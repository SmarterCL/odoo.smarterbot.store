# 🌐 API Gateway - SmarterBot Infrastructure

**Última actualización:** 2025-11-19  
**Versión:** 1.0.0

## 📚 Documentación Disponible

### Documentos Principales

1. **[API-GATEWAY-AUTH.md](./API-GATEWAY-AUTH.md)** - Documentación completa de autenticación
2. **[API-GATEWAY-GUIDE.md](./API-GATEWAY-GUIDE.md)** - Guía del gateway centralizado
3. **[DOKPLOY-API-CONFIG.md](./DOKPLOY-API-CONFIG.md)** - Configuración Dokploy API

### Documentos de Implementación

4. **[API-GATEWAY-VAULT-AUTH.md](./API-GATEWAY-VAULT-AUTH.md)** - Autenticación con Vault
5. **[API-GATEWAY-VAULT-AUTH-IMPLEMENTATION-STATUS.md](./API-GATEWAY-VAULT-AUTH-IMPLEMENTATION-STATUS.md)** - Estado
6. **[TRAEFIK-MIGRATION-PLAN.md](./TRAEFIK-MIGRATION-PLAN.md)** - Plan de migración

### Archivos de Configuración

7. **[Caddyfile.example](./Caddyfile.example)** - Configuración de Caddy
8. **[api-gateway-secret.example.json](./api-gateway-secret.example.json)** - Estructura del secret

## 🚀 Quick Start

```bash
curl https://api.smarterbot.cl/<endpoint> \
  -H "Authorization: Bearer <API_KEY>"
```

**Endpoints:** `/dokploy/*` `/n8n/*` `/chatwoot/*` `/metabase/*` `/odoo/*` `/portainer/*` `/botpress/*`

## 🔐 Seguridad

⚠️ API Key en Vault: `secret/data/mcp/api-gateway`

---

**Repositorio:** https://github.com/SmarterCL/smarteros-specs
