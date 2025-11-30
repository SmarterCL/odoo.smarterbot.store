import type React from "react"
import type { Metadata } from "next"
import { Inter, Geist_Mono } from "next/font/google"
import { Analytics } from "@vercel/analytics/next"
import "./globals.css"

const _inter = Inter({ subsets: ["latin"] })
const _geistMono = Geist_Mono({ subsets: ["latin"] })

export const metadata: Metadata = {
  title: "SmarterOS Chile | Odoo ERP + IA + Automatización",
  description:
    "Implementamos Odoo con conexiones listas a WhatsApp, IA local, n8n y tu negocio real. Especialistas Odoo en Chile con enfoque en automatización e inteligencia artificial.",
  keywords: "Odoo, ERP, Chile, implementación, automatización, IA, n8n, WhatsApp, SmarterOS",
  generator: "v0.app",
}

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode
}>) {
  return (
    <html lang="es">
      <body className={`font-sans antialiased`}>
        {children}
        <Analytics />
      </body>
    </html>
  )
}
