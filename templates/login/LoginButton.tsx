import * as React from "react"

type Variant = "primary" | "outline" | "ghost" | "google"

type IconPosition = "left" | "right"

export interface LoginButtonProps extends React.ButtonHTMLAttributes<HTMLButtonElement> {
  variant?: Variant
  loading?: boolean
  icon?: React.ReactNode
  iconPosition?: IconPosition
}

function getVariantClass(variant: Variant = "primary") {
  switch (variant) {
    case "outline":
      return "so-button-outline"
    case "ghost":
      return "so-button-ghost"
    case "google":
      return "so-button-google"
    default:
      return "so-button-primary"
  }
}

export const LoginButton = React.forwardRef<HTMLButtonElement, LoginButtonProps>(
  ({ children, variant = "primary", loading = false, icon, iconPosition = "left", className, disabled, ...props }, ref) => {
    return (
      <button
        ref={ref}
        className={["so-button", getVariantClass(variant), className].filter(Boolean).join(" ")}
        disabled={disabled || loading}
        {...props}
      >
        {icon && iconPosition === "left" ? icon : null}
        {loading ? "Procesando..." : children}
        {icon && iconPosition === "right" ? icon : null}
      </button>
    )
  }
)
LoginButton.displayName = "LoginButton"
