# SmarterOS - Operating System Snapshot
**Version:** 1.2.0  
**Date:** 2025-11-23  
**Purpose:** Complete system state documentation for reproducibility

---

## 🎯 System Overview

**SmarterOS** is a containerized business automation operating system built on:
- **Docker** for service isolation
- **Dokploy** for deployment orchestration
- **Caddy** for reverse proxy & SSL
- **Supabase** for data persistence
- **MCP (Model Context Protocol)** for AI agent integration

---

## 🐳 Container Inventory

### **Production Services**

| Container | Image | Port(s) | Purpose | Status |
|-----------|-------|---------|---------|--------|
| `smartapi` | `api.smarterbot.cl:latest` | 8001→8000 | Unified REST API (FastAPI) | ✅ Running |
| `postgres` | `postgres:15` | 5432 | PostgreSQL database | ✅ Running |
| `redis` | `redis:7` | 6379 | Cache & sessions | ✅ Running |
| `odoo` | `odoo:19` | 8069 | ERP/CRM system | ✅ Running |
| `caddy` | `caddy:2.7` | 80, 443 | Reverse proxy & SSL | ✅ Running |
| `n8n` | `n8nio/n8n:1.75` | 5678 | Workflow automation | ✅ Running |
| `chatwoot` | `chatwoot/chatwoot:latest` | 3000 | Conversational CRM | 🟡 Planned |
| `vault` | `vault:1.15` | 8200 | Secret management | 🟡 Planned |

### **Development/Lab Services**

| Container | Image | Port(s) | Purpose | Status |
|-----------|-------|---------|---------|--------|
| `smarterbolt-lab` | Custom (Python 3.12) | - | Bolt doc generator | 🔵 Pending |

---

## 🌐 Domain Routing

### **Production Domains**

```
smarterbot.cl           → Caddy → app.smarterbot.cl (Next.js)
api.smarterbot.cl       → Caddy → smartapi:8000
odoo.smarterbot.cl      → Caddy → odoo:8069
n8n.smarterbot.cl       → Caddy → n8n:5678
chatwoot.smarterbot.cl  → Caddy → chatwoot:3000 (planned)
vault.smarterbot.cl     → Caddy → vault:8200 (planned)
```

### **Caddyfile Configuration**

Located at: `/etc/caddy/Caddyfile`

```caddy
api.smarterbot.cl {
    reverse_proxy smartapi:8000
}

odoo.smarterbot.cl {
    reverse_proxy odoo:8069
}

n8n.smarterbot.cl {
    reverse_proxy n8n:5678
}
```

---

## 📁 Directory Structure

### **VPS Layout** (`/root/`)

```
/root/
├── smarteros/                    # Main OS repository
│   ├── docker/                   # Dockerfiles
│   │   ├── BoltLab.Dockerfile
│   │   └── api.Dockerfile
│   ├── specs/                    # System specifications
│   │   ├── versions.lock
│   │   ├── os.md (this file)
│   │   └── BRANDING.md
│   ├── scripts/                  # Automation scripts
│   │   ├── birth_of_bolt.py
│   │   ├── install.sh
│   │   └── restore.sh
│   ├── docker-compose.yml        # Main services
│   └── smarterbolt-lab.yml       # Bolt Lab container
│
├── api.smarterbot.cl/            # FastAPI backend
│   ├── main.py
│   ├── routers/
│   │   ├── odoo.py
│   │   ├── supabase.py
│   │   ├── n8n.py
│   │   └── chatwoot.py
│   ├── odoo_client.py
│   └── requirements.txt
│
├── app.smarterbot.cl/            # Next.js frontend
├── smarterbot.store/             # Marketplace (planned)
└── dkcompose/                    # Docker compose templates
```

---

## 🗄️ Database Schema

### **PostgreSQL (Odoo)**

- **Host:** `postgres:5432`
- **Database:** `smarterbot`
- **User:** `odoo`
- **Models:** `res.partner`, `sale.order`, `account.move`, etc.

### **Supabase (Production)**

