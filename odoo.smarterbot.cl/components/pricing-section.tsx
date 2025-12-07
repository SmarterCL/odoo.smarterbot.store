'use client'

import { useState } from "react"
import { Check, Copy, Mail, MessageCircle } from "lucide-react"
import { Button } from "@/components/ui/button"
import { Card, CardContent, CardFooter, CardHeader, CardTitle } from "@/components/ui/card"
import { Tabs, TabsList, TabsTrigger } from "@/components/ui/tabs"

const plans = [
    {
        name: "Startup",
        description: "Para emprendimientos",
        basePrice: 29000,
        price24m: 25000,
        commission24m: 38000,
        discountLabel: "–15% descuento",
        features: [
            "CRM básico",
            "Chat omnicanal",
            "Automatizaciones básicas",
            "Gestión de contactos",
            "Reportes básicos",
        ],
        highlighted: false,
    },
    {
        name: "Pro",
        description: "Para operación completa",
        basePrice: 49000,
        price24m: 39000,
        commission24m: 75000,
        discountLabel: "–20% descuento",
        popular: true,
        features: [
            "WhatsApp Business + CRM",
            "Facturación electrónica",
            "Gestión de clientes",
            "Cobros por Flow",
            "Conciliación automática",
        ],
        highlighted: true,
    },
    {
        name: "Enterprise",
        description: "Para operación avanzada",
        basePrice: 99000,
        price24m: 74000,
        commission24m: 140000,
        discountLabel: "–25% descuento",
        features: [
            "Todo Plan Pro +",
            "ERP completo",
            "Integraciones API",
            "Soporte prioritario",
            "Automatizaciones avanzadas",
        ],
        highlighted: false,
    },
]

export function PricingSection() {
    const [cycle, setCycle] = useState("24") // default to 24 months as per request mockup implication

    return (
        <section className="py-20 bg-background/50">
            <div className="container mx-auto px-4">
                <div className="text-center mb-12">
                    <h2 className="text-3xl font-bold mb-4">Planes Smarter por industria</h2>
                    <p className="text-muted-foreground">
                        Valores en CLP + IVA. Cada plan incluye herramientas operativas reales integradas en SmarterOS.
                    </p>
                </div>

                <div className="flex justify-center mb-12">
                    <Tabs defaultValue="24" className="w-auto" onValueChange={setCycle}>
                        <TabsList className="grid w-full grid-cols-3">
                            <TabsTrigger value="1">Mensual</TabsTrigger>
                            <TabsTrigger value="12">12 Meses</TabsTrigger>
                            <TabsTrigger value="24">24 Meses</TabsTrigger>
                        </TabsList>
                    </Tabs>
                </div>

                <div className="grid md:grid-cols-3 gap-8 max-w-6xl mx-auto">
                    {plans.map((plan) => {
                        // Logic for price display based on cycle
                        // Current user data only explicitly provided 24m vs Base ("Mensual" implied by base price).
                        // For 12m, we'll interpolate or just show base for now to be safe, or use 24m price if user wants to push long term.
                        // ACTUALLY, checking the user request: "Mensual / 12 Meses / 24 Meses"
                        // And the detail provided: "–15% descuento / $29.000 / $25.000/mes" maps to the Discounted view.
                        // So:
                        // If Cycle == 1: Show Base Price. No Discount text.
                        // If Cycle == 24: Show Discounted Price. Show Discount Text.
                        // If Cycle == 12: We don't have explicit data. I will assume it's same as 24 or slightly more.
                        // Let's use the 24m price for 12m for now as "Annual Plans" usually get the discount, unless specified otherwise. 
                        // Better yet, let's keep it simple: 
                        // 1 = Base Price
                        // 12/24 = Discounted Price (since 24 is explicit, maybe 12 is same deal or slightly less discount?) 
                        // I'll stick to the "24m" data for the "Discounted" view since that matches the text provided best.

                        const isDiscounted = cycle !== "1"
                        const currentPrice = isDiscounted ? plan.price24m : plan.basePrice
                        const originalPrice = isDiscounted ? plan.basePrice : null

                        return (
                            <Card
                                key={plan.name}
                                className={`relative flex flex-col ${plan.highlighted ? 'border-primary shadow-lg scale-105 z-10' : 'border-border'}`}
                            >
                                {plan.popular && (
                                    <div className="absolute -top-4 left-0 right-0 flex justify-center">
                                        <span className="bg-primary text-primary-foreground text-xs font-bold px-3 py-1 rounded-full">
                                            Más popular
                                        </span>
                                    </div>
                                )}

                                <CardHeader>
                                    <CardTitle className="text-2xl font-bold">{plan.name}</CardTitle>
                                    <p className="text-sm text-muted-foreground">{plan.description}</p>
                                </CardHeader>

                                <CardContent className="flex-1 space-y-6">
                                    <div>
                                        {isDiscounted && (
                                            <div className="flex items-center gap-2 mb-2">
                                                <span className="text-xs font-bold text-green-600 bg-green-100 px-2 py-0.5 rounded-full">
                                                    {plan.discountLabel}
                                                </span>
                                                {originalPrice && (
                                                    <span className="text-sm text-muted-foreground line-through">
                                                        ${originalPrice.toLocaleString('es-CL')}
                                                    </span>
                                                )}
                                            </div>
                                        )}
                                        <div className="flex items-end gap-1">
                                            <span className="text-4xl font-bold">
                                                ${currentPrice.toLocaleString('es-CL')}
                                            </span>
                                            <span className="text-muted-foreground mb-1">/mes</span>
                                        </div>

                                        {/* Unique requirement from user: "Tu comisión" */}
                                        {isDiscounted && (
                                            <p className="text-sm text-primary font-medium mt-2">
                                                Tu comisión: ${(plan.commission24m).toLocaleString('es-CL')}
                                            </p>
                                        )}
                                    </div>

                                    <ul className="space-y-3">
                                        {plan.features.map((feature) => (
                                            <li key={feature} className="flex items-start gap-2 text-sm">
                                                <Check className="w-4 h-4 text-primary mt-0.5 shrink-0" />
                                                <span className="text-muted-foreground">{feature}</span>
                                            </li>
                                        ))}
                                    </ul>
                                </CardContent>

                                <CardFooter className="flex gap-4 border-t pt-6 text-muted-foreground">
                                    <Button variant="ghost" size="icon" className="hover:text-[#25D366] hover:bg-[#25D366]/10">
                                        <MessageCircle className="w-5 h-5" />
                                    </Button>
                                    <Button variant="ghost" size="icon" className="hover:text-primary hover:bg-primary/10">
                                        <Mail className="w-5 h-5" />
                                    </Button>
                                    <Button variant="ghost" size="icon" className="ml-auto hover:text-primary hover:bg-primary/10">
                                        <Copy className="w-5 h-5" />
                                    </Button>
                                </CardFooter>
                            </Card>
                        )
                    })}
                </div>
            </div>
        </section>
    )
}
