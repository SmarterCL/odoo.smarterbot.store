import { CheckCircle2 } from "lucide-react"
import { Button } from "@/components/ui/button"

const benefits = [
  "Odoo no queda solo: viene conectado a IA local, WhatsApp, n8n y tu stack",
  "Todo corre en tu VPS o nuestro VPS gestionado, no dependes de un SaaS cerrado",
  "Multi-empresa y multi-RUT desde el diseño, pensando en Chile",
  "Migración de canales de soporte a Chatwoot incluida",
  "Documentación y scripts para que no quedes atado a una sola persona",
]

export function TransformSection() {
  return (
    <section id="diferenciadores" className="py-20 lg:py-32 bg-muted">
      <div className="container mx-auto px-4">
        <div className="grid lg:grid-cols-2 gap-12 items-center">
          {/* Left - Image */}
          <div className="relative">
            <div className="grid grid-cols-2 gap-4">
              <div className="space-y-4">
                <div className="rounded-2xl overflow-hidden aspect-square">
                  <img
                    src="/automation-workflow-dashboard-n8n-style.jpg"
                    alt="Automatización con n8n"
                    className="object-cover w-full h-full"
                  />
                </div>
                <div className="rounded-2xl overflow-hidden aspect-video">
                  <img
                    src="/whatsapp-business-chat-integration.jpg"
                    alt="WhatsApp Business integrado"
                    className="object-cover w-full h-full"
                  />
                </div>
              </div>
              <div className="space-y-4 pt-8">
                <div className="rounded-2xl overflow-hidden aspect-video">
                  <img src="/modern-ai-chatbot.png" alt="IA y Chatbots" className="object-cover w-full h-full" />
                </div>
                <div className="rounded-2xl overflow-hidden aspect-square">
                  <img
                    src="/server-infrastructure-vps-cloud.jpg"
                    alt="Infraestructura propia"
                    className="object-cover w-full h-full"
                  />
                </div>
              </div>
            </div>
          </div>

          {/* Right - Content */}
          <div className="space-y-8">
            <div>
              <p className="text-sm font-medium text-primary mb-4">Nuestra diferencia</p>
              <h2 className="text-3xl md:text-4xl font-bold text-foreground mb-6 text-balance">
                ¿Qué hacemos distinto a un partner Odoo tradicional?
              </h2>
              <p className="text-muted-foreground leading-relaxed">
                En SmarterOS unimos Odoo Enterprise, automatización con n8n, WhatsApp oficial, IA local con Ollama y un
                centro de agentes MCP, todo corriendo en tu propio servidor o en nuestra infraestructura gestionada.
              </p>
            </div>

            <ul className="space-y-4">
              {benefits.map((benefit) => (
                <li key={benefit} className="flex items-start gap-3">
                  <CheckCircle2 className="w-5 h-5 text-primary mt-0.5 flex-shrink-0" />
                  <span className="text-foreground">{benefit}</span>
                </li>
              ))}
            </ul>

            <Button size="lg" className="bg-primary text-primary-foreground hover:bg-primary/90">
              Conoce cómo funciona
            </Button>
          </div>
        </div>
      </div>
    </section>
  )
}
