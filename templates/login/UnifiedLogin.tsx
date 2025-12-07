"use client"

import * as React from "react"
import { useClerk, useSignIn } from "@clerk/nextjs"

import "../../design/login-theme/global.css"
import "../../design/login-theme/components.css"

import { LoginButton } from "./LoginButton"
import { LoginInput } from "./LoginInput"

export interface UnifiedLoginProps {
  tenant?: string
  redirectUrl?: string
  googleRedirectUrl?: string
  provider?: "clerk"
  logoSrc?: string
  supportEmail?: string
  enablePassword?: boolean
  enableGoogle?: boolean
  onAfterSignIn?: (payload: SignInResultPayload) => Promise<void> | void
}

export interface SignInResultPayload {
  tenant?: string
  redirectUrl?: string
  provider: "clerk"
  strategy: "password" | "google"
  sessionId?: string | null
}

const DEFAULT_LOGO = "/design/login-theme/smarterbot-logo.svg"

export function UnifiedLogin({
  tenant,
  redirectUrl = "/dashboard",
  googleRedirectUrl = "/sso-callback",
  provider = "clerk",
  logoSrc = DEFAULT_LOGO,
  supportEmail = "soporte@smarterbot.cl",
  enablePassword = true,
  enableGoogle = true,
  onAfterSignIn,
}: UnifiedLoginProps) {
  const { signIn, isLoaded } = useSignIn()
  const { setActive } = useClerk()

  const [email, setEmail] = React.useState("")
  const [password, setPassword] = React.useState("")
  const [loading, setLoading] = React.useState(false)
  const [error, setError] = React.useState<string | null>(null)
  const [status, setStatus] = React.useState<{ type: "success" | "error"; message: string } | null>(null)

  const tenantLabel = tenant ? tenant.toUpperCase() : "TENANT DEFAULT"

  const handlePasswordSignIn = async (event: React.FormEvent) => {
    event.preventDefault()

    if (!enablePassword) return
    if (!isLoaded || !signIn) {
      setError("Clerk todavía no termina de cargar. Intenta nuevamente en unos segundos.")
      return
    }

    setLoading(true)
    setError(null)
    setStatus(null)

    try {
      const result = await signIn.create({ identifier: email, password })

      if (result.status === "complete") {
        await setActive({ session: result.createdSessionId })
        await onAfterSignIn?.({ tenant, redirectUrl, provider, strategy: "password", sessionId: result.createdSessionId })
        setStatus({ type: "success", message: "Acceso concedido. Redirigiendo..." })
        if (typeof window !== "undefined") {
          window.location.assign(redirectUrl)
        }
        return
      }

      if (result.status === "needs_first_factor") {
        setStatus({ type: "error", message: "Tu cuenta requiere un factor adicional. Completa el flujo en la pantalla siguiente." })
      } else {
        setStatus({ type: "error", message: `Flujo pendiente: ${result.status}` })
      }
    } catch (authError: any) {
      setError(authError?.errors?.[0]?.message ?? "Credenciales inválidas. Intenta nuevamente.")
    } finally {
      setLoading(false)
    }
  }

  const handleGoogleRedirect = async () => {
    if (!enableGoogle) return
    if (!isLoaded || !signIn) {
      setStatus({ type: "error", message: "Clerk no está listo todavía. Recarga la página." })
      return
    }

    setStatus(null)
    setLoading(true)

    try {
      await onAfterSignIn?.({ tenant, redirectUrl, provider, strategy: "google", sessionId: null })
      await signIn.authenticateWithRedirect({
        strategy: "oauth_google",
        redirectUrl: googleRedirectUrl,
        redirectUrlComplete: redirectUrl,
        additionalScopes: ["email", "profile"],
        unsafeMetadata: tenant ? { tenant } : undefined,
      })
    } catch (authError: any) {
      setLoading(false)
      setStatus({ type: "error", message: authError?.errors?.[0]?.message ?? "No se pudo iniciar sesión con Google." })
    }
  }

  return (
    <div className="so-login-wrapper" style={{ backgroundImage: "url('/design/login-theme/login-bg.svg')", backgroundSize: "cover" }}>
      <div className="so-login-card">
        <div className="so-login-card-content">
          <header className="so-login-header">
            <img src={logoSrc} alt="SmarterOS" className="so-login-logo" />
            <p className="so-tenant-badge">Tenant · {tenantLabel}</p>
            <h1 className="so-login-title">Bienvenido a SmarterOS</h1>
            <p className="so-login-subtitle">Accede a tu panel corporativo y mantén el control en un solo login.</p>
          </header>

          {status ? <div className={`so-login-status ${status.type}`}>{status.message}</div> : null}

          {enablePassword ? (
            <form className="so-login-form" onSubmit={handlePasswordSignIn} noValidate>
              <LoginInput
                type="email"
                label="Correo corporativo"
                placeholder="founder@company.com"
                value={email}
                onChange={(event) => setEmail(event.target.value)}
                required
                error={error ?? undefined}
              />
              <LoginInput
                type="password"
                label="Contraseña"
                placeholder="••••••••"
                value={password}
                onChange={(event) => setPassword(event.target.value)}
                required
                error={null}
              />
              <LoginButton type="submit" loading={loading} disabled={!email || !password || loading}>
                Iniciar sesión
              </LoginButton>
            </form>
          ) : null}

          {enablePassword && enableGoogle ? <div className="so-divider">o continúa con</div> : null}

          {enableGoogle ? (
            <LoginButton
              type="button"
              variant="google"
              loading={loading && !enablePassword}
              onClick={handleGoogleRedirect}
              icon={
                <svg width="20" height="20" viewBox="0 0 533.5 544.3" aria-hidden="true">
                  <path
                    fill="#4285f4"
                    d="M533.5 278.4c0-17.4-1.5-34.1-4.3-50.4H272.1v95.4h147.3c-6.4 34.8-25.6 64.2-54.6 84v69.7h88.4c51.7-47.6 80.3-118 80.3-198.7z"
                  />
                  <path fill="#34a853" d="M272.1 544.3c73.5 0 135.2-24.3 180.3-66.2l-88.4-69.7c-24.6 16.5-56.2 26-91.9 26-70.7 0-130.7-47.7-152.1-111.7H28.4v70.2c45.3 89.5 137.9 151.4 243.7 151.4z" />
                  <path fill="#fbbc05" d="M120 322.7c-10.9-34.8-10.9-72.3 0-107.1V145.4H28.4c-36.6 73-36.6 160.1 0 233.1l91.6-55.8z" />
                  <path fill="#ea4335" d="M272.1 107.7c39.9-.6 78.1 14.4 107.2 41.9l79.5-79.5c-48.8-45.4-112.7-70.6-186.7-70.1-105.8 0-198.4 61.9-243.7 151.4l91.6 70.2c21.4-64 81.4-111.7 152.1-111.7z" />
                </svg>
              }
            >
              Continuar con Google
            </LoginButton>
          ) : null}

          <section className="so-login-metadata">
            <span>Proveedor: {provider === "clerk" ? "Clerk" : "Custom"}</span>
            <span>Redirección: {redirectUrl}</span>
            {tenant ? <span>Tenant detectado: {tenant}</span> : <span>Tenant por defecto configurado</span>}
          </section>

          <footer className="so-login-footer">
            ¿Necesitas ayuda? <a className="so-login-support" href={`mailto:${supportEmail}`}>{supportEmail}</a>
          </footer>
        </div>
      </div>
    </div>
  )
}
