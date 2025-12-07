"use client"

import { Header } from "@/components/header"
import { Footer } from "@/components/footer"
import { ContactSection } from "@/components/contact-section"
import PricingHero from "@/components/pricing/pricing-hero"
import PricingCards from "@/components/pricing/pricing-cards"
import PricingComparison from "@/components/pricing/pricing-comparison"

export default function PricingClient() {
  return (
    <main className="min-h-screen bg-background">
      <Header />
      <PricingHero />
      <PricingCards />
      <PricingComparison />
      <ContactSection />
      <Footer />
    </main>
  )
}
