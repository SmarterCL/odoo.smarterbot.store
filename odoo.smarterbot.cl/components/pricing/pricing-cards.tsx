"use client"

import { Check } from "lucide-react"
import { openDemoPopup } from "@/lib/open-demo"

const plans = [
  {
    name: "Plan Base",
    price: "2,5",
    description: "CRM + WhatsApp",
    features: [
      "CRM completo",
      "WhatsApp Cloud API",
      "1 flujo n8n v2",
      "1 dominio y multi-RUT básico",
      "Emails automáticos",
      "Dashboard comercial",
    ],
    highlighted: false,
  },
  {
    name: "Plan Operación",
    price: "5",
    description: "CRM + ERP + WhatsApp + BD",
    features: [
      "Todo del Plan Base",
      "ERP Odoo 19 (ventas + compras + inventario)",
      "Base de Datos empresarial",
      "5 flujos n8n v2",
      "Catálogo unificado",
      "Hosting VPS gestionado (opcional)",
    ],
    highlighted: true,
  },
  {
    name: "Plan Empresa",
    price: "10",
    description: "ERP Completo + IA + Automatización",
    features: [
      "Odoo 19 con módulos avanzados",
      "Integraciones (ecommerce, portales, facturación)",
      "IA local con Ollama",
      "WhatsApp avanzado (plantillas, triggers)",
      "20 flujos n8n v2",
      "Chatwoot integrado",
    ],
    highlighted: false,
  },
  {
    name: "Plan Corporativo",
    price: "18+",
    description: "Multi-Sucursal + Multi-RUT",
    features: [
      "Todo el stack completo",
      "Multi-empresa ilimitada",
      "Infra propia (VPS o bare metal)",
      "Monitor 24/7",
      "Alta disponibilidad",
      "Agentes MCP personalizados",
    ],
    highlighted: false,
  },
]

export default function PricingCards() {
  return (
    <section className="py-16 lg:py-24 px-4 sm:px-6 lg:px-8 bg-background">
      <div className="max-w-7xl mx-auto">
        <p className="text-center text-muted-foreground mb-12">
          <span className="font-semibold text-foreground">Precios en UF + IVA</span> · Stack sin SaaS externo, datos
          bajo tu control
        </p>

        <div className="grid md:grid-cols-2 lg:grid-cols-4 gap-6">
          {plans.map((plan) => (
            <div
              key={plan.name}
              className={`rounded-xl transition-all ${
                plan.highlighted
                  ? "bg-primary/5 border-2 border-primary shadow-lg scale-105 md:scale-100"
                  : "bg-card border border-border hover:border-primary/50 hover:shadow-md"
              }`}
            >
              <div className="p-6">
                {plan.highlighted && (
                  <div className="inline-block bg-primary text-primary-foreground text-xs font-bold px-3 py-1 rounded-full mb-3">
                    Recomendado
                  </div>
                )}

                <h3 className="text-xl font-bold text-foreground mb-1">{plan.name}</h3>
                <p className="text-sm text-muted-foreground mb-4">{plan.description}</p>

                <div className="mb-6">
                  <span className="text-3xl font-bold text-foreground">UF {plan.price}</span>
                  <span className="text-muted-foreground text-sm">/mes + IVA</span>
                </div>

                <button
                  className={`w-full py-3 rounded-lg font-semibold transition-colors mb-6 ${
                    plan.highlighted
                      ? "bg-primary text-primary-foreground hover:bg-primary/90"
                      : "bg-secondary text-secondary-foreground hover:bg-secondary/80 border border-border"
                  }`}
                  onClick={openDemoPopup}
                >
                  Quiero ver demo
                </button>

                <div className="space-y-3">
                  {plan.features.map((feature, idx) => (
                    <div key={idx} className="flex gap-3 items-start">
                      <Check className="w-5 h-5 text-primary flex-shrink-0 mt-0.5" />
                      <span className="text-sm text-foreground leading-snug">{feature}</span>
                    </div>
                  ))}
                </div>
              </div>
            </div>
          ))}
        </div>
      </div>
    </section>
  )
}
