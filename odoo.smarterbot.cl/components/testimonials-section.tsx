import { Card, CardContent } from "@/components/ui/card"
import { Button } from "@/components/ui/button"
import { CheckCircle2, ArrowRight } from "lucide-react"

const pilotFeatures = [
  "Alcance limitado pero real (ventas + facturación, por ejemplo)",
  "Datos de prueba o una muestra de tus datos reales",
  "Automatización básica ya funcionando",
  "Si no te aporta valor, no sigues. Sin letra chica.",
]

export function TestimonialsSection() {
  return (
    <section className="py-20 lg:py-32 bg-muted">
      <div className="container mx-auto px-4">
        <div className="max-w-3xl mx-auto text-center">
          <p className="text-sm font-medium text-primary mb-4">Prueba sin riesgo</p>
          <h2 className="text-3xl md:text-4xl font-bold text-foreground mb-6 text-balance">
            ¿Te interesa probar Odoo sin sufrir un proyecto eterno?
          </h2>
          <p className="text-muted-foreground mb-12">
            Te ofrecemos un piloto guiado para que veas resultados reales antes de comprometerte.
          </p>

          <Card className="bg-card text-left">
            <CardContent className="p-8">
              <ul className="space-y-4 mb-8">
                {pilotFeatures.map((feature) => (
                  <li key={feature} className="flex items-start gap-3">
                    <CheckCircle2 className="w-5 h-5 text-primary mt-0.5 flex-shrink-0" />
                    <span className="text-foreground">{feature}</span>
                  </li>
                ))}
              </ul>

              <div className="flex flex-col sm:flex-row gap-4">
                <Button size="lg" className="bg-primary text-primary-foreground hover:bg-primary/90">
                  Quiero probar Odoo con SmarterOS
                  <ArrowRight className="ml-2 w-4 h-4" />
                </Button>
                <Button size="lg" variant="outline">
                  Envíame más información
                </Button>
              </div>
            </CardContent>
          </Card>
        </div>
      </div>
    </section>
  )
}
