import { Header } from "@/components/header"
import { Footer } from "@/components/footer"
import { Button } from "@/components/ui/button"

const featurePills = [
  "WhatsApp Business",
  "CRM + ERP",
  "Facturación electrónica",
]

const integratedOps = [
  "WhatsApp • CRM • ERP • Pagos • Automatizaciones",
  "Interfaz Smarterbot sobre SmarterOS: todo conectado, sin datos duplicados",
  "Operación real en Chile: ventas, soporte, facturación, cobros y flujos n8n",
]

const stacks = [
  { title: "WhatsApp Business", desc: "Ventas y soporte integrado" },
  { title: "CRM Comercial", desc: "Gestión de clientes y oportunidades" },
  { title: "Odoo ERP", desc: "Facturación electrónica y gestión" },
  { title: "Tienda Online", desc: "Ventas con boleta o factura" },
  { title: "Flow", desc: "Cobros por redes sociales" },
  { title: "Automatizaciones n8n", desc: "Flujos entre todos los sistemas" },
]

const plans = [
  {
    name: "Startup",
    badge: "–15% descuento",
    price: "$25.000/mes",
    note: "$29.000",
    commission: "Tu comisión: $38.000",
    bullets: [
      "CRM básico",
      "Chat omnicanal",
      "Automatizaciones básicas",
      "Gestión de contactos",
      "Reportes básicos",
    ],
    channels: ["WhatsApp"],
  },
  {
    name: "Pro",
    badge: "–20% descuento",
    price: "$39.000/mes",
    note: "$49.000",
    commission: "Tu comisión: $75.000",
    highlight: true,
    bullets: [
      "WhatsApp Business + CRM",
      "Facturación electrónica",
      "Gestión de clientes",
      "Cobros por Flow",
      "Conciliación automática",
    ],
    channels: ["WhatsApp"],
  },
  {
    name: "Enterprise",
    badge: "–25% descuento",
    price: "$74.000/mes",
    note: "$99.000",
    commission: "Tu comisión: $140.000",
    bullets: [
      "Todo Plan Pro +",
      "ERP completo",
      "Integraciones API",
      "Soporte prioritario",
      "Automatizaciones avanzadas",
    ],
    channels: ["WhatsApp"],
  },
]

const steps = [
  "Seleccionas un plan",
  "Defines la duración",
  "Compartes por WhatsApp",
  "Descuento inmediato",
  "Comisión automática",
  "Recibe tu pago",
]

const industries = [
  "Empresas en crecimiento",
  "Comercios físicos",
  "Estudios contables",
  "Agencias de marketing",
  "Emprendedores digitales",
  "Consultores de negocios",
]

