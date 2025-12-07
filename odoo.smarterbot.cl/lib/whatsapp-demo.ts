const DEMO_WHATSAPP_NUMBER = "56979540471"
export const DEMO_WHATSAPP_MESSAGE = "Quiero una reunion para Odoo 19"

export const DEMO_WHATSAPP_URL = `https://wa.me/${DEMO_WHATSAPP_NUMBER}?text=${encodeURIComponent(DEMO_WHATSAPP_MESSAGE)}`

export function openWhatsAppDemo() {
  if (typeof window === "undefined") return

  // Redirect in the same tab so it works reliably on mobile and desktop.
  window.location.href = DEMO_WHATSAPP_URL
}
