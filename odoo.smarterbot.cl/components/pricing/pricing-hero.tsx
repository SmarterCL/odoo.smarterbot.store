"use client"

import Link from "next/link"
import { openDemoPopup } from "@/lib/open-demo"

export default function PricingHero() {
  return (
    <section className="bg-gradient-to-br from-primary/10 via-accent/5 to-background pt-24 pb-16 lg:pb-24 px-4 sm:px-6 lg:px-8">
      <div className="max-w-4xl mx-auto text-center">
        <p className="text-sm font-semibold text-primary mb-3">Planes SmarterOS</p>
        <h1 className="text-4xl lg:text-5xl font-bold text-foreground mb-4 text-pretty">
          Automatización comercial con Odoo 19 + WhatsApp + n8n
        </h1>
        <p className="text-lg text-muted-foreground mb-10 text-pretty">
          Precios en UF + IVA, sin SaaS externo. Toda la infraestructura y datos bajo tu control, alineado al stack
          SmarterOS.
        </p>
        <div className="flex flex-col sm:flex-row gap-3 justify-center">
          <button
            className="px-8 py-3 bg-primary text-primary-foreground rounded-lg font-semibold hover:bg-primary/90 transition-colors shadow-sm"
            onClick={openDemoPopup}
          >
            Ver Demo
          </button>
          <Link
            href="#contacto"
            className="px-8 py-3 bg-secondary text-secondary-foreground rounded-lg font-semibold hover:bg-secondary/80 transition-colors border border-border"
          >
            Contactar ventas
          </Link>
        </div>
      </div>
    </section>
  )
}
