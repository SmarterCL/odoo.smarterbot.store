import { Card, CardContent } from "@/components/ui/card"
import { Button } from "@/components/ui/button"
import { Truck, Package, Building2, Laptop, ShoppingCart, Globe } from "lucide-react"

const verticals = [
  {
    icon: Package,
    title: "Importación y distribución",
    description: "Control total de gastos, documentación aduanera y logística internacional con trazabilidad completa.",
  },
  {
    icon: Building2,
    title: "Empresas de servicios B2B",
    description: "Gestión de proyectos, hojas de tiempo, facturación automatizada y seguimiento de clientes.",
  },
  {
    icon: Truck,
    title: "Logística y transporte",
    description: "Optimiza rutas, gestiona flotas y controla inventarios en tiempo real con IA.",
  },
  {
    icon: ShoppingCart,
    title: "Alimentos y retail",
    description: "Trazabilidad completa, gestión de lotes, fechas de vencimiento y punto de venta integrado.",
  },
  {
    icon: Laptop,
    title: "SaaS / tecnología",
    description: "Facturación recurrente, gestión de suscripciones y métricas de producto.",
  },
  {
    icon: Globe,
    title: "Comercio exterior",
    description: "Multi-moneda, multi-empresa y gestión documental para operaciones internacionales.",
  },
]

export function VerticalsSection() {
  return (
    <section id="sectores" className="py-20 lg:py-32 bg-background">
      <div className="container mx-auto px-4">
        <div className="text-center mb-16">
          <p className="text-sm font-medium text-primary mb-4">Sectores</p>
          <h2 className="text-3xl md:text-4xl font-bold text-foreground mb-6 text-balance">
            Sectores donde SmarterOS + Odoo ya marcan la diferencia
          </h2>
          <p className="text-muted-foreground max-w-2xl mx-auto">
            Cada industria tiene particularidades. SmarterOS te da un ERP + automatización + canales digitales adaptados
            a la realidad chilena.
          </p>
        </div>

        <div className="grid md:grid-cols-2 lg:grid-cols-3 gap-6">
          {verticals.map((vertical) => (
            <Card
              key={vertical.title}
              className="group hover:shadow-lg transition-all duration-300 border-border/50 hover:border-primary/30 overflow-hidden"
            >
              <CardContent className="p-6">
                <div className="flex items-start gap-4">
                  <div className="w-12 h-12 rounded-lg bg-primary/10 flex items-center justify-center flex-shrink-0 group-hover:bg-primary/20 transition-colors">
                    <vertical.icon className="w-6 h-6 text-primary" />
                  </div>
                  <div>
                    <h3 className="font-semibold text-foreground mb-2">{vertical.title}</h3>
                    <p className="text-sm text-muted-foreground leading-relaxed">{vertical.description}</p>
                  </div>
                </div>
              </CardContent>
            </Card>
          ))}
        </div>

        <div className="text-center mt-12">
          <Button size="lg" className="bg-primary text-primary-foreground hover:bg-primary/90">
            Cuéntanos tu industria
          </Button>
        </div>
      </div>
    </section>
  )
}
