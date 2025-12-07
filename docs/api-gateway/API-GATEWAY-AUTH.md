# 🔐 API Gateway Authentication - Complete Documentation

**Date:** 2025-11-19 13:25 UTC  
**Server:** 89.116.23.167  
**Type:** Bearer Token (Static - Temporary)

---

## 📍 1. Ubicación en Vault

### Path en Vault
```
secret/data/mcp/api-gateway
```

### Archivo en VPS
```bash
/root/vault-secrets/api-gateway.json
```

**Permisos:** `chmod 600` (solo root puede leer)

---

## 🔑 2. API Key Actual

**Bearer Token:**
```
86220f9799aa262ce8cdd8dae397203a58ea326c2e520791d37f023120e1c336
```

**Tipo:** Bearer  
**Creado:** 2025-11-19 13:25 UTC  
**Próxima rotación:** 2025-02-17 (90 días)

---

## 📋 3. Uso de la API Key

### Formato de Request

```bash
curl https://api.smarterbot.cl/<endpoint> \
  -H "Authorization: Bearer 86220f9799aa262ce8cdd8dae397203a58ea326c2e520791d37f023120e1c336"
```

### Ejemplos por Servicio

#### Dokploy API
```bash
curl https://api.smarterbot.cl/dokploy/api/auth/login \
  -H "Authorization: Bearer 86220f9799aa262ce8cdd8dae397203a58ea326c2e520791d37f023120e1c336" \
  -H "Content-Type: application/json" \
  -d '{"email":"admin@smarterbot.cl","password":"xxx"}'
```

#### n8n API
```bash
curl https://api.smarterbot.cl/n8n/api/v1/workflows \
  -H "Authorization: Bearer 86220f9799aa262ce8cdd8dae397203a58ea326c2e520791d37f023120e1c336"
```

#### Chatwoot API
```bash
curl https://api.smarterbot.cl/chatwoot/api/v1/accounts/1/conversations \
  -H "Authorization: Bearer 86220f9799aa262ce8cdd8dae397203a58ea326c2e520791d37f023120e1c336"
```

#### Metabase API
```bash
curl https://api.smarterbot.cl/metabase/api/session \
  -H "Authorization: Bearer 86220f9799aa262ce8cdd8dae397203a58ea326c2e520791d37f023120e1c336" \
  -H "Content-Type: application/json" \
  -d '{"username":"user@domain.com","password":"xxx"}'
```

#### Odoo API
```bash
curl https://api.smarterbot.cl/odoo/web/session/authenticate \
  -H "Authorization: Bearer 86220f9799aa262ce8cdd8dae397203a58ea326c2e520791d37f023120e1c336" \
  -H "Content-Type: application/json" \
  -d '{"jsonrpc":"2.0","params":{"db":"database","login":"user","password":"xxx"}}'
```

#### Portainer API
```bash
curl https://api.smarterbot.cl/portainer/api/endpoints \
  -H "Authorization: Bearer 86220f9799aa262ce8cdd8dae397203a58ea326c2e520791d37f023120e1c336"
```

#### Botpress API
```bash
curl https://api.smarterbot.cl/botpress/api/v1/bots \
  -H "Authorization: Bearer 86220f9799aa262ce8cdd8dae397203a58ea326c2e520791d37f023120e1c336"
```

---

## 🔄 4. Rotación de la API Key

### Generar Nueva Key

```bash
# Generar nueva API key
NEW_KEY=$(openssl rand -hex 32)
echo "Nueva API Key: $NEW_KEY"
```

### Actualizar en Vault Secret

```bash
# Editar el archivo JSON
nano /root/vault-secrets/api-gateway.json

# Actualizar campo "api_key" con la nueva key
# Actualizar "created_at" con fecha actual
# Actualizar "next_rotation" sumando 90 días
```

### Actualizar en Caddy

```bash
# Editar Caddyfile
nano /root/Caddyfile

# Buscar línea:
# @authorized {
#     header Authorization "Bearer OLD_KEY"
# }

# Reemplazar con nueva key
# Recargar Caddy
docker exec caddy-proxy caddy reload --config /etc/caddy/Caddyfile
```

### Calendario de Rotación

```
Creación:         2025-11-19
Primera rotación: 2025-02-17 (90 días)
Segunda rotación: 2025-05-18 (90 días)
Tercera rotación: 2025-08-16 (90 días)
```

---

## 🤖 5. Lectura desde MCP

### MCP JSON-RPC Request

```json
{
  "jsonrpc": "2.0",
  "method": "vault.read",
  "params": {
    "path": "secret/data/mcp/api-gateway"
  },
  "id": 1
}
```

### MCP Response

```json
{
  "jsonrpc": "2.0",
  "result": {
    "data": {
      "api_key": "86220f9799aa262ce8cdd8dae397203a58ea326c2e520791d37f023120e1c336",
      "type": "bearer",
      "created_at": "2025-11-19T13:25:00Z",
      "description": "SmarterOS API Gateway primary token",
      "allowed_services": ["dokploy", "n8n", "chatwoot", ...]
    }
  },
  "id": 1
}
```

