# SmarterOS Infrastructure Inventory
**Generated:** 2025-11-18T20:59:31Z  
**Server:** 89.116.23.167 (Hostinger VPS)  
**DNS Zones:** smarterbot.cl, smarterbot.store

---

## 🌐 DNS Records (Active)

### smarterbot.cl (Primary Domain)
| Subdomain | Type | Target | Service |
|-----------|------|--------|---------|
| kpi | A | 89.116.23.167 | Metabase Dashboard |
| chatwoot | A | 89.116.23.167 | Customer Support |
| chat | A | 89.116.23.167 | Botpress Chat |
| n8n | A | 89.116.23.167 | Workflow Automation |
| odoo | A | 89.116.23.167 | ERP System |
| portainer | A | 89.116.23.167 | Container Management |
| dokploy | A | 89.116.23.167 | Deployment Platform |
| mkt | A | 89.116.23.167 | Marketing Platform (BlogBowl) |

### smarterbot.store (Hostinger Domain)
| Subdomain | Type | Target | Service |
|-----------|------|--------|---------|
| dokploy | A | 89.116.23.167 | Deployment Platform |
| ai | A | 89.116.23.167 | Nexa AI Server |
| mkt | A | 89.116.23.167 | Marketing Platform (BlogBowl) |

---

## 🐳 Docker Infrastructure

### Network Architecture
```
smarter-net (bridge)
├── caddy-proxy (80, 443)
├── smarteros-metabase
├── smarter-chatwoot
├── smarter-botpress
├── smarter-n8n
├── smarter-odoo
├── smarter-portainer
├── dokploy
├── nexa-server
└── smarteros-blogbowl
```

### Active Containers

#### Reverse Proxy
- **Container:** `caddy-proxy`
- **Image:** caddy:2-alpine
- **Ports:** 80, 443 (TCP/UDP)
- **Network:** smarter-net
- **Config:** /root/Caddyfile
- **Logs:** /var/log/caddy/

#### Metabase (KPI Dashboard)
- **Container:** `smarteros-metabase`
- **Domain:** kpi.smarterbot.cl
- **Port:** 3000 (internal)
- **Purpose:** Business Intelligence & Dashboards

#### Chatwoot (Customer Support)
- **Container:** `smarter-chatwoot`
- **Domain:** chatwoot.smarterbot.cl
- **Port:** 3000 (internal)
- **Purpose:** Multi-tenant Customer Support

#### Botpress (Chat Bot)
- **Container:** `smarter-botpress`
- **Domain:** chat.smarterbot.cl
- **Port:** 3000 (internal)
- **Purpose:** Conversational AI Platform

#### n8n (Workflow Automation)
- **Container:** `smarter-n8n`
- **Domain:** n8n.smarterbot.cl
- **Port:** 5678 (internal)
- **Purpose:** Workflow Automation & Integration

#### Odoo (ERP)
- **Container:** `smarter-odoo`
- **Domain:** odoo.smarterbot.cl
- **Port:** 8069 (internal)
- **Purpose:** Enterprise Resource Planning

#### Portainer (Container Management)
- **Container:** `smarter-portainer`
- **Domain:** portainer.smarterbot.cl
- **Port:** 9000 (internal)
- **Purpose:** Docker Management UI

#### Dokploy (Deployment Platform)
- **Container:** `dokploy`
- **Domains:** dokploy.smarterbot.cl, dokploy.smarterbot.store
- **Port:** 3000 (internal)
- **Purpose:** Git-based Deployment Platform

#### Nexa AI Server
- **Container:** `nexa-server`
- **Domain:** ai.smarterbot.store
- **Port:** 8000 (internal)
- **Purpose:** Local AI Runtime (Multi-tenant)

#### BlogBowl (Marketing Platform)
- **Container:** `smarteros-blogbowl`
- **Domains:** mkt.smarterbot.cl, mkt.smarterbot.store
- **Port:** 3000 (internal), 3002 (exposed)
- **Purpose:** Content Marketing & Blogs
- **Stack:** Ruby on Rails 8.0, Puma

---

## 🔐 Security & SSL

### TLS Certificates
- **Provider:** Let's Encrypt (via Caddy)
- **Auto-renewal:** Enabled
- **Email:** admin@smarterbot.cl

### Certificate Coverage
All domains listed above have automatic HTTPS via Caddy.

### IP Access Policy
- Direct IP access (http://89.116.23.167) → redirects to dokploy.smarterbot.store
- HTTPS disabled for IP addresses (prevents cert errors)

---

## 📊 Service Dependencies

### Core Services (Always Running)
1. caddy-proxy (reverse proxy)
2. dokploy (deployment platform)

### Business Services
1. smarteros-metabase (analytics)
2. smarter-n8n (automation)
3. smarteros-blogbowl (marketing)

### AI/ML Services
1. nexa-server (AI runtime)

### Support Services
1. smarter-chatwoot (support)
2. smarter-botpress (chatbot)

### ERP Services
1. smarter-odoo (business management)

---

## 🔧 Configuration Files

### Docker Compose Files
- `/root/docker-compose-caddy.yml` - Reverse proxy
- `/root/docker-compose-blogbowl.yml` - Marketing platform
- `/root/docker-compose-nexa.yml` - AI server
- `/root/docker-compose-vault.yml` - Secrets management

### Service Configs
- `/root/Caddyfile` - Reverse proxy configuration
- `/root/vault-config.hcl` - Vault configuration

### Scripts
- `/root/QUICK-START-NEXA.sh` - Nexa testing script
- `/root/migrate-to-caddy.sh` - Migration script

---

## 📈 Monitoring & Logs

### Log Locations
- Caddy: `/var/log/caddy/*.log`
- Docker: `docker logs <container>`

### Health Checks
All services have healthcheck endpoints configured.

### Metrics
- Metabase dashboards available at kpi.smarterbot.cl
- Docker stats: `docker stats`

---

## 🚀 Quick Commands

### View all services
```bash
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
```

### Restart Caddy (after config changes)
```bash
docker restart caddy-proxy
```

### View Caddy logs
```bash
docker logs -f caddy-proxy
```

### Check service health
```bash
docker ps --filter "health=unhealthy"
```

### Reload Caddy config (no downtime)
```bash
docker exec caddy-proxy caddy reload --config /etc/caddy/Caddyfile
```

---

## 📝 Notes

1. **Primary IP:** 89.116.23.167
2. **Network Mode:** All services on `smarter-net` bridge network
3. **SSL:** Automatic via Caddy + Let's Encrypt
4. **Domains:** .cl domains for main services, .store for Hostinger-specific
5. **Port Conflicts:** Avoided by using internal container ports
6. **Health Checks:** All services monitored for availability

---

## 🔄 Recent Changes (2025-11-18)

1. ✅ Migrated from Traefik to Caddy
2. ✅ Added BlogBowl marketing platform (mkt.smarterbot.cl/.store)
3. ✅ Fixed healthcheck for BlogBowl container
4. ✅ Normalized DNS configuration across .cl and .store domains
5. ✅ Added Nexa AI server (ai.smarterbot.store)
6. ✅ Configured dual-domain support for dokploy and mkt

---

**Last Updated:** 2025-11-18T20:59:31Z  
**Maintained by:** SmarterOS Team
