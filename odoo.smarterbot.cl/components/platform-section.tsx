'use client'

import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card"
import { MessageCircle, BarChart3, Database, ShoppingCart, CreditCard, GitBranch } from "lucide-react"

const features = [
    {
        icon: MessageCircle,
        title: "WhatsApp Business",
        description: "Ventas y soporte integrado",
        color: "text-green-500",
        bgColor: "bg-green-500/10",
    },
    {
        icon: BarChart3,
        title: "CRM Comercial",
        description: "Gestión de clientes y oportunidades",
        color: "text-blue-500",
        bgColor: "bg-blue-500/10",
    },
    {
        icon: Database,
        title: "Odoo ERP",
        description: "Facturación electrónica y gestión",
        color: "text-purple-500",
        bgColor: "bg-purple-500/10",
    },
    {
        icon: ShoppingCart,
        title: "Tienda Online",
        description: "Ventas con boleta o factura",
        color: "text-orange-500",
        bgColor: "bg-orange-500/10",
    },
    {
        icon: CreditCard,
        title: "Flow",
        description: "Cobros por redes sociales",
        color: "text-indigo-500",
        bgColor: "bg-indigo-500/10",
    },
    {
        icon: GitBranch,
        title: "Automatizaciones N8N",
        description: "Flujos entre todos los sistemas",
        color: "text-pink-500",
        bgColor: "bg-pink-500/10",
    },
]

export function PlatformSection() {
    return (
        <section className="py-20 lg:py-32 bg-background">
            <div className="container mx-auto px-4">
                <div className="text-center mb-16 max-w-3xl mx-auto">
                    <p className="text-sm font-medium text-primary mb-4 uppercase tracking-wider">
                        WhatsApp • CRM • ERP • Pagos • Automatizaciones
                    </p>
                    <h2 className="text-3xl md:text-4xl font-bold text-foreground mb-6 text-balance">
                        Smarterbot es la interfaz de acceso a SmarterOS.
                    </h2>
                    <p className="text-muted-foreground text-lg leading-relaxed">
                        Un sistema operativo en la nube que integra herramientas reales de operación diaria en un solo entorno. Todo funciona conectado. Sin duplicar datos. Sin operaciones manuales innecesarias.
                    </p>
                </div>

                <div className="grid md:grid-cols-2 lg:grid-cols-3 gap-6 mb-16">
                    {features.map((feature) => (
                        <Card
                            key={feature.title}
                            className="group hover:shadow-lg transition-all duration-300 border-border/50 hover:border-primary/30"
                        >
                            <CardHeader className="flex flex-row items-center gap-4 pb-2">
                                <div className={`w-12 h-12 rounded-lg ${feature.bgColor} flex items-center justify-center transition-colors`}>
                                    <feature.icon className={`w-6 h-6 ${feature.color}`} />
                                </div>
                                <CardTitle className="text-lg">{feature.title}</CardTitle>
                            </CardHeader>
                            <CardContent>
                                <p className="text-sm text-muted-foreground">{feature.description}</p>
                            </CardContent>
                        </Card>
                    ))}
                </div>

                <div className="text-center">
                    <p className="text-xl md:text-2xl font-semibold text-foreground">
                        Una sola plataforma. Múltiples operaciones. Cero fricción.
                    </p>
                </div>
            </div>
        </section>
    )
}