### Uso desde Scripts

```bash
# Leer desde JSON local
API_KEY=$(jq -r '.data.api_key' /root/vault-secrets/api-gateway.json)

# Usar en requests
curl https://api.smarterbot.cl/n8n/api/v1/workflows \
  -H "Authorization: Bearer $API_KEY"
```

---

## 🔐 6. Políticas de Acceso Vault

### Roles con Acceso

Según `smarteros-specs/vault/policies`:

```hcl
# mcp-admin-full.hcl
path "secret/data/mcp/*" {
  capabilities = ["create", "read", "update", "delete", "list"]
}

# agent-gemini-mcp-access.hcl
path "secret/data/mcp/api-gateway" {
  capabilities = ["read"]
}

# agent-copilot-mcp-access.hcl
path "secret/data/mcp/api-gateway" {
  capabilities = ["read"]
}

# agent-codex-mcp-access.hcl
path "secret/data/mcp/api-gateway" {
  capabilities = ["read"]
}
```

### Crear Políticas en Vault (cuando esté disponible)

```bash
# Policy para lectura del gateway
vault policy write mcp-api-gateway-read - <<EOF
path "secret/data/mcp/api-gateway" {
  capabilities = ["read"]
}
EOF

# Asignar a roles de agentes
vault write auth/userpass/users/gemini-agent policies="agent-gemini-mcp-access,mcp-api-gateway-read"
vault write auth/userpass/users/copilot-agent policies="agent-copilot-mcp-access,mcp-api-gateway-read"
vault write auth/userpass/users/codex-agent policies="agent-codex-mcp-access,mcp-api-gateway-read"
```

---

## 🌐 7. Integración con Aplicaciones Externas

### n8n Workflow

```javascript
// HTTP Request Node
{
  "method": "GET",
  "url": "https://api.smarterbot.cl/chatwoot/api/v1/conversations",
  "headers": {
    "Authorization": "Bearer 86220f9799aa262ce8cdd8dae397203a58ea326c2e520791d37f023120e1c336"
  }
}
```

### GitHub Actions

```yaml
# .github/workflows/deploy.yml
- name: Trigger Dokploy Deployment
  run: |
    curl -X POST https://api.smarterbot.cl/dokploy/api/deployment \
      -H "Authorization: Bearer ${{ secrets.API_GATEWAY_KEY }}" \
      -H "Content-Type: application/json" \
      -d '{"applicationId":"app-123","branch":"main"}'
```

### Zapier / Make

```
URL: https://api.smarterbot.cl/<endpoint>
Headers:
  Authorization: Bearer 86220f9799aa262ce8cdd8dae397203a58ea326c2e520791d37f023120e1c336
```

### Shopify Webhooks

```javascript
// Shopify webhook handler
const apiKey = '86220f9799aa262ce8cdd8dae397203a58ea326c2e520791d37f023120e1c336';

fetch('https://api.smarterbot.cl/n8n/webhook/shopify-orders', {
  method: 'POST',
  headers: {
    'Authorization': `Bearer ${apiKey}`,
    'Content-Type': 'application/json'
  },
  body: JSON.stringify(orderData)
});
```

---

## ⚙️ 8. Configuración en Caddy

### Archivo: `/root/Caddyfile`

```caddyfile
# API Gateway - Centralized API Access with API Key Authentication
api.smarterbot.cl, api.smarterbot.store {
    
    # Health check endpoint (public, no auth)
    handle /health {
        respond "API Gateway OK" 200
    }
    
    # All other endpoints require API key
    @authorized {
        header Authorization "Bearer 86220f9799aa262ce8cdd8dae397203a58ea326c2e520791d37f023120e1c336"
    }
    
    handle @authorized {
        # Routes to all services...
        handle_path /dokploy/* {
            reverse_proxy dokploy:3000
        }
        # ...
    }
    
    # Unauthorized - missing or invalid API key
    handle {
        respond "Unauthorized: Invalid or missing API key" 401
    }
}
```

### Recargar Configuración

```bash
docker exec caddy-proxy caddy reload --config /etc/caddy/Caddyfile
```

---

## 🚨 9. Seguridad

### ⚠️ ADVERTENCIAS

- ❌ **NO** compartir la API key públicamente
- ❌ **NO** commitear a repositorios Git
- ❌ **NO** enviar por email/Slack sin cifrar
- ❌ **NO** hardcodear en código fuente
- ✅ **SÍ** usar variables de entorno
- ✅ **SÍ** rotar cada 90 días
- ✅ **SÍ** usar HTTPS siempre

### Almacenamiento Seguro

**En VPS:**
```bash
/root/vault-secrets/api-gateway.json  # chmod 600
/root/API-KEY.txt                      # chmod 600
```

**En aplicaciones:**
```bash
# Variables de entorno
export API_GATEWAY_KEY="86220f9799aa262ce8cdd8dae397203a58ea326c2e520791d37f023120e1c336"

# GitHub Secrets
Settings → Secrets → New repository secret
Name: API_GATEWAY_KEY
Value: 86220f9799aa262ce8cdd8dae397203a58ea326c2e520791d37f023120e1c336

# .env files (con .gitignore)
API_GATEWAY_KEY=86220f9799aa262ce8cdd8dae397203a58ea326c2e520791d37f023120e1c336
```

