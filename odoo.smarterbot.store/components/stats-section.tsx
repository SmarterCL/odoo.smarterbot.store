"use client"

import { useEffect, useState, useRef } from "react"

const stats = [
  { value: 70, suffix: "%", label: "Ahorro en tiempo de integración" },
  { value: 100, suffix: "%", label: "Control de tu infraestructura" },
  { value: 24, suffix: "/7", label: "Monitoreo de sistemas" },
  { value: 0, suffix: "", label: "Dependencia de SaaS cerrados", displayValue: "Cero" },
]

function AnimatedNumber({ value, suffix, displayValue }: { value: number; suffix: string; displayValue?: string }) {
  const [count, setCount] = useState(0)
  const ref = useRef<HTMLDivElement>(null)
  const [hasAnimated, setHasAnimated] = useState(false)

  useEffect(() => {
    const observer = new IntersectionObserver(
      ([entry]) => {
        if (entry.isIntersecting && !hasAnimated) {
          setHasAnimated(true)
          if (displayValue) {
            setCount(value)
            return
          }
          const duration = 2000
          const steps = 60
          const increment = value / steps
          let current = 0

          const timer = setInterval(() => {
            current += increment
            if (current >= value) {
              setCount(value)
              clearInterval(timer)
            } else {
              setCount(Math.floor(current))
            }
          }, duration / steps)
        }
      },
      { threshold: 0.5 },
    )

    if (ref.current) {
      observer.observe(ref.current)
    }

    return () => observer.disconnect()
  }, [value, hasAnimated, displayValue])

  return (
    <div ref={ref} className="text-4xl md:text-5xl font-bold text-background">
      {displayValue || (
        <>
          {count.toLocaleString()}
          {suffix}
        </>
      )}
    </div>
  )
}

export function StatsSection() {
  return (
    <section className="py-20 lg:py-32 bg-foreground text-background">
      <div className="container mx-auto px-4">
        <div className="text-center mb-16">
          <p className="text-sm font-medium text-primary mb-4">SmarterOS en números</p>
          <h2 className="text-3xl md:text-4xl font-bold mb-6 text-balance">Resultados que marcan la diferencia</h2>
          <p className="text-background/70 max-w-2xl mx-auto">
            Llevamos años trabajando con empresas chilenas que necesitan algo más que un ERP instalado.
          </p>
        </div>

        <div className="grid grid-cols-2 lg:grid-cols-4 gap-8">
          {stats.map((stat) => (
            <div key={stat.label} className="text-center space-y-2">
              <AnimatedNumber value={stat.value} suffix={stat.suffix} displayValue={stat.displayValue} />
              <p className="text-sm text-background/70">{stat.label}</p>
            </div>
          ))}
        </div>
      </div>
    </section>
  )
}
