import type { Metadata } from "next"
import PricingClient from "./pricing-client-component"

export const metadata: Metadata = {
  title: "Planes y Precios | SmarterOS",
  description: "Conoce los planes de automatización comercial y ERP con Odoo 19, WhatsApp y n8n.",
}

export default function PreciosPage() {
  return <PricingClient />
}
