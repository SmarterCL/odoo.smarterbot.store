"use client"

import { MessageCircle } from "lucide-react"

const WHATSAPP_NUMBER = "56979540471"
const WHATSAPP_MESSAGE = encodeURIComponent("Quiero una cita para el demo Odoo")
const WHATSAPP_LINK = `https://wa.me/${WHATSAPP_NUMBER}?text=${WHATSAPP_MESSAGE}`

export function WhatsAppFab() {
  return (
    <a
      href={WHATSAPP_LINK}
      target="_blank"
      rel="noreferrer"
      className="fixed bottom-4 right-4 z-50 flex items-center gap-3 bg-green-500 text-white px-4 py-3 rounded-full shadow-lg hover:bg-green-600 transition-colors"
      aria-label="Quiero una cita para el demo Odoo por WhatsApp"
    >
      <MessageCircle className="w-5 h-5" />
      <span className="hidden sm:inline text-sm font-semibold">Quiero una cita para el demo Odoo</span>
    </a>
  )
}