- **URL:** `https://[project].supabase.co`
- **Tables:**
  - `contacts` - Contact form submissions
  - `accounting_events` - Ledger events (planned)
  - `payments_intents` - Payment tracking (planned)
  - `payment_webhooks` - Webhook logs (planned)
  - `reconciliations` - Payment-invoice mapping (planned)

### **Redis (Cache)**

- **Host:** `redis:6379`
- **Usage:** Session storage, rate limiting, cache

---

## 🔌 API Endpoints

### **Unified API** (`api.smarterbot.cl`)

**Version:** 1.2.0

**Categories:**
- `core`: `/`, `/health`, `/contact`, `/contacts`, `/registry.json`
- `odoo`: `/odoo/search_read`, `/odoo/create`, `/odoo/write`, `/odoo/unlink`, `/odoo/call`
- `supabase`: `/supabase/query`, `/supabase/insert`, `/supabase/update`, `/supabase/delete`
- `n8n`: `/n8n/workflows`, `/n8n/executions`, `/n8n/health`
- `chatwoot`: `/chatwoot/contacts`, `/chatwoot/conversations`, `/chatwoot/messages`

**MCP Registry:**
```
GET /registry.json
```
Returns auto-generated tool catalog with 28 tools across 5 categories.

---

## 🔐 Secrets Management

### **Environment Variables** (`.env.production`)

```bash
# Supabase
SUPABASE_URL=https://xxx.supabase.co
SUPABASE_SERVICE_ROLE=eyJ...

# Odoo
ODOO_URL=https://odoo.smarterbot.cl
ODOO_DB=smarterbot
ODOO_API_KEY=***

# n8n
N8N_BASE_URL=https://n8n.smarterbot.cl
N8N_API_KEY=***

# Chatwoot
CHATWOOT_BASE_URL=https://chatwoot.smarterbot.cl
CHATWOOT_TOKEN=***
CHATWOOT_ACCOUNT_ID=1
CHATWOOT_INBOX_ID=1

# Email (Resend)
RESEND_API_KEY=re_***
RESEND_FROM=no-reply@smarterbot.cl
ADMIN_EMAIL=smarterbotcl@gmail.com

# MCP
ENABLE_MCP=true
```

### **Vault Storage** (Planned)

- Path: `/vault/smarteros/`
- KV version: 2
- Access: OIDC auth via Supabase

---

## 🚀 Deployment Process

### **Current Manual Process**

1. SSH into VPS
2. Pull latest code: `git pull origin main`
3. Rebuild containers: `docker compose up -d --build`
4. Verify: `curl https://api.smarterbot.cl/health`

### **Planned Automated Process** (`install.sh`)

1. Install Docker + Dokploy
2. Clone repository
3. Load secrets from Vault
4. Deploy all services
5. Configure Caddy
6. Run health checks
7. Print dashboard URLs

---

## 🔄 Backup & Restore

### **What Gets Backed Up**

1. **Configuration Files:**
   - `docker-compose.yml`
   - `.env.production`
   - `Caddyfile`

2. **Database Snapshots:**
   - PostgreSQL dump: `pg_dump smarterbot`
   - Supabase schema export

3. **Application Code:**
   - Git commit hash reference
   - Custom scripts

4. **Vault Secrets:**
   - Encrypted export

### **Restore Process** (`restore.sh`)

```bash
# Stop all services
docker compose down

# Restore database
psql < backup/smarterbot.sql

# Restore configs
cp backup/.env.production .env.production

# Restart services
docker compose up -d

# Verify
curl https://api.smarterbot.cl/health
```

---

## 📊 Monitoring & Health

### **Health Check Endpoints**

- `https://api.smarterbot.cl/health` - API status
- `https://n8n.smarterbot.cl/health` - n8n status
- `https://odoo.smarterbot.cl/web/health` - Odoo status

### **Expected Health Response**

```json
{
  "status": "healthy",
  "supabase": "configured",
  "resend": "configured",
  "chatwoot": "configured",
  "n8n": "configured"
}
```

### **Observability Stack** (Planned)

- **Grafana** - Dashboards
- **Prometheus** - Metrics
- **Loki** - Logs
- **Jaeger** - Tracing

---