### Monitoreo de Accesos

```bash
# Ver logs de Caddy
docker logs caddy-proxy --tail 100 -f | grep "401\|Authorization"

# Ver requests autorizados
docker logs caddy-proxy --tail 100 -f | grep "200"

# Archivo de logs
docker exec caddy-proxy tail -f /var/log/caddy/api.log
```

---

## 🔄 10. Migración Futura a Vault Auth

### Estado Actual

✅ API Key estática en Caddy  
⏳ Vault MCP server deployed (unhealthy - needs Vault backend)  
⏳ vault-auth-validator service ready  
❌ Forward auth not implemented (Caddy limitation)

### Plan de Migración

**Opción A: Traefik + Vault Forward Auth** (Recomendado)

1. Deploy Traefik con forward auth middleware
2. Conectar a vault-auth-validator service
3. Usuarios se autentican en Vault → reciben JWT
4. Traefik valida JWT antes de proxiar requests
5. Policies granulares por agente/servicio

**Tiempo estimado:** 1.5 horas

**Opción B: Mantener Caddy + Vault KV**

1. Guardar API key en Vault KV real
2. Script que lee de Vault y actualiza Caddyfile
3. Rotación automática vía cron
4. Sin forward auth (misma arquitectura actual)

**Tiempo estimado:** 30 minutos

### Referencias

- `/root/API-GATEWAY-VAULT-AUTH.md` - Documentación completa Vault auth
- `/root/TRAEFIK-MIGRATION-PLAN.md` - Plan migración Traefik
- `/root/vault-auth-validator/` - Servicio validador listo
- `smarteros-specs/vault/policies/` - Políticas Vault

---

## 📝 11. Endpoints del API Gateway

### Servicios Disponibles

| Servicio | Base Path | Puerto Backend | Estado |
|----------|-----------|----------------|--------|
| Dokploy | `/dokploy/*` | 3000 | ✅ |
| n8n | `/n8n/*` | 5678 | ✅ |
| Chatwoot | `/chatwoot/*` | 3000 | ✅ |
| Metabase | `/metabase/*` | 3000 | ✅ |
| Odoo | `/odoo/*` | 8069 | ✅ |
| Portainer | `/portainer/*` | 9000 | ✅ |
| Botpress | `/botpress/*` | 3000 | ✅ |

### Endpoint Público (Sin Auth)

```
GET https://api.smarterbot.cl/health
Response: "API Gateway OK"
```

---

## 🧪 12. Testing

### Test 1: Sin API Key (debe fallar)

```bash
curl -I https://api.smarterbot.cl/n8n/api/v1/workflows
# Expected: HTTP/2 401
```

### Test 2: Con API Key (debe funcionar)

```bash
curl -I https://api.smarterbot.cl/n8n/api/v1/workflows \
  -H "Authorization: Bearer 86220f9799aa262ce8cdd8dae397203a58ea326c2e520791d37f023120e1c336"
# Expected: HTTP/2 200 o respuesta del servicio
```

### Test 3: Health Check Público

```bash
curl https://api.smarterbot.cl/health
# Expected: "API Gateway OK"
```

### Test 4: API Key Inválida

```bash
curl -I https://api.smarterbot.cl/dokploy/api \
  -H "Authorization: Bearer invalid-key-123"
# Expected: HTTP/2 401
```

---

## 📚 13. Documentación Relacionada

### Archivos Locales

```
/root/API-KEY.txt                                    - Credenciales seguras
/root/vault-secrets/api-gateway.json                 - Secret en formato Vault
/root/Caddyfile                                      - Configuración gateway
/root/API-GATEWAY-GUIDE.md                           - Guía del gateway
/root/API-GATEWAY-VAULT-AUTH.md                      - Auth con Vault completo
/root/API-GATEWAY-VAULT-AUTH-IMPLEMENTATION-STATUS.md - Estado implementación
/root/TRAEFIK-MIGRATION-PLAN.md                      - Plan migración
/root/DOKPLOY-API-CONFIG.md                          - Config Dokploy
```

### Repositorios

- **Specs:** https://github.com/SmarterCL/smarteros-specs
- **Vault Policies:** `smarteros-specs/vault/policies/`
- **MCP Registry:** `smarteros-specs/mcp/index.yml`

---

## 🎯 14. Checklist de Implementación

- [x] Generar API key segura
- [x] Configurar autenticación en Caddy
- [x] Testing de endpoints protegidos
- [x] Guardar secret en formato Vault
- [x] Documentar uso y rotación
- [x] Configurar permisos seguros (chmod 600)
- [ ] Migrar a Traefik + Vault auth (futuro)
- [ ] Implementar rotación automática (futuro)
- [ ] Aplicar políticas Vault (cuando Vault esté activo)

---

**Última actualización:** 2025-11-19 13:30 UTC  
**Mantenido por:** SmarterBot DevOps Team  
**Próxima revisión:** 2025-02-17 (rotación de key)
