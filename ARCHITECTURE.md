# 🏗️ SmarterOS - Architecture Documentation

## 🎯 Overview

SmarterOS is a **multi-tenant cognitive operating system** for Chilean SMBs, built on a microservices architecture with SSO, multi-agent AI, and RUT-based isolation.

---

## 📊 High-Level Architecture

```
┌─────────────────────────────────────────────────┐
│              Internet Users                      │
└────────────────┬────────────────────────────────┘
                 │
    ┌────────────┴─────────────┐
    │                          │
┌───▼─────────┐        ┌──────▼────────┐
│  Cloudflare │        │    Vercel     │
│    (WAF)    │        │  (Frontend)   │
└───┬─────────┘        └──────┬────────┘
    │                         │
┌───▼─────────────────────────▼────────┐
│         Caddy Reverse Proxy          │
│         (SSL/TLS Termination)        │
└───┬──────────────────────────────────┘
    │
┌───▼──────────────────────────────────┐
│       API Gateway (FastAPI)          │
│   - JWT Verification                 │
│   - Rate Limiting                    │
│   - Tenant Resolution                │
└───┬──────────────────────────────────┘
    │
    ├──────────┬──────────┬──────────┬──────────┐
    │          │          │          │          │
┌───▼───┐  ┌──▼───┐  ┌──▼───┐  ┌──▼───┐  ┌──▼───┐
│ Odoo  │  │ n8n  │  │Chat │  │Bot  │  │ KPI  │
│ ERP   │  │Auto │  │woot │  │press│  │Base │
└───┬───┘  └──┬───┘  └──┬───┘  └──┬───┘  └──┬───┘
    │         │         │         │         │
    └─────────┴─────────┴─────────┴─────────┘
                        │
            ┌───────────▼────────────┐
            │   Data Layer           │
            ├────────────────────────┤
            │ PostgreSQL (Odoo)      │
            │ Supabase (Multi-tenant)│
            │ Redis (Cache)          │
            │ S3 (Files)             │
            └────────────────────────┘
```

---

## 🧩 Component Details

### Frontend Layer (Vercel)

#### 1. Landing Page
- **URL:** `smarterbot.cl`
- **Tech:** Static HTML + Tailwind
- **Purpose:** Marketing, pricing, CTA

#### 2. Portal Maestro
- **URL:** `app.smarterbot.cl`
- **Tech:** Next.js 14 + Clerk
- **Features:**
  - Dashboard with 7 modules
  - SSO integration
  - Multi-tenant routing
  - Responsive design

#### 3. CRM Frontend
- **URL:** `crm.smarterbot.cl`
- **Tech:** Next.js 14
- **Features:**
  - Contact management
  - Sales pipeline
  - Reports

#### 4. Marketing Center
- **URL:** `mkt.smarterbot.cl`
- **Tech:** Next.js 14 + Recharts
- **Features:**
  - Campaign management
  - Lead capture
  - Analytics

---

### Backend Layer (VPS)

#### 1. API Gateway
- **Tech:** FastAPI 0.104+
- **Port:** 8001
- **Functions:**
  - JWT verification (Clerk)
  - Tenant resolution (RUT)
  - Rate limiting
  - Request routing
  - Audit logging (MCP)

#### 2. ERP (Odoo)
- **Version:** 19.0
- **Port:** 8069
- **Database:** PostgreSQL 16
- **Features:**
  - Multi-company (tenant isolation)
  - Custom theme (GitHub Actions)
  - Auth addon (Clerk SSO)
  - E-commerce module

#### 3. Automatizaciones (n8n)
- **Version:** Latest
- **Port:** 5678
- **Features:**
  - Visual workflows
  - Multi-tenant credentials
  - Webhook management
  - 200+ integrations

#### 4. Chat (Chatwoot)
- **Version:** Latest
- **Port:** 3000
- **Features:**
  - Omnichannel inbox
  - WhatsApp / Email / Web
  - Agent roles
  - Bot integration

#### 5. Bot IA (Botpress)
- **Version:** Latest
- **Port:** 3100
- **Features:**
  - NLP engine
  - Contextual responses
  - Lead qualification
  - Human handoff

#### 6. KPI (Metabase)
- **Version:** Latest
- **Port:** 3030
- **Features:**
  - JWT embedding
  - Multi-tenant filtering
  - Custom dashboards
  - Supabase connector

---

## 🔐 Security Architecture

### Authentication Flow

```
User → Portal
  ↓
Clerk OAuth
  ↓
JWT Token
  ↓
API Gateway (verify)
  ↓
Tenant Resolution (RUT)
  ↓
Service (Odoo/CRM/etc)
  ↓
Auto-login (if SSO)
```

### Multi-Tenant Isolation

```sql
-- Supabase RLS
CREATE POLICY "Users can only see their tenant data"
ON public.users
FOR SELECT
USING (tenant_id = current_setting('app.tenant_id')::uuid);

-- Odoo Multi-Company
SELECT * FROM res_partner
WHERE company_id = %s;
```

---

## 📡 Data Flow

### Example: New Lead Capture

```
1. User fills form on mkt.smarterbot.cl
2. POST to API Gateway (/leads/create)
3. API Gateway:
   - Verifies JWT
   - Resolves tenant_id from RUT
   - Rate limit check
4. Stores in Supabase (leads table)
5. Triggers n8n workflow via webhook
6. n8n:
   - Enriches lead data (LinkedIn, etc)
   - Creates contact in Odoo CRM
   - Sends WhatsApp via Chatwoot
   - Starts Bot conversation (Botpress)
7. Updates dashboard in Metabase
8. Portal shows notification
```

---

## 🔄 Deployment Architecture

### CI/CD Pipeline

```
GitHub Push
  ↓
GitHub Actions
  ├─ Lint & Test
  ├─ Build Docker Image
  ├─ Push to Registry
  └─ Deploy to VPS (Vercel for Frontend)
```

### Infrastructure as Code

```yaml
# docker-compose.yml (simplified)
services:
  odoo:
    image: smarteros/odoo:latest
    environment:
      - TENANT_ID=${TENANT_ID}
    networks:
      - smarteros-network
  
  api-gateway:
    image: smarteros/api:latest
    depends_on:
      - odoo
    networks:
      - smarteros-network
```

---

## 📊 Scalability

### Horizontal Scaling

```
Load Balancer (Caddy)
  ├─ Odoo Instance 1
  ├─ Odoo Instance 2
  └─ Odoo Instance 3

Database (PostgreSQL)
  ├─ Master (Write)
  └─ Replica (Read)
```

### Caching Strategy

```
Redis Cache
├─ Session data (TTL 30min)
├─ API responses (TTL 5min)
└─ Tenant configs (TTL 1h)
```

---

## 🔍 Monitoring & Observability

### Metrics (MCP Tools)

```
- API response time
- Database query time
- Active sessions
- Error rate
- Tenant usage
- Webhook success rate
```

### Logging

```
Format: JSON
Destination: Supabase + CloudWatch
Retention: 90 days
```

---

## 📈 Performance Targets

```
- API Response: < 200ms (p95)
- Page Load: < 2s (p95)
- Uptime: > 99.9%
- Database Queries: < 100ms (p95)
```

---

## 🚀 Future Architecture (2026)

```
+ Mobile App (React Native)
+ Edge Computing (Cloudflare Workers)
+ ML Pipeline (Model serving)
+ Event Streaming (Kafka)
+ Search Engine (Elasticsearch)
```

---

**Version:** 1.0  
**Last Updated:** 2025-11-23  
**Maintainer:** SmarterCL Engineering
