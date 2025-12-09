import { Header } from "@/components/header"
import { Footer } from "@/components/footer"
import { Button } from "@/components/ui/button"

const heroPills = ["WhatsApp Business", "CRM + ERP", "Facturación electrónica"]

const highlights = [
  "Operación real en Chile: ventas, soporte, facturación y cobros integrados",
  "Smarterbot como interfaz de SmarterOS: todo conectado, sin datos duplicados",
  "Flujos n8n y pagos en línea listos para usar",
]

const stack = [
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
    badge: "–15%",
    price: "$25.000/mes",
    note: "$29.000",
    commission: "Comisión: $38.000",
    bullets: ["CRM básico", "Chat omnicanal", "Automatizaciones básicas", "Gestión de contactos", "Reportes básicos"],
  },
  {
    name: "Pro",
    badge: "–20%",
    price: "$39.000/mes",
    note: "$49.000",
    commission: "Comisión: $75.000",
    highlight: true,
    bullets: [
      "WhatsApp Business + CRM",
      "Facturación electrónica",
      "Gestión de clientes",
      "Cobros por Flow",
      "Conciliación automática",
    ],
  },
  {
    name: "Enterprise",
    badge: "–25%",
    price: "$74.000/mes",
    note: "$99.000",
    commission: "Comisión: $140.000",
    bullets: ["Todo Plan Pro +", "ERP completo", "Integraciones API", "Soporte prioritario", "Automatizaciones avanzadas"],
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

export default function VinculantePage() {
  return (
    <main className="min-h-screen bg-amber-50 text-amber-950">
      <Header />

      <section className="relative overflow-hidden bg-gradient-to-b from-amber-100 via-white to-amber-50 px-6 py-16 sm:px-8 md:py-20">
        <div className="mx-auto max-w-5xl space-y-8 text-center">
          <div className="flex items-center justify-center gap-2 text-sm font-semibold text-amber-700">
            <span className="inline-flex h-8 items-center rounded-full bg-amber-200/80 px-3 text-amber-800">⚡ SmarterOS</span>
            <span className="text-amber-700/80">Centraliza ventas, gestión y cobros</span>
          </div>
          <div className="space-y-4">
            <h1 className="text-4xl font-bold tracking-tight sm:text-5xl text-amber-900">SmarterBOT Vinculante</h1>
            <p className="text-lg text-amber-800 sm:text-xl">
              WhatsApp Business para ventas y soporte, CRM comercial, facturación electrónica y cobros integrados en
              SmarterOS. Operación real en Chile.
            </p>
          </div>
          <div className="flex flex-wrap items-center justify-center gap-3">
            <Button size="lg" className="bg-amber-600 text-white hover:bg-amber-700 px-6">
              Activar ahora
            </Button>
            <Button size="lg" variant="outline" className="border-amber-600 text-amber-700 hover:bg-amber-100 px-6">
              Recomendar y obtener comisión
            </Button>
          </div>
          <p className="text-sm text-amber-700/80">
            Sin formularios. Activación inmediata por WhatsApp. Valores en pesos chilenos + IVA. Solo para empresas con
            RUT.
          </p>
          <div className="flex flex-wrap justify-center gap-2 text-sm font-medium">
            {heroPills.map((item) => (
              <span key={item} className="rounded-full bg-amber-200/80 px-3 py-1 text-amber-800">
                {item}
              </span>
            ))}
          </div>
        </div>
      </section>

      <section className="px-6 py-16 sm:px-8">
        <div className="mx-auto max-w-6xl space-y-6">
          <div className="space-y-3 text-center">
            <div className="inline-flex items-center rounded-full bg-amber-200/80 px-3 py-1 text-xs font-semibold text-amber-800">
              🚀 Operación integrada
            </div>
            <h2 className="text-3xl font-bold sm:text-4xl text-amber-900">Todo conectado. Cero fricción.</h2>
            <p className="text-amber-700">
              Smarterbot es la interfaz de SmarterOS para operar WhatsApp, CRM, ERP y cobros en un solo entorno.
            </p>
          </div>
          <div className="grid gap-4 rounded-2xl border border-amber-200 bg-white p-6 shadow-sm md:grid-cols-3">
            {highlights.map((item) => (
              <div key={item} className="rounded-xl bg-amber-100 p-4 text-sm font-medium text-amber-900">
                {item}
              </div>
            ))}
          </div>
          <div className="grid gap-4 md:grid-cols-3">
            {stack.map((item) => (
              <div
                key={item.title}
                className="rounded-2xl border border-amber-200 bg-white p-5 shadow-sm transition hover:-translate-y-1 hover:shadow-md"
              >
                <div className="text-sm font-semibold text-amber-900">{item.title}</div>
                <p className="mt-2 text-sm text-amber-700">{item.desc}</p>
              </div>
            ))}
          </div>
        </div>
      </section>

      <section className="bg-amber-900 px-6 py-16 text-amber-50 sm:px-8">
        <div className="mx-auto max-w-6xl space-y-8">
          <div className="space-y-3 text-center">
            <h2 className="text-3xl font-bold sm:text-4xl">Planes Smarter por industria</h2>
            <p className="text-amber-100/80">
              Valores en CLP + IVA. Cada plan incluye herramientas operativas reales integradas en SmarterOS.
            </p>
            <div className="flex justify-center gap-3 text-sm text-amber-100/80">
              <span className="rounded-full bg-amber-800 px-3 py-1">Mensual</span>
              <span className="rounded-full bg-amber-800 px-3 py-1">12 Meses</span>
              <span className="rounded-full bg-amber-800 px-3 py-1">24 Meses</span>
            </div>
          </div>
          <div className="grid gap-6 md:grid-cols-3">
            {plans.map((plan) => (
              <div
                key={plan.name}
                className={`rounded-2xl border border-amber-800 bg-amber-800/60 p-6 shadow-xl backdrop-blur transition ${
                  plan.highlight ? "ring-2 ring-amber-300/70" : ""
                }`}
              >
                <div className="flex items-center justify-between">
                  <div>
                    <div className="text-lg font-semibold text-amber-50">{plan.name}</div>
                    <div className="text-xs text-amber-100/80">{plan.badge}</div>
                  </div>
                  <div className="rounded-full bg-amber-700 px-3 py-1 text-xs text-amber-50">{plan.commission}</div>
                </div>
                <div className="mt-4 text-3xl font-bold text-amber-50">{plan.price}</div>
                <div className="text-sm text-amber-100/80">Precio normal {plan.note}</div>
                <ul className="mt-4 space-y-2 text-sm text-amber-50">
                  {plan.bullets.map((item) => (
                    <li key={item} className="flex items-start gap-2">
                      <span className="mt-1 inline-block h-1.5 w-1.5 rounded-full bg-amber-200" />
                      <span>{item}</span>
                    </li>
                  ))}
                </ul>
                <div className="mt-6 flex gap-2">
                  <Button className="w-full bg-amber-300 text-amber-900 hover:bg-amber-200" variant="default">
                    Activar
                  </Button>
                  <Button className="w-full border-amber-200 text-amber-50" variant="outline">
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
            <h2 className="text-3xl font-bold sm:text-4xl text-amber-900">Cómo funciona la recomendación empresarial</h2>
            <p className="text-amber-700">Seis pasos simples. Sin formularios. Sin vendedores. Sin fricción.</p>
          </div>
          <div className="grid gap-4 sm:grid-cols-2 md:grid-cols-3">
            {steps.map((step, index) => (
              <div key={step} className="rounded-2xl border border-amber-200 bg-white p-5 shadow-sm">
                <div className="mb-2 flex h-10 w-10 items-center justify-center rounded-full bg-amber-100 text-sm font-semibold text-amber-900">
                  {index + 1}
                </div>
                <div className="text-sm font-semibold text-amber-900">{step}</div>
              </div>
            ))}
          </div>
          <p className="text-center text-sm text-amber-700">
            Modelo válido solo para empresas con RUT. Operación real. Sin promesas de ingresos automáticos.
          </p>
        </div>
      </section>

      <section className="bg-amber-100 px-6 py-16 sm:px-8">
        <div className="mx-auto max-w-6xl space-y-8">
          <div className="space-y-3 text-center">
            <h2 className="text-3xl font-bold sm:text-4xl text-amber-900">Para quién es SmarterOS</h2>
            <p className="text-amber-700">Si tu negocio opera en Chile y necesita integrar ventas, gestión y cobros, esto es para ti.</p>
          </div>
          <div className="grid gap-3 sm:grid-cols-2 md:grid-cols-3">
            {industries.map((industry) => (
              <div key={industry} className="rounded-xl border border-amber-200 bg-white p-4 text-sm font-semibold text-amber-900">
                {industry}
              </div>
            ))}
          </div>
        </div>
      </section>

      <section className="px-6 py-16 sm:px-8">
        <div className="mx-auto max-w-5xl space-y-6 text-center">
          <div className="inline-flex items-center rounded-full bg-amber-200/80 px-3 py-1 text-xs font-semibold text-amber-900">
            Soy .Smarter
          </div>
          <h2 className="text-3xl font-bold sm:text-4xl text-amber-900">Comunidad SmarterOS</h2>
          <p className="text-amber-700">
            Interoperabilidad real entre empresas que operan sobre un mismo sistema digital. Comisiones justas y una
            red de empresas que crece con cada activación.
          </p>
          <div className="grid gap-4 sm:grid-cols-3">
            {["Interoperabilidad real", "Comisiones justas", "Red de empresas"].map((item) => (
              <div key={item} className="rounded-2xl border border-amber-200 bg-white p-5 shadow-sm">
                <div className="text-sm font-semibold text-amber-900">{item}</div>
              </div>
            ))}
          </div>
        </div>
      </section>

      <section className="bg-amber-900 px-6 py-16 text-amber-50 sm:px-8">
        <div className="mx-auto max-w-5xl space-y-6 text-center">
          <h2 className="text-3xl font-bold sm:text-4xl">Activa tu empresa en SmarterOS hoy</h2>
          <p className="text-amber-100/80">Acceso inmediato. Sin formularios. Sin llamadas. Solo operación real.</p>
          <div className="flex flex-wrap justify-center gap-3">
            <Button size="lg" className="bg-amber-300 text-amber-900 hover:bg-amber-200 px-6">
              Activar Smarterbot
            </Button>
            <Button size="lg" variant="outline" className="border-amber-200 text-amber-50 px-6">
              Recomendar a otra empresa
            </Button>
          </div>
          <p className="text-xs text-amber-100/80">
            Valores expresados en pesos chilenos + IVA • Uso exclusivo para empresas con RUT
          </p>
        </div>
      </section>

      <Footer />
    </main>
  )
}
