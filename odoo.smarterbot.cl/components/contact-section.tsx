"use client"

import type React from "react"

import { useState } from "react"
import { openBookingPopup } from "@/lib/open-booking"
import { Button } from "@/components/ui/button"
import { Input } from "@/components/ui/input"
import { Textarea } from "@/components/ui/textarea"
import { Card, CardContent } from "@/components/ui/card"
import { Phone, Mail, Clock, MapPin, Send } from "lucide-react"

const contactInfo = [
  {
    icon: Phone,
    label: "Teléfono",
    value: "+56979540471",
    href: "tel:+56979540471",
  },
  {
    icon: Mail,
    label: "Email",
    value: "contacto@smarterbot.cl",
    href: "mailto:contacto@smarterbot.cl",
  },
  {
    icon: Clock,
    label: "Horario",
    value: "Lunes a Viernes, 9:00-18:00",
  },
  {
    icon: MapPin,
    label: "Ubicación",
    value: "Chile - Proyectos remotos y presenciales",
  },
]

export function ContactSection() {
  const [formData, setFormData] = useState({
    name: "",
    email: "",
    company: "",
    message: "",
  })
  const [sending, setSending] = useState(false)
  const [feedback, setFeedback] = useState<"idle" | "ok" | "error">("idle")

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault()
    setSending(true)
    setFeedback("idle")
    try {
      const res = await fetch("/api/contact", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify(formData),
      })
      if (!res.ok) throw new Error("Error enviando formulario")
      setFeedback("ok")
      setFormData({ name: "", email: "", company: "", message: "" })
    } catch (err) {
      console.error(err)
      setFeedback("error")
    } finally {
      setSending(false)
    }
  }

  return (
    <section id="contacto" className="py-20 lg:py-32 bg-background">
      <div className="container mx-auto px-4">
        <div className="grid lg:grid-cols-2 gap-12">
          {/* Left - Contact Info */}
          <div className="space-y-8">
            <div>
              <p className="text-sm font-medium text-primary mb-4">Contacto</p>
              <h2 className="text-3xl md:text-4xl font-bold text-foreground mb-6 text-balance">
                Hablemos de tu proyecto
              </h2>
              <p className="text-muted-foreground leading-relaxed">
                SmarterOS Chile - Plataforma de automatización y ERP basada en Odoo, n8n, Chatwoot, Supabase y Ollama.
              </p>
              <p className="text-muted-foreground leading-relaxed">
                Chile - proyectos remotos y presenciales.
              </p>
              <Button
                className="mt-4 bg-primary text-primary-foreground hover:bg-primary/90"
                onClick={openBookingPopup}
              >
                Agenda una demo
              </Button>
            </div>

            <div className="grid sm:grid-cols-2 gap-4">
              {contactInfo.map((info) => (
                <Card key={info.label} className="border-border/50">
                  <CardContent className="p-4 flex items-center gap-4">
                    <div className="w-10 h-10 rounded-lg bg-primary/10 flex items-center justify-center flex-shrink-0">
                      <info.icon className="w-5 h-5 text-primary" />
                    </div>
                    <div>
                      <p className="text-xs text-muted-foreground">{info.label}</p>
                      {info.href ? (
                        <a
                          href={info.href}
                          className="text-sm font-medium text-foreground hover:text-primary transition-colors"
                        >
                          {info.value}
                        </a>
                      ) : (
                        <p className="text-sm font-medium text-foreground">{info.value}</p>
                      )}
                    </div>
                  </CardContent>
                </Card>
              ))}
            </div>

            <div className="p-6 bg-primary/5 rounded-2xl border border-primary/20">
              <p className="text-sm text-foreground">
                <strong className="text-primary">Stack completo:</strong>
                <br />
                Odoo Enterprise + n8n + WhatsApp Cloud API + Chatwoot + Ollama (IA local) + Supabase + VPS gestionado
              </p>
            </div>
          </div>

          {/* Right - Contact Form */}
          <Card className="border-border/50">
            <CardContent className="p-6">
              <form onSubmit={handleSubmit} className="space-y-6">
                <div className="grid sm:grid-cols-2 gap-4">
                  <div className="space-y-2">
                    <label htmlFor="name" className="text-sm font-medium text-foreground">
                      Nombre
                    </label>
                    <Input
                      id="name"
                      placeholder="Tu nombre"
                      value={formData.name}
                      onChange={(e) => setFormData({ ...formData, name: e.target.value })}
                      required
                    />
                  </div>
                  <div className="space-y-2">
                    <label htmlFor="email" className="text-sm font-medium text-foreground">
                      Email
                    </label>
                    <Input
                      id="email"
                      type="email"
                      placeholder="tu@email.com"
                      value={formData.email}
                      onChange={(e) => setFormData({ ...formData, email: e.target.value })}
                      required
                    />
                  </div>
                </div>

                <div className="space-y-2">
                  <label htmlFor="company" className="text-sm font-medium text-foreground">
                    Empresa
                  </label>
                  <Input
                    id="company"
                    placeholder="Nombre de tu empresa"
                    value={formData.company}
                    onChange={(e) => setFormData({ ...formData, company: e.target.value })}
                  />
                </div>

                <div className="space-y-2">
                  <label htmlFor="message" className="text-sm font-medium text-foreground">
                    Mensaje
                  </label>
                  <Textarea
                    id="message"
                    placeholder="Cuéntanos sobre tu proyecto..."
                    rows={5}
                    value={formData.message}
                    onChange={(e) => setFormData({ ...formData, message: e.target.value })}
                    required
                  />
                </div>

                <Button
                  type="submit"
                  size="lg"
                  className="w-full bg-primary text-primary-foreground hover:bg-primary/90"
                  disabled={sending}
                >
                  {sending ? "Enviando..." : "Enviar mensaje"}
                  <Send className="ml-2 w-4 h-4" />
                </Button>
                {feedback === "ok" && (
                  <p className="text-sm text-green-600">Mensaje enviado. Te contactaremos pronto.</p>
                )}
                {feedback === "error" && (
                  <p className="text-sm text-red-600">No se pudo enviar. Intenta nuevamente en unos minutos.</p>
                )}
              </form>
            </CardContent>
          </Card>
        </div>
      </div>
    </section>
  )
}
