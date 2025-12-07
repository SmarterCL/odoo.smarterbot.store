const DEMO_URL = "https://flow.smarterbot.cl/"

export function openDemoPopup() {
  if (typeof window === "undefined") return
  // Open in the same tab to avoid popups being blocked.
  window.location.href = DEMO_URL
}
