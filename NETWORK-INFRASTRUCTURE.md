# SmarterOS Network Infrastructure

## Domain Mapping

### Production Domains (.cl)

| Domain | Container | Port | Purpose |
|--------|-----------|------|---------|
| mkt.smarterbot.cl | smarteros-blogbowl | 3000 | Marketing Site |
| api.smarterbot.cl | n8n | 5678 | N8N Automation |
| kpi.smarterbot.cl | metabase | 3001 | Analytics Dashboard |
| ai.smarterbot.cl | nexa-runtime | 8080 | AI Runtime |
| dash.smarterbot.cl | dokploy | 3000 | Platform Admin |

### Hostinger Domains (.store)

| Domain | Container | Port | Purpose |
|--------|-----------|------|---------|
| mkt.smarterbot.store | smarteros-blogbowl | 3000 | Marketing Site (alt) |
| ai.smarterbot.store | nexa-runtime | 8080 | AI Runtime (alt) |
| dokploy.smarterbot.store | dokploy | 3000 | Platform Admin (alt) |

## DNS Configuration

All domains point to: `89.116.23.167`

### DNS Records Type
- **A Records**: All domains configured as A records pointing to VPS IP
- **SSL/TLS**: Handled by Caddy (automatic HTTPS)

## Network Architecture

```
Internet (Port 443/80)
         ↓
    Caddy Proxy
         ↓
   smarter-net (Docker Network)
         ↓
    ┌─────────────────────┐
    │   Service Mesh      │
    ├─────────────────────┤
    │ • mkt (3000)       │
    │ • n8n (5678)       │
    │ • metabase (3001)  │
    │ • nexa (8080)      │
    │ • dokploy (3000)   │
    └─────────────────────┘
```

## Container Network

### Network Name
`smarter-net` (external, bridge mode)

### Active Services

1. **caddy-proxy** - Reverse proxy with automatic HTTPS
2. **smarteros-blogbowl** - Next.js marketing site
3. **n8n** - Automation platform
4. **metabase** - Analytics
5. **nexa-runtime** - AI engine (future)
6. **dokploy** - Platform management

## Ports Mapping

### External (Host → Container)
- 80:80 - HTTP (Caddy)
- 443:443 - HTTPS (Caddy)
- 3002:3000 - Direct access to mkt (optional)

### Internal (Container ← → Container)
All services communicate via service names on `smarter-net`

## SSL/TLS

- **Provider**: Let's Encrypt (via Caddy)
- **Auto-renewal**: Yes
- **Certificate storage**: `/root/letsencrypt/`
- **Supported protocols**: TLS 1.2, TLS 1.3

## Firewall Rules (Hostinger)

Recommended configuration:
- Allow: 80/tcp (HTTP)
- Allow: 443/tcp (HTTPS)
- Allow: 22/tcp (SSH - restricted)
- Deny: All other incoming

## Health Checks

Each service implements health checks:
- mkt: `GET /`
- n8n: `GET /healthz`
- metabase: `GET /api/health`
- nexa: `GET /health`

## Load Balancing

Current: Single-node deployment
Future: Can be scaled with Docker Swarm or Kubernetes

---

Last updated: 2025-11-18
Infrastructure version: v0.3.1
