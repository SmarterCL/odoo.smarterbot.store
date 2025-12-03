import { NextResponse } from "next/server"

const RESEND_ENDPOINT = "https://api.resend.com/emails"
const TO_EMAIL = "smarterbotcl@gmail.com"
// Resend solo acepta remitentes verificados o el dominio onboarding@resend.dev
const FROM_EMAIL = process.env.RESEND_FROM_EMAIL || "SmarterOS <onboarding@resend.dev>"

export async function POST(request: Request) {
  try {
    const apiKey = process.env.RESEND_API_KEY
    if (!apiKey) {
      return NextResponse.json({ error: "Missing RESEND_API_KEY" }, { status: 500 })
    }

    const body = await request.json()
    const { name, email, company, message } = body || {}

    if (!name || !email || !message) {
      return NextResponse.json({ error: "Faltan campos requeridos" }, { status: 400 })
    }

    const subject = "Contacto landing Odoo + SmarterOS"
    const html = `
      <p><strong>Nombre:</strong> ${name}</p>
      <p><strong>Email:</strong> ${email}</p>
      <p><strong>Empresa:</strong> ${company || "N/A"}</p>
      <p><strong>Mensaje:</strong></p>
      <p>${message}</p>
    `

    const resendResponse = await fetch(RESEND_ENDPOINT, {
      method: "POST",
      headers: {
        Authorization: `Bearer ${apiKey}`,
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        from: FROM_EMAIL,
        to: [TO_EMAIL],
        subject,
        html,
      }),
    })

    if (!resendResponse.ok) {
      const errorText = await resendResponse.text()
      return NextResponse.json({ error: "Error enviando correo", details: errorText }, { status: 502 })
    }

    return NextResponse.json({ success: true })
  } catch (error) {
    console.error("Error en /api/contact:", error)
    return NextResponse.json({ error: "Error interno" }, { status: 500 })
  }
}
