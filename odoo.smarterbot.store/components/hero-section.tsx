import { Button } from "@/components/ui/button"
import { Badge } from "@/components/ui/badge"
import { ArrowRight, Zap, CheckCircle2 } from "lucide-react"

export function HeroSection() {
  return (
    <section className="relative min-h-screen bg-foreground text-background pt-16 overflow-hidden">
      {/* Background Pattern */}
      <div className="absolute inset-0 opacity-5">
        <div className="absolute top-20 left-10 w-72 h-72 bg-primary rounded-full blur-3xl" />
        <div className="absolute bottom-20 right-10 w-96 h-96 bg-accent rounded-full blur-3xl" />
      </div>

      <div className="container mx-auto px-4 py-20 lg:py-32 relative z-10">
        <div className="grid lg:grid-cols-2 gap-12 items-center">
          {/* Left Content */}
          <div className="space-y-8">
            <Badge variant="outline" className="border-primary/50 text-primary bg-primary/10 px-4 py-2">
              <Zap className="w-4 h-4 mr-2" />
              Odoo + IA + Automatización
            </Badge>

            <h1 className="text-4xl md:text-5xl lg:text-6xl font-bold leading-tight text-balance">
              Odoo ERP en Chile, <span className="text-primary">sin integraciones dolorosas</span>
            </h1>

            <p className="text-lg text-background/70 max-w-xl leading-relaxed">
              Implementamos Odoo con conexiones listas a WhatsApp, IA local, n8n y tu negocio real. Pruébalo gratis.
            </p>

            <div className="flex flex-col sm:flex-row gap-4">
              <Button size="lg" className="bg-primary text-primary-foreground hover:bg-primary/90">
                Quiero ver una demo
                <ArrowRight className="ml-2 w-4 h-4" />
              </Button>
              <Button
                size="lg"
                variant="outline"
                className="border-background/30 text-background hover:bg-background/10 bg-transparent"
              >
                Agenda una llamada 20 min
              </Button>
            </div>

            <div className="flex flex-wrap gap-6 pt-4">
              {["WhatsApp integrado", "IA local con Ollama", "Automatización n8n"].map((item) => (
                <div key={item} className="flex items-center gap-2 text-sm text-background/70">
                  <CheckCircle2 className="w-4 h-4 text-primary" />
                  {item}
                </div>
              ))}
            </div>
          </div>

          {/* Right Content - Image */}
          <div className="relative">
            <div className="relative rounded-2xl overflow-hidden aspect-[4/3]">
              <img
                src="/modern-tech-dashboard-with-automation-flows-and-ai.jpg"
                alt="SmarterOS Dashboard con automatización e IA"
                className="object-cover w-full h-full"
              />
              <div className="absolute inset-0 bg-gradient-to-t from-foreground/60 to-transparent" />

              {/* Floating Card */}
              <div className="absolute bottom-6 left-6 right-6 bg-card/95 backdrop-blur-sm rounded-xl p-4 text-card-foreground">
                <div className="flex items-center justify-between">
                  <div>
                    <p className="text-sm text-muted-foreground">Ahorro en integración</p>
                    <p className="text-2xl font-bold text-primary">+70%</p>
                  </div>
                  <div className="h-12 w-px bg-border" />
                  <div>
                    <p className="text-sm text-muted-foreground">Tiempo de setup</p>
                    <p className="text-2xl font-bold text-primary">-50%</p>
                  </div>
                  <div className="h-12 w-px bg-border" />
                  <div>
                    <p className="text-sm text-muted-foreground">Sin SaaS cerrado</p>
                    <p className="text-2xl font-bold text-primary">100%</p>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </section>
  )
}
