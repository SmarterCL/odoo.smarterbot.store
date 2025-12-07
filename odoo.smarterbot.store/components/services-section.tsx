import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card"
import { Button } from "@/components/ui/button"
import { Settings, Link2, Headphones, Code, ArrowRight } from "lucide-react"

const services = [
  {
    icon: Settings,
    title: "Implementación Odoo Enterprise",
    description:
      "Diseñamos el proyecto según tus procesos: ventas, compras, inventario, contabilidad, servicio técnico y más. Incluye análisis, parametrización y salida en producción.",
    cta: "Iniciar proyecto",
  },
  {
    icon: Link2,
    title: "Integraciones listas para usar",
    description:
      "Conectamos Odoo con WhatsApp Business (Cloud API), portales web, ecommerce y APIs externas. Sin integraciones a medida eternas ni sorpresas ocultas.",
    cta: "Ver integraciones",
  },
  {
    icon: Headphones,
    title: "Servicios profesionales Odoo",
    description:
      "Soporte técnico, migración de versiones, formación a usuarios y hosting gestionado. Un equipo que entiende negocio, no solo código.",
    cta: "Solicitar soporte",
  },
  {
    icon: Code,
    title: "Desarrollo a medida sobre Odoo",
    description:
      "Cuando tu proceso no cabe en un módulo estándar, extendemos Odoo con desarrollos limpios, documentados y mantenibles.",
    cta: "Personalizar Odoo",
  },
]

export function ServicesSection() {
  return (
    <section id="servicios" className="py-20 lg:py-32 bg-background">
      <div className="container mx-auto px-4">
        <div className="text-center mb-16">
          <p className="text-sm font-medium text-primary mb-4">Nuestros servicios</p>
          <h2 className="text-3xl md:text-4xl font-bold text-foreground mb-6 text-balance">
            Especialistas Odoo en Chile, con enfoque en automatización e IA
          </h2>
          <p className="text-muted-foreground max-w-2xl mx-auto">
            No solo te dejamos Odoo andando: lo conectamos con tu operación real
          </p>
        </div>

        <div className="grid md:grid-cols-2 lg:grid-cols-4 gap-6">
          {services.map((service) => (
            <Card
              key={service.title}
              className="group hover:shadow-lg transition-all duration-300 border-border/50 hover:border-primary/30"
            >
              <CardHeader>
                <div className="w-12 h-12 rounded-lg bg-primary/10 flex items-center justify-center mb-4 group-hover:bg-primary/20 transition-colors">
                  <service.icon className="w-6 h-6 text-primary" />
                </div>
                <CardTitle className="text-lg">{service.title}</CardTitle>
              </CardHeader>
              <CardContent className="space-y-4">
                <p className="text-sm text-muted-foreground leading-relaxed">{service.description}</p>
                <Button variant="link" className="p-0 h-auto text-primary hover:text-primary/80">
                  {service.cta}
                  <ArrowRight className="ml-1 w-4 h-4" />
                </Button>
              </CardContent>
            </Card>
          ))}
        </div>
      </div>
    </section>
  )
}
