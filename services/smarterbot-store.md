# smarterbot.store - E-commerce Frontend

## 📋 Overview

**smarterbot.store** ahora es un frontend headless apoyado en Chatwoot (engagement), Botpress (conversación/automatización) y Odoo/Supabase (productos + datos), eliminando dependencia de Shopify y WhatsApp.

## 🏗️ Arquitectura

```
┌─────────────────────────────────────────────────────────┐
│                  smarterbot.store                       │
│                  (Next.js 15 + TS)                      │
└─────────────────────────────────────────────────────────┘
                        │
        ┌───────────────┼───────────────┐
        │               │               │
        ▼               ▼               ▼
┌──────────────┐ ┌──────────────┐ ┌──────────────┐
│  Chatwoot    │ │  Supabase    │ │  Botpress    │
│ Storefront   │ │  (Analytics) │ │  (Quick Buy) │
│     API      │ │              │ │              │
└──────────────┘ └──────────────┘ └──────────────┘
```

## 🎯 Funcionalidades

### Core Features
- ✅ Catálogo de productos (Odoo → Supabase cache)
- ✅ Búsqueda y filtrado
- ✅ Carrito (custom / Odoo integration futura)
- ✅ Tracking analytics (Supabase)
- ✅ Soporte y contacto (Chatwoot)
- ✅ Automatización conversacional (Botpress)

### Future Features
- ⏳ Multi-tenant (inbox/bot por cliente)
- ⏳ Recomendaciones IA
- ⏳ Personalización por usuario
- ⏳ Integraciones avanzadas Odoo

## 🔧 Stack Tecnológico

### Frontend
- **Framework:** Next.js 15.2.4 (App Router)
- **Language:** TypeScript 5
- **Styling:** Tailwind CSS 3.4
**UI Components:** Custom + Design System interno

### APIs
**Chatwoot API:** Conversaciones, mensajes
**Botpress API:** Intents, workflows
**Supabase:** Analytics + cache catálogo

### Hosting
- **Production:** Dokploy (Docker Compose en VPS)
- **Domain:** smarterbot.store (Cloudflare DNS)
- **SSL:** Traefik/Let's Encrypt gestionado por Dokploy

## 📁 Estructura del Proyecto

```
front/store.smarterbot.cl/
├── app/
│   ├── layout.tsx              # Layout principal
│   ├── page.tsx                # Home page
│   ├── globals.css             # Estilos globales
│   ├── products/
│   │   ├── page.tsx            # Listado de productos
│   │   └── [handle]/
│   │       └── page.tsx        # Detalle de producto
│   ├── cart/
│   │   └── page.tsx            # Carrito de compras
│   └── api/
│       ├── webhooks/           # Eventos Chatwoot/Botpress
│       └── analytics/          # Tracking endpoints
├── components/
│   ├── header.tsx              # Navegación
│   ├── footer.tsx              # Footer
│   ├── product-card.tsx        # Tarjeta de producto
│   ├── cart-button.tsx         # Botón carrito
│   └── chatwoot-widget.tsx     # Widget Chatwoot
│   └── botpress-widget.tsx     # Widget Botpress
├── lib/
│   ├── chatwoot.ts             # Cliente Chatwoot API
│   ├── botpress.ts             # Cliente Botpress API
│   ├── supabase.ts             # Cliente Supabase
│   └── utils.ts                # Utilidades
├── public/
│   ├── images/
│   └── favicon.ico
├── .env.example                # Template variables
├── next.config.mjs             # Config Next.js
├── tailwind.config.ts          # Config Tailwind
├── tsconfig.json               # Config TypeScript
└── package.json                # Dependencies
```

## 🔐 Variables de Entorno

### Chatwoot
```env
CHATWOOT_BASE_URL=https://chatwoot.smarterbot.cl
CHATWOOT_TOKEN=pk_xxxxxxxxx
CHATWOOT_INBOX_ID=1
```

### URLs
```env
NEXT_PUBLIC_SITE_URL=https://smarterbot.store
NEXT_PUBLIC_APP_URL=https://app.smarterbot.cl
```

### Supabase (analytics / catálogo cache)
```env
SUPABASE_URL=https://<project>.supabase.co
SUPABASE_SERVICE_KEY=# Service role key
```

### Botpress
```env
BOTPRESS_URL=https://botpress.smarterbot.cl
BOTPRESS_API_KEY=bp_xxxxxxxxx
BOTPRESS_BOT_ID=leadbot
```

## 🚀 Deployment

### Local Development
```bash
cd front/store.smarterbot.cl
pnpm install
cp .env.example .env.local
# Editar .env.local con tokens reales
pnpm dev
```

### Production (Dokploy)
Ubicación del stack:
`infra/dokploy/store.smarterbot.cl/`

1) Preparar entorno en VPS (Dokploy ya instalado)
```bash
cd ~/dev/2025/infra/dokploy/store.smarterbot.cl
cp .env.template .env
# Editar .env con credenciales reales
```

2) Levantar stack
```bash
docker network create smarteros_net || true
docker compose --env-file .env up -d --build
```

3) Exponer en Traefik (si aplica) y configurar DNS en Cloudflare a la IP del VPS

## 🌐 DNS Configuration

El dominio `smarterbot.store` puede configurarse de dos formas:

### Opción: Infra propia
- Traefik/Caddy gestionan SSL
- Subdominios por tenant (inbox/bot)
- Control total sobre caching y orquestación

### Evolución
- Integrar pricing / stock desde Odoo directo
- Enriquecer intent detection con embeddings

