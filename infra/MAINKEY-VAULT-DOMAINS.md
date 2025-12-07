# mainkey - Vault Key Management System
**Fecha:** 2025-11-19 14:45 UTC
**Status:** ✅ Caddy Configured | ⏳ DNS Pending

## 🎯 Resumen

**mainkey** es el alias de dominio para el sistema Vault (Key Management) en SmarterOS.

## 📋 Dominios Configurados

| Dominio | IP | Puerto | Status |
|---------|-----|--------|--------|
| mainkey.smarterbot.cl | 89.116.23.167 | 443 (HTTPS) | ⏳ DNS Pending |
| mainkey.smarterbot.store | 89.116.23.167 | 443 (HTTPS) | ⏳ DNS Pending |

## 🏗️ Arquitectura

```
Internet (HTTPS/443)
    ↓
Cloudflare DNS (DNS only - no proxy)
    ↓
mainkey.smarterbot.cl ──┐
mainkey.smarterbot.store ┘
    ↓
89.116.23.167:443
    ↓
Caddy Proxy
    ├─→ SSL/TLS (Let's Encrypt)
    ├─→ Security Headers
    └─→ Access Logs
    ↓
smarteros-vault-mcp:8080
    ├─→ Token Management
    ├─→ Secret Storage
    ├─→ API Authentication
    └─→ Traefik Integration
```

## 🔐 Configuración Caddy

```caddy
# Vault - Key Management System (mainkey)
mainkey.smarterbot.cl, mainkey.smarterbot.store {
    reverse_proxy smarteros-vault-mcp:8080
    encode gzip
    
    header {
        X-Frame-Options "DENY"
        X-Content-Type-Options "nosniff"
        Referrer-Policy "strict-origin-when-cross-origin"
    }
    
    log {
        output file /var/log/caddy/mainkey-vault.log
    }
}
```

## 🌐 DNS Configuration

### Cloudflare Records

**smarterbot.cl:**
```
Type: A
Name: mainkey
Content: 89.116.23.167
TTL: Auto
Proxy: DNS only (OFF)
```

**smarterbot.store:**
```
Type: A
Name: mainkey
Content: 89.116.23.167
TTL: Auto
Proxy: DNS only (OFF)
```

## 🎯 Uso y Propósito

### Servicios Integrados

1. **Traefik API Gateway** (api.smarterbot.store)
   - Forward Auth validation
   - Token verification
   - Request authentication

2. **MCP Registry** (mcp.smarterbot.store)
   - API credentials storage
   - Integration tokens
   - MCP handshake authentication

3. **Shopify Integration**
   - API keys secure storage
   - Webhook secrets
   - OAuth tokens

4. **Odoo ERP** (erp.smarterbot.cl)
   - Database credentials
   - API tokens
   - Integration keys

5. **Chatwoot CRM** (crm.smarterbot.cl)
   - WhatsApp API keys
   - Integration tokens
   - OAuth credentials

## 🔑 URLs Finales

| Endpoint | URL | Uso |
|----------|-----|-----|
| Vault UI | https://mainkey.smarterbot.cl | Web Interface |
| Vault UI (alt) | https://mainkey.smarterbot.store | Web Interface |
| Vault API | https://mainkey.smarterbot.cl/v1/ | REST API |
| Health Check | https://mainkey.smarterbot.cl/v1/sys/health | Status Monitor |
| Seal Status | https://mainkey.smarterbot.cl/v1/sys/seal-status | Seal Status |

## 🧪 Testing

```bash
# DNS Resolution
dig mainkey.smarterbot.cl +short
dig mainkey.smarterbot.store +short

# SSL/HTTPS
curl -I https://mainkey.smarterbot.cl
curl -I https://mainkey.smarterbot.store

# Vault Health
curl -s https://mainkey.smarterbot.cl/v1/sys/health | jq

# Vault Seal Status
curl -s https://mainkey.smarterbot.cl/v1/sys/seal-status | jq
```

## 📊 Status

### ✅ Completado
- Caddy configuration
- SSL/TLS setup (auto)
- Security headers
- Logging
- Reverse proxy to vault container

### ⏳ Pendiente
- DNS configuration in Cloudflare
- DNS propagation (1-5 min)
- Vault initialization (if new)
- Access testing

## 🔐 Seguridad

- ✅ DNS only (no Cloudflare proxy) para comunicación directa
- ✅ SSL/TLS automático vía Let's Encrypt
- ✅ Security headers (X-Frame-Options, CSP, etc.)
- ✅ Logs centralizados
- ✅ Reverse proxy isolation

## 📝 Notas

1. **Naming Convention**: "mainkey" = Main Key = Vault (Key Management)
2. **Dual Domain**: Soporta tanto .cl como .store para flexibilidad
3. **Proxy Disabled**: DNS only para mejor rendimiento con Vault
4. **SSL Auto**: Caddy gestiona certificados automáticamente
5. **Container**: Usa `smarteros-vault-mcp` existente en puerto 8080

## 🔄 Integración MCP

```yaml
# MCP Handshake con Vault Authentication
External App → mcp.smarterbot.store
    ↓
MCP Protocol Discovery
    ↓
Authentication Request → mainkey.smarterbot.cl
    ↓
Token Validation
    ↓
Authenticated Connection
    ↓
Access to:
    - Shopify API
    - Odoo ERP
    - Chatwoot CRM
    - SmarterOS Core
```

## 📞 Referencias

- Caddy Config: `/root/Caddyfile`
- DNS Script: `/root/configure-dns-mainkey.sh`
- Setup Guide: `/root/RESUMEN-MAINKEY-SETUP.md`
- DNS Instructions: `/root/DNS-MAINKEY-INSTRUCCIONES.md`

---

**mainkey = Vault = SmarterOS Key Management System** 🔐