export default function SmarterbotPage() {
  return (
    <main className="min-h-screen bg-background text-foreground">
      <Header />

      <section className="relative overflow-hidden bg-gradient-to-b from-white to-neutral-50 px-6 py-16 sm:px-8 md:py-20">
        <div className="mx-auto max-w-5xl space-y-8 text-center">
          <div className="flex items-center justify-center gap-2 text-sm font-semibold text-primary">
            <span className="inline-flex h-8 items-center rounded-full bg-primary/5 px-3">⚡ SmarterOS</span>
            <span className="text-muted-foreground">Centraliza ventas, gestión y cobros</span>
          </div>
          <div className="space-y-4">
            <h1 className="text-4xl font-bold tracking-tight sm:text-5xl">SmarterBOT</h1>
            <p className="text-lg text-muted-foreground sm:text-xl">
              WhatsApp Business para ventas y soporte, CRM comercial, facturación electrónica, gestión de empresa y
              cobros por redes sociales. Todo integrado para operar en Chile.
            </p>
          </div>
          <div className="flex flex-wrap items-center justify-center gap-3">
            <Button size="lg" className="px-6">
              Activar ahora
            </Button>
            <Button size="lg" variant="outline" className="px-6">
              Recomendar y obtener comisión
            </Button>
          </div>
          <p className="text-sm text-muted-foreground">
            Sin formularios. Activación inmediata por WhatsApp. Valores en pesos chilenos + IVA. Solo para empresas con
            RUT.
          </p>
          <div className="flex flex-wrap justify-center gap-2 text-sm font-medium">
            {featurePills.map((item) => (
              <span key={item} className="rounded-full bg-primary/5 px-3 py-1 text-primary">
                {item}
              </span>
            ))}
          </div>
        </div>
      </section>

      <section className="px-6 py-16 sm:px-8">
        <div className="mx-auto max-w-6xl space-y-6">
          <div className="space-y-3 text-center">
            <div className="inline-flex items-center rounded-full bg-primary/5 px-3 py-1 text-xs font-semibold text-primary">
              🚀 Tu operación digital, integrada
            </div>
            <h2 className="text-3xl font-bold sm:text-4xl">Una sola plataforma. Múltiples operaciones. Cero fricción.</h2>
            <p className="text-muted-foreground">
              Smarterbot es la interfaz de acceso a SmarterOS: un sistema operativo en la nube que conecta ventas,
              soporte, gestión y cobros en un solo entorno.
            </p>
          </div>
          <div className="grid gap-4 rounded-2xl border bg-white/60 p-6 shadow-sm md:grid-cols-3">
            {integratedOps.map((item) => (
              <div key={item} className="rounded-xl bg-primary/5 p-4 text-sm font-medium text-primary">
                {item}
              </div>
            ))}
          </div>
          <div className="grid gap-4 md:grid-cols-3">
            {stacks.map((stack) => (
              <div
                key={stack.title}
                className="rounded-2xl border bg-white p-5 shadow-sm transition hover:-translate-y-1 hover:shadow-md"
              >
                <div className="text-sm font-semibold text-primary">{stack.title}</div>
                <p className="mt-2 text-sm text-muted-foreground">{stack.desc}</p>
              </div>
            ))}
          </div>
        </div>
      </section>

      <section className="bg-neutral-950 px-6 py-16 text-white sm:px-8">
        <div className="mx-auto max-w-6xl space-y-8">
          <div className="space-y-3 text-center">
            <h2 className="text-3xl font-bold sm:text-4xl">Planes Smarter por industria</h2>
            <p className="text-neutral-300">
              Valores en CLP + IVA. Cada plan incluye herramientas operativas reales integradas en SmarterOS.
            </p>
            <div className="flex justify-center gap-3 text-sm text-neutral-300">
              <span className="rounded-full bg-white/10 px-3 py-1">Mensual</span>
              <span className="rounded-full bg-white/10 px-3 py-1">12 Meses</span>
              <span className="rounded-full bg-white/10 px-3 py-1">24 Meses</span>
            </div>
          </div>
          <div className="grid gap-6 md:grid-cols-3">
            {plans.map((plan) => (
              <div
                key={plan.name}
                className={`rounded-2xl border border-white/10 bg-white/5 p-6 shadow-xl backdrop-blur transition ${
                  plan.highlight ? "ring-2 ring-primary/70" : ""
                }`}
              >
                <div className="flex items-center justify-between">
                  <div>
                    <div className="text-lg font-semibold">{plan.name}</div>
                    <div className="text-xs text-neutral-300">{plan.badge}</div>
                  </div>
                  <div className="rounded-full bg-white/10 px-3 py-1 text-xs">{plan.commission}</div>
                </div>
                <div className="mt-4 text-3xl font-bold">{plan.price}</div>
                <div className="text-sm text-neutral-300">Precio normal {plan.note}</div>
                <ul className="mt-4 space-y-2 text-sm text-neutral-100">
                  {plan.bullets.map((item) => (
                    <li key={item} className="flex items-start gap-2">
                      <span className="mt-1 inline-block h-1.5 w-1.5 rounded-full bg-primary" />
                      <span>{item}</span>
                    </li>
                  ))}
                </ul>
                <div className="mt-4 flex flex-wrap gap-2 text-xs text-neutral-200">
                  {plan.channels.map((channel) => (
                    <span key={channel} className="rounded-full bg-white/10 px-3 py-1">
                      {channel}
                    </span>
                  ))}
                </div>
                <div className="mt-6 flex gap-2">
                  <Button className="w-full" variant={plan.highlight ? "default" : "secondary"}>
                    Activar
                  </Button>
                  <Button className="w-full" variant="outline">
                    Copiar
                  </Button>
                </div>
              </div>
            ))}
          </div>
        </div>
      </section>

      <section className="px-6 py-16 sm:px-8">
        <div className="mx-auto max-w-5xl space-y-10">
          <div className="space-y-3 text-center">
            <h2 className="text-3xl font-bold sm:text-4xl">Cómo funciona la recomendación empresarial</h2>
            <p className="text-muted-foreground">Seis pasos simples. Sin formularios. Sin vendedores. Sin fricción.</p>
          </div>
          <div className="grid gap-4 sm:grid-cols-2 md:grid-cols-3">
            {steps.map((step, index) => (
              <div key={step} className="rounded-2xl border bg-white p-5 shadow-sm">
                <div className="mb-2 flex h-10 w-10 items-center justify-center rounded-full bg-primary/10 text-sm font-semibold text-primary">
                  {index + 1}
                </div>
                <div className="text-sm font-semibold text-primary">{step}</div>
              </div>
            ))}
          </div>
          <p className="text-center text-sm text-muted-foreground">
            Modelo válido solo para empresas con RUT. Operación real. Sin promesas de ingresos automáticos.
          </p>
        </div>
      </section>

      <section className="bg-neutral-50 px-6 py-16 sm:px-8">
        <div className="mx-auto max-w-6xl space-y-8">
          <div className="space-y-3 text-center">
            <h2 className="text-3xl font-bold sm:text-4xl">Para quién es SmarterOS</h2>
            <p className="text-muted-foreground">Si tu negocio opera en Chile y necesita integrar ventas, gestión y cobros, esto es para ti.</p>
          </div>
          <div className="grid gap-3 sm:grid-cols-2 md:grid-cols-3">
            {industries.map((industry) => (
              <div key={industry} className="rounded-xl border bg-white p-4 text-sm font-semibold text-primary">
                {industry}
              </div>
            ))}
          </div>
        </div>
      </section>

      <section className="px-6 py-16 sm:px-8">
        <div className="mx-auto max-w-5xl space-y-6 text-center">
          <div className="inline-flex items-center rounded-full bg-primary/5 px-3 py-1 text-xs font-semibold text-primary">
            Soy .Smarter
          </div>
          <h2 className="text-3xl font-bold sm:text-4xl">SmarterOS no es solo una plataforma. Es una comunidad.</h2>
          <p className="text-muted-foreground">
            Interoperabilidad real entre empresas que operan sobre un mismo sistema digital. Comisiones justas y una
            red de empresas que crece con cada activación.
          </p>
          <div className="grid gap-4 sm:grid-cols-3">
            {["Interoperabilidad real", "Comisiones justas", "Red de empresas"].map((item) => (
              <div key={item} className="rounded-2xl border bg-white p-5 shadow-sm">
                <div className="text-sm font-semibold text-primary">{item}</div>
              </div>
            ))}
          </div>
        </div>
      </section>

      <section className="bg-neutral-950 px-6 py-16 text-white sm:px-8">
        <div className="mx-auto max-w-5xl space-y-6 text-center">
          <h2 className="text-3xl font-bold sm:text-4xl">Activa tu empresa en SmarterOS hoy</h2>
          <p className="text-neutral-300">Acceso inmediato. Sin formularios. Sin llamadas. Solo operación real.</p>
          <div className="flex flex-wrap justify-center gap-3">
            <Button size="lg" className="px-6">
              Activar Smarterbot
            </Button>
            <Button size="lg" variant="outline" className="px-6">
              Recomendar a otra empresa
            </Button>
          </div>
          <p className="text-xs text-neutral-400">
            Valores expresados en pesos chilenos + IVA • Uso exclusivo para empresas con RUT
          </p>
        </div>
      </section>

      <Footer />
    </main>
  )
}