Script DNS disponible:
```bash
~/dev/2025/configure-chatwoot-dns.sh
```

## 🔄 Shopify Integration

### APIs Utilizadas

#### Storefront API (GraphQL)
- **Endpoint:** `https://{store}.myshopify.com/api/{version}/graphql.json`
- **Token:** Storefront Access Token (público)
- **Uso:** Consultas de productos, colecciones, carrito

**Ejemplo:**
```graphql
query GetProducts($first: Int!) {
  products(first: $first) {
    edges {
      node {
        id
        title
        priceRange {
          minVariantPrice {
            amount
            currencyCode
          }
        }
      }
    }
  }
}
```

#### Admin API (REST)
- **Endpoint:** `https://{store}.myshopify.com/admin/api/{version}/`
- **Token:** Admin API Token (privado, server-only)
- **Uso:** Webhooks, orders, inventory management

### Webhooks

Configurar en Shopify Admin:

| Event | Endpoint | Descripción |
|-------|----------|-------------|
| `orders/create` | `/api/webhooks/orders` | Nueva orden |
| `orders/paid` | `/api/webhooks/orders` | Orden pagada |
| `products/create` | `/api/webhooks/products` | Nuevo producto |
| `products/update` | `/api/webhooks/products` | Producto actualizado |

**Webhook URL base:** `https://smarterbot.store/api/webhooks`

## 📊 Analytics & Tracking

### Eventos Rastreados (Supabase)

```sql
-- Tabla: analytics_events
CREATE TABLE analytics_events (
  id BIGSERIAL PRIMARY KEY,
  event_type TEXT NOT NULL, -- page_view, product_view, add_to_cart, checkout
  path TEXT NOT NULL,
  metadata JSONB, -- {product_id, utm_*, etc}
  ip INET,
  user_agent TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);
```

### Eventos:
- `page_view` - Vista de página
- `product_view` - Vista de producto
- `add_to_cart` - Agregar al carrito
- `checkout_start` - Iniciar checkout
- `order_complete` - Orden completada

## 🛒 Multi-tenant Strategy

Para soportar múltiples tenants (cada uno con su inbox / bot):

### Approach 1: Subdominios
```
inbox.tenant-a.smarterbot.cl → Chatwoot Inbox A
bot.tenant-b.smarterbot.cl → Botpress Bot B
```

### Approach 2: Query Parameter
```
smarterbot.store?tenant=tenant-a
```

### Approach 3: Separate Deployments
```
tenant-a.store.smarterbot.cl (Vercel deployment A)
tenant-b.store.smarterbot.cl (Vercel deployment B)
```

**Recomendación:** Empezar con single tenant (smarterbot.store), luego evolucionar a multi-tenant en Phase 2.

## 🔗 Integración con SmarterOS

### Flujos Automatizados (n8n)

#### Flujo: Nueva Orden
```
Chatwoot Conversation Created Event
  │
  ▼
n8n recibe webhook
  │
  ├─► Crear cliente en Odoo
  ├─► Generar factura (SII via n8n)
  ├─► Notificar WhatsApp
  └─► Actualizar analytics (Supabase)
```

#### Flujo: Compra por WhatsApp
```
Cliente inicia conversación en widget (Chatwoot/Botpress)
  │
  ▼
Chatwoot recibe mensaje
  │
  ▼
Botpress detecta intent "quiero comprar"
  │
  ▼
n8n workflow:
  ├─► Buscar productos en Odoo
  ├─► Botpress genera respuesta estructurada
  ├─► Generar link de pago
  └─► Track en Supabase
```

## 📝 API Routes

### Public Routes
- `GET /` - Home page
- `GET /products` - Catálogo
- `GET /products/[handle]` - Detalle producto
- `GET /cart` - Carrito

### API Routes (Server-side)
- `POST /api/events/chatwoot` - Webhook Chatwoot
- `POST /api/intents` - Botpress intent proxy
- `POST /api/analytics/track` - Track custom event
- `GET /api/products` - Productos (Odoo/Supabase)

## 🧪 Testing

```bash
# Unit tests
pnpm test

# E2E tests (Playwright)
pnpm test:e2e

# Validate Chatwoot connection
curl https://smarterbot.store/api/health/chatwoot
```

## 📚 Referencias

- [Chatwoot API Docs](https://www.chatwoot.com/developers/api)
- [Botpress Cloud Docs](https://botpress.com/docs)
- [Next.js 15 Docs](https://nextjs.org/docs)
- [SmarterOS Architecture](../smarteros-specs/ARCHITECTURE.md)

## 🗺️ Roadmap

### Phase 1 (Current - MVP)
- ✅ Migración inicial a Chatwoot/Botpress/Odoo/Supabase
- ✅ Catálogo base
- ✅ Analytics básico

### Phase 2 (Q1 2026)
- ⏳ Multi-tenant completo
- ⏳ Recomendaciones IA
- ⏳ Mejora intents Botpress
- ⏳ Orquestación avanzada n8n

### Phase 3 (Q2 2026)
- ⏳ Marketplace de skills/templates
- ⏳ Subscription products
- ⏳ Afiliados
- ⏳ Internacionalización

## 👥 Team

- **Owner:** SmarterOS Team
- **Maintainer:** Pedro
- **Repo:** `/Users/mac/dev/2025/front/store.smarterbot.cl`

---

**Última actualización:** 14 Noviembre 2025  
**Versión:** 1.0.0-MVP
