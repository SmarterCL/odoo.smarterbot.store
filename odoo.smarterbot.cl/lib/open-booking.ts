const BOOKING_URL = "https://systeme.smarterbot.store/booking.html"

export function openBookingPopup() {
  if (typeof window === "undefined") return

  // Try popup, fallback to same tab (especially on mobile).
  const popup = window.open(BOOKING_URL, "smarterbotBooking", "width=1200,height=800,noopener,noreferrer")
  if (!popup) {
    window.location.href = BOOKING_URL
    return
  }
  popup.opener = null
  popup.focus()
}
