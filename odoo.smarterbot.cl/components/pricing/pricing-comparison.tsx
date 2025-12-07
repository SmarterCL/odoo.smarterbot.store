"use client"

import React from "react"
import { Check, X } from "lucide-react"
import { openDemoPopup } from "@/lib/open-demo"

const plans = ["Base", "Operación", "Empresa", "Corporativo"]

const comparison = [
  {
    category: "CRM",
    items: [
      { label: "Gestión de leads", availability: [true, true, true, true] },
      { label: "Pipeline de ventas", availability: [true, true, true, true] },
      { label: "WhatsApp integrado", availability: [true, true, true, true] },
      { label: "Automatizaciones", availability: [false, true, true, true] },
    ],
  },
  {
    category: "ERP",
    items: [
      { label: "Ventas y compras", availability: [false, true, true, true] },
      { label: "Inventario", availability: [false, true, true, true] },
      { label: "Contabilidad", availability: [false, true, true, true] },
      { label: "Facturación electrónica", availability: [false, true, true, true] },
    ],
  },
  {
    category: "Automatización",
    items: [
      { label: "Flujos n8n v2", availability: [false, false, true, true] },
      { label: "Bots WhatsApp", availability: [false, false, true, true] },
      { label: "Webhooks", availability: [false, false, true, true] },
      { label: "Integraciones", availability: [false, false, true, true] },
    ],
  },
  {
    category: "Soporte",
    items: [
      { label: "Email support", availability: [false, false, false, true] },
      { label: "Documentación", availability: [false, false, false, true] },
      { label: "Consultoría", availability: [false, false, false, true] },
      { label: "SLA 24/7", availability: [false, false, false, true] },
    ],
  },
]

export default function PricingComparison() {
  return (
    <section className="py-16 lg:py-24 px-4 sm:px-6 lg:px-8 bg-secondary/30">
      <div className="max-w-7xl mx-auto">
        <h2 className="text-3xl lg:text-4xl font-bold text-foreground mb-12 text-center text-pretty">
          Comparativa de planes
        </h2>

        <div className="overflow-x-auto">
          <table className="w-full">
            <thead>
              <tr className="border-b border-border">
                <th className="text-left py-4 px-4 font-semibold text-foreground">Características</th>
                {plans.map((plan) => (
                  <th key={plan} className="text-center py-4 px-4 font-semibold text-foreground">
                    {plan}
                  </th>
                ))}
              </tr>
            </thead>
            <tbody>
              {comparison.map((section) => (
                <React.Fragment key={section.category}>
                  <tr className="bg-primary/5 border-b border-border">
                    <td colSpan={plans.length + 1} className="py-3 px-4 font-semibold text-foreground text-sm">
                      {section.category}
                    </td>
                  </tr>
                  {section.items.map((item) => (
                    <tr key={item.label} className="border-b border-border hover:bg-background/50">
                      <td className="py-3 px-4 text-sm text-foreground">{item.label}</td>
                      {item.availability.map((isIncluded, planIdx) => (
                        <td key={`${item.label}-${plans[planIdx]}`} className="text-center py-3 px-4">
                          {isIncluded ? (
                            <Check className="w-5 h-5 text-primary mx-auto" />
                          ) : (
                            <X className="w-5 h-5 text-muted-foreground mx-auto" />
                          )}
                        </td>
                      ))}
                    </tr>
                  ))}
                </React.Fragment>
              ))}
            </tbody>
          </table>
        </div>

        <div className="mt-12 bg-card rounded-xl p-8 border border-border text-center">
          <h3 className="text-xl font-bold text-foreground mb-3">¿Necesitas una solución personalizada?</h3>
          <p className="text-muted-foreground mb-6">
            Agenda una demo para revisar tu arquitectura (multi-RUT, alta disponibilidad, agentes MCP personalizados o
            infraestructura propia).
          </p>
          <div className="flex justify-center">
            <button
              className="px-8 py-3 bg-primary text-primary-foreground rounded-lg font-semibold hover:bg-primary/90 transition-colors"
              onClick={openDemoPopup}
            >
              Solicitar demo
            </button>
          </div>
        </div>
      </div>
    </section>
  )
}
