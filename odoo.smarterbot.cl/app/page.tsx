import { Header } from "@/components/header"
import { HeroSection } from "@/components/hero-section"
import { PlatformSection } from "@/components/platform-section"
import { PricingSection } from "@/components/pricing-section"
import { TransformSection } from "@/components/transform-section"
import { StatsSection } from "@/components/stats-section"
import { VerticalsSection } from "@/components/verticals-section"
import { TestimonialsSection } from "@/components/testimonials-section"
import { ContactSection } from "@/components/contact-section"
import { Footer } from "@/components/footer"

export default function HomePage() {
  return (
    <main className="min-h-screen bg-background">
      <Header />
      <HeroSection />
      <PlatformSection />
      <PricingSection />
      <TransformSection />
      <StatsSection />
      <VerticalsSection />
      <TestimonialsSection />
      <ContactSection />
      <Footer />
    </main>
  )
}