## 🧩 MCP Integration

### **fastapi-mcp Mount**

- **Endpoint:** `/mcp`
- **Auto-tools:** Enabled (all routers exposed)
- **Registry:** `/registry.json`

### **Tool Categories**

```json
{
  "odoo": 5,
  "supabase": 5,
  "n8n": 6,
  "chatwoot": 7,
  "core": 5
}
```

### **Usage Example**

```python
# AI agent can call:
result = mcp.call_tool("odoo.search_read", {
    "model": "res.partner",
    "domain": [["is_company", "=", true]],
    "fields": ["name", "email"],
    "limit": 10
})
```

---

## 🔧 Maintenance Commands

### **Docker Operations**

```bash
# View running containers
docker ps

# View logs
docker logs smartapi -f

# Restart service
docker restart smartapi

# Rebuild and restart
docker compose up -d --build smartapi

# Clean up
docker system prune -af
```

### **Database Operations**

```bash
# Connect to PostgreSQL
docker exec -it postgres psql -U odoo -d smarterbot

# Backup database
docker exec postgres pg_dump -U odoo smarterbot > backup.sql

# Restore database
cat backup.sql | docker exec -i postgres psql -U odoo -d smarterbot
```

### **API Operations**

```bash
# Check API health
curl https://api.smarterbot.cl/health

# View registry
curl https://api.smarterbot.cl/registry.json | jq

# Test endpoint
curl -X POST https://api.smarterbot.cl/odoo/search_read \
  -H "Content-Type: application/json" \
  -d '{"model": "res.partner", "limit": 5}'
```

---

## 🎯 System Requirements

### **Minimum VPS Specs**

- **CPU:** 2 vCPU
- **RAM:** 4 GB
- **Storage:** 50 GB SSD
- **OS:** Ubuntu 22.04 LTS
- **Docker:** 26.1.0+
- **Docker Compose:** 2.24.0+

### **Recommended VPS Specs**

- **CPU:** 4 vCPU
- **RAM:** 8 GB
- **Storage:** 100 GB SSD
- **Bandwidth:** 2 TB/month

---

## 🌍 Multi-Country Deployment

### **Regional Variations**

Each country-specific installation (`smarterbot.com.ar`, `.com.pe`, etc.) runs:
- **Same Docker images** (pulled from HQ registry)
- **Same MCP tools** (standardized API)
- **Localized content** (translations, tax modules)
- **Regional payment gateways** (local integrations)

### **Shared Infrastructure**

- **Marketplace:** Single `smarterbot.store` for all countries
- **MCP Registry:** Centralized tool catalog
- **Updates:** Push once, deploy everywhere

---

## 📝 Change Log

### **v1.2.0** (2025-11-23)
- ✅ Added supabase, n8n, chatwoot routers
- ✅ Enhanced `/registry.json` with categories
- ✅ Professional README
- ✅ Enhanced root endpoint metadata

### **v1.1.0** (2025-11-20)
- ✅ Odoo router + client
- ✅ MCP integration (fastapi-mcp)
- ✅ Registry endpoint

### **v1.0.0** (2025-11-15)
- ✅ Initial FastAPI setup
- ✅ Contact form endpoints
- ✅ Supabase integration

---

## 🚧 Pending Tasks

1. **Bolt Lab Container** - Doc generator service
2. **install.sh** - One-click OS installer
3. **restore.sh** - One-click system restore
4. **Accounting Router** - MCP accounting motor
5. **Payments Router** - Multi-gateway payment orchestration
6. **Monitoring Stack** - Grafana + Prometheus
7. **CI/CD Pipeline** - GitHub Actions
8. **Unit Tests** - pytest coverage

---

## 📞 Support

- **Documentation:** https://smarterbot.cl/docs
- **API Reference:** https://api.smarterbot.cl/docs
- **MCP Registry:** https://api.smarterbot.cl/registry.json
- **Email:** soporte@smarterbot.cl
- **Status Page:** https://status.smarterbot.cl (planned)

---

**Last Updated:** 2025-11-23  
**Maintained By:** SmarterOS Team  
**License:** Proprietary
