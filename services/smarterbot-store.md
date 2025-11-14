# smarterbot.store - E-commerce Frontend

## 📋 Overview

**smarterbot.store** es el storefront de SmarterOS basado en Shopify, implementado como una aplicación Next.js 15 que consume la Shopify Storefront API.

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
│   Shopify    │ │  Supabase    │ │   WhatsApp   │
│ Storefront   │ │  (Analytics) │ │  (Quick Buy) │
│     API      │ │              │ │              │
└──────────────┘ └──────────────┘ └──────────────┘
```

## 🎯 Funcionalidades

### Core Features
- ✅ Catálogo de productos desde Shopify
- ✅ Búsqueda y filtrado
- ✅ Carrito de compras (Shopify Cart API)
- ✅ Checkout integrado con Shopify
- ✅ Tracking de analytics (Supabase)
- ✅ Integración WhatsApp (compra rápida)

### Future Features
- ⏳ Multi-tenant (tiendas por cliente)
- ⏳ Recomendaciones IA
- ⏳ Chat en vivo (Chatwoot)
- ⏳ Personalización por usuario

## 🔧 Stack Tecnológico

### Frontend
- **Framework:** Next.js 15.2.4 (App Router)
- **Language:** TypeScript 5
- **Styling:** Tailwind CSS 3.4
- **UI Components:** Custom + Shopify Hydrogen React

### APIs
- **Shopify Storefront API:** GraphQL (2025-10)
- **Shopify Admin API:** REST (para webhooks)
- **Supabase:** Analytics tracking
- **WhatsApp Business API:** Quick checkout

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
│       ├── webhooks/           # Shopify webhooks
│       └── analytics/          # Tracking endpoints
├── components/
│   ├── header.tsx              # Navegación
│   ├── footer.tsx              # Footer
│   ├── product-card.tsx        # Tarjeta de producto
│   ├── cart-button.tsx         # Botón carrito
│   └── whatsapp-button.tsx     # Botón WhatsApp
├── lib/
│   ├── shopify.ts              # Cliente Shopify API
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

### Shopify
```env
SHOPIFY_STORE_URL=smarterbot.myshopify.com
SHOPIFY_STOREFRONT_ACCESS_TOKEN=# Public token
SHOPIFY_ADMIN_API_TOKEN=shpat_# Private token (server only)
SHOPIFY_API_VERSION=2025-10
```

### URLs
```env
NEXT_PUBLIC_SITE_URL=https://smarterbot.store
NEXT_PUBLIC_APP_URL=https://app.smarterbot.cl
```

### Supabase (opcional, para analytics)
```env
SUPABASE_URL=https://<project>.supabase.co
SUPABASE_SERVICE_KEY=# Service role key
```

### WhatsApp (opcional)
```env
WHATSAPP_API_URL=https://evolution.smarterbot.cl
WHATSAPP_TOKEN=# Bearer token
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

### Opción 1: Direct Shopify (Recomendado para Phase 1)
- Registros A apuntan a IPs de Shopify
- Shopify maneja SSL y hosting
- Este Next.js app actúa como proxy/extensión

### Opción 2: Custom Frontend (Phase 2+)
- Next.js desplegado en Vercel
- Consume Shopify como headless CMS
- Mayor control sobre UX

Script DNS disponible:
```bash
~/dev/2025/configure-shopify-dns.sh
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

Para soportar múltiples tenants (cada uno con su tienda Shopify):

### Approach 1: Subdominios
```
store.tenant-a.smarterbot.cl → Tienda Shopify A
store.tenant-b.smarterbot.cl → Tienda Shopify B
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
Shopify Order Created Webhook
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
Cliente envía mensaje WhatsApp
  │
  ▼
Chatwoot recibe mensaje
  │
  ▼
Botpress detecta intent "quiero comprar"
  │
  ▼
n8n workflow:
  ├─► Buscar productos en Shopify
  ├─► Enviar catálogo via WhatsApp
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
- `POST /api/webhooks/orders` - Shopify order webhooks
- `POST /api/webhooks/products` - Shopify product webhooks
- `POST /api/analytics/track` - Track custom event
- `GET /api/products` - Proxy to Shopify (with caching)

## 🧪 Testing

```bash
# Unit tests
pnpm test

# E2E tests (Playwright)
pnpm test:e2e

# Validate Shopify connection
curl https://smarterbot.store/api/health/shopify
```

## 📚 Referencias

- [Shopify Storefront API Docs](https://shopify.dev/docs/api/storefront)
- [Shopify Admin API Docs](https://shopify.dev/docs/api/admin)
- [Shopify Hydrogen (React components)](https://hydrogen.shopify.dev/)
- [Next.js 15 Docs](https://nextjs.org/docs)
- [SmarterOS Architecture](../smarteros-specs/ARCHITECTURE.md)

## 🗺️ Roadmap

### Phase 1 (Current - MVP)
- ✅ Estructura básica Next.js + Shopify
- ✅ Catálogo de productos
- ✅ Carrito + Checkout
- ✅ Analytics básico

### Phase 2 (Q1 2026)
- ⏳ Multi-tenant support
- ⏳ Recomendaciones IA
- ⏳ Chat en vivo (Chatwoot)
- ⏳ Integración completa WhatsApp

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
