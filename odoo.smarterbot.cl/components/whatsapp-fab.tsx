"use client"

import { MessageCircle } from "lucide-react"
import { DEMO_WHATSAPP_MESSAGE, DEMO_WHATSAPP_URL } from "@/lib/whatsapp-demo"

export function WhatsAppFab() {
  return (
    <a
      href={DEMO_WHATSAPP_URL}
      target="_blank"
      rel="noreferrer"
      className="fixed bottom-4 right-4 z-50 flex items-center gap-3 bg-green-500 text-white px-4 py-3 rounded-full shadow-lg hover:bg-green-600 transition-colors"
      aria-label={`${DEMO_WHATSAPP_MESSAGE} por WhatsApp`}
    >
      <MessageCircle className="w-5 h-5" />
      <span className="hidden sm:inline text-sm font-semibold">{DEMO_WHATSAPP_MESSAGE}</span>
    </a>
  )
}
