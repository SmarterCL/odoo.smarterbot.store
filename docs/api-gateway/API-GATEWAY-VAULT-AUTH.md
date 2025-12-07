# 🔐 Autenticación Vault para API Gateway - SmarterBot

**Fecha:** 2025-11-19
**Basado en:** smarteros-specs/vault/policies

## 🎯 Objetivo

Proteger el API Gateway (api.smarterbot.cl) usando Vault como sistema de autenticación centralizado, siguiendo el principio de **Zero Trust** y **Least Privilege**.

## 📋 Arquitectura

```
┌─────────┐     ┌──────────────┐     ┌───────┐     ┌──────────┐
│ Usuario │────▶│ API Gateway  │────▶│ Vault │────▶│ Valida   │
│         │     │ Caddy        │     │  MCP  │     │ Token    │
└─────────┘     └──────────────┘     └───────┘     └──────────┘
                       │                                │
                       │  Token válido ✅               │
                       ▼                                │
                ┌──────────────┐                       │
                │ Servicios:   │◀──────────────────────┘
                │ • n8n        │
                │ • Chatwoot   │
                │ • Dokploy    │
                │ • ...        │
                └──────────────┘
```

## 🔑 Flujo de Autenticación

### 1. Usuario obtiene token de Vault

```bash
# Login en Vault
curl -X POST https://mcp.smarterbot.cl/v1/auth/userpass/login/username \
  -d '{"password":"userpass"}'

# Response:
{
  "auth": {
    "client_token": "hvs.CAESIxxx...",
    "policies": ["agent-copilot-mcp-access"],
    "metadata": {
      "username": "copilot-agent"
    }
  }
}
```

### 2. Usuario usa token en API Gateway

```bash
# Acceder a cualquier API
curl https://api.smarterbot.cl/n8n/api/v1/workflows \
  -H "Authorization: Bearer hvs.CAESIxxx..."
```

### 3. API Gateway valida token

Caddy valida el token contra Vault antes de hacer el proxy al servicio.

## 🏗️ Implementación

### Opción 1: Forward Auth (Recomendada)

Crear un servicio ligero que valide tokens de Vault:

```go
// vault-auth-validator/main.go
package main

import (
    "fmt"
    "net/http"
    "strings"
    
    vault "github.com/hashicorp/vault/api"
)

func validateToken(w http.ResponseWriter, r *http.Request) {
    // Extraer token del header Authorization
    auth := r.Header.Get("Authorization")
    if !strings.HasPrefix(auth, "Bearer ") {
        http.Error(w, "Unauthorized", 401)
        return
    }
    
    token := strings.TrimPrefix(auth, "Bearer ")
    
    // Crear cliente Vault
    config := vault.DefaultConfig()
    config.Address = "http://vault-mcp:8200"
    client, _ := vault.NewClient(config)
    client.SetToken(token)
    
    // Validar token lookup
    secret, err := client.Auth().Token().LookupSelf()
    if err != nil {
        http.Error(w, "Invalid token", 401)
        return
    }
    
    // Extraer policies del token
    policies, _ := secret.Data["policies"].([]interface{})
    
    // Agregar headers con metadata
    w.Header().Set("X-Vault-Policies", fmt.Sprint(policies))
    w.Header().Set("X-Auth-User", secret.Data["display_name"].(string))
    
    w.WriteHeader(200)
}

func main() {
    http.HandleFunc("/validate", validateToken)
    http.ListenAndServe(":8080", nil)
}
```

### Configurar Caddy con Forward Auth

```caddyfile
api.smarterbot.cl, api.smarterbot.store {
    
    # Forward Auth - Validar con Vault
    forward_auth vault-auth-validator:8080 {
        uri /validate
        copy_headers X-Vault-Policies X-Auth-User
    }
    
    # Dokploy API
    handle_path /dokploy/* {
        reverse_proxy dokploy:3000
    }
    
    # n8n API
    handle_path /n8n/* {
        reverse_proxy smarter-n8n:5678
    }
    
    # ... resto de APIs
}
```

### Opción 2: Caddy HTTP Basic + Vault Lookup

Más simple, usando autenticación básica:

```caddyfile
api.smarterbot.cl {
    
    basicauth {
        # Las credenciales se validan contra Vault
        vault {
            addr http://vault-mcp:8200
            path auth/userpass/login
        }
    }
    
    handle_path /dokploy/* {
        reverse_proxy dokploy:3000
    }
}
```

## 👥 Roles y Políticas

Basado en `smarteros-specs/vault/policies`:

### 1. Admin (Humanos)

```hcl
# Policy: mcp-admin-full.hcl
path "smarteros/mcp/*" {
  capabilities = ["create", "read", "update", "delete", "list"]
}
```

**Uso:**
```bash
# Login admin
vault login -method=userpass username=admin password=xxx

# Acceso completo al API Gateway
curl https://api.smarterbot.cl/dokploy/api/project \
  -H "Authorization: Bearer $VAULT_TOKEN"
```

### 2. Agente Gemini (Director)

```hcl
# Policy: agent-gemini-mcp-access.hcl
# 15 MCPs: github, vault, supabase, shopify, metabase, odoo, n8n, 
#          stripe, openai, anthropic, google, slack, twilio, 
#          whatsapp, mailgun, linear, notion
```

**Uso:**
```bash
# Login Gemini
vault login -method=userpass username=gemini-agent password=xxx

# Acceso a múltiples APIs
curl https://api.smarterbot.cl/n8n/api/v1/workflows \
  -H "Authorization: Bearer $VAULT_TOKEN"
```

### 3. Agente Copilot (Writer)

```hcl
# Policy: agent-copilot-mcp-access.hcl
# 4 MCPs: github, vault, supabase, context7
# NO acceso a datos de negocio (shopify orders, etc)
```

**Uso:**
```bash
# Login Copilot
vault login -method=userpass username=copilot-agent password=xxx

# Acceso limitado
curl https://api.smarterbot.cl/chatwoot/api/v1/... \
  -H "Authorization: Bearer $VAULT_TOKEN"
# ❌ Denied si intenta acceder a APIs no permitidas
```

### 4. Agente Codex (Executor)

```hcl
# Policy: agent-codex-mcp-access.hcl
# 9 MCPs: github, vault, docker, hostinger, n8n, slack,
#         cloudflare, aws, caddy
# Full access a SSH keys e infraestructura
```

**Uso:**
```bash
# Login Codex
vault login -method=userpass username=codex-agent password=xxx

# Acceso a APIs de infraestructura
curl https://api.smarterbot.cl/portainer/api/containers \
  -H "Authorization: Bearer $VAULT_TOKEN"
```

### 5. CI/CD (Readonly)

```hcl
# Policy: ci-readonly.hcl
# Solo lectura de deploy secrets
```

## 🚀 Deployment

### 1. Crear servicio de validación

```bash
# Dockerfile
cat > /root/vault-auth-validator/Dockerfile << 'DOCKERFILE'
FROM golang:1.21-alpine

WORKDIR /app
COPY main.go go.mod go.sum ./
RUN go build -o validator

CMD ["./validator"]
DOCKERFILE
```

### 2. Agregar al docker-compose

```yaml
# docker-compose-api-auth.yml
services:
  vault-auth-validator:
    build: ./vault-auth-validator
    container_name: vault-auth-validator
    restart: unless-stopped
    environment:
      VAULT_ADDR: http://smarteros-vault-mcp:8080
    networks:
      - smarter-net
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8080/health"]
      interval: 30s
      timeout: 10s
      retries: 3
```

### 3. Actualizar Caddyfile

```bash
# Agregar forward_auth al API Gateway
nano /root/Caddyfile

# Recargar Caddy
docker exec caddy-proxy caddy reload --config /etc/caddy/Caddyfile
```

### 4. Crear usuarios en Vault

```bash
# Enable userpass auth
vault auth enable userpass

# Crear agente Gemini
vault write auth/userpass/users/gemini-agent \
  password="secure-password" \
  policies="agent-gemini-mcp-access"

# Crear agente Copilot
vault write auth/userpass/users/copilot-agent \
  password="secure-password" \
  policies="agent-copilot-mcp-access"

# Crear agente Codex
vault write auth/userpass/users/codex-agent \
  password="secure-password" \
  policies="agent-codex-mcp-access"

# Crear admin
vault write auth/userpass/users/admin \
  password="admin-password" \
  policies="mcp-admin-full"
```

## 🧪 Testing

### Test 1: Sin token (debe fallar)

```bash
curl -I https://api.smarterbot.cl/n8n/api/v1/workflows
# Expected: 401 Unauthorized
```

### Test 2: Con token Gemini (debe funcionar)

```bash
# Login
GEMINI_TOKEN=$(curl -s -X POST http://localhost:8200/v1/auth/userpass/login/gemini-agent \
  -d '{"password":"secure-password"}' | jq -r '.auth.client_token')

# Request
curl https://api.smarterbot.cl/n8n/api/v1/workflows \
  -H "Authorization: Bearer $GEMINI_TOKEN"
# Expected: 200 OK + workflows data
```

### Test 3: Copilot accediendo a API no permitida

```bash
# Login Copilot
COPILOT_TOKEN=$(curl -s -X POST http://localhost:8200/v1/auth/userpass/login/copilot-agent \
  -d '{"password":"secure-password"}' | jq -r '.auth.client_token')

# Intentar acceder a Shopify (no permitido)
curl https://api.smarterbot.cl/odoo/web/session/authenticate \
  -H "Authorization: Bearer $COPILOT_TOKEN"
# Expected: 403 Forbidden
```

### Test 4: Validar policies del token

```bash
# Ver policies asignadas
vault token lookup $GEMINI_TOKEN | grep policies
# Expected: agent-gemini-mcp-access
```

## 📊 Matriz de Acceso API Gateway

| API Endpoint | Admin | Gemini | Copilot | Codex | Notas |
|--------------|-------|--------|---------|-------|-------|
| /dokploy/* | ✅ | ✅ | ✅ | ✅ | Infraestructura |
| /n8n/* | ✅ | ✅ | ❌ | ✅ | Workflows |
| /chatwoot/* | ✅ | ✅ | ✅ | ❌ | Soporte |
| /metabase/* | ✅ | ✅ | ❌ | ❌ | Analytics |
| /odoo/* | ✅ | ✅ | ❌ | ❌ | ERP |
| /portainer/* | ✅ | ❌ | ❌ | ✅ | Docker |
| /botpress/* | ✅ | ✅ | ✅ | ❌ | Chatbot |

## 🔒 Seguridad

### Token TTL

```bash
# Configurar TTL de tokens
vault write auth/userpass/users/gemini-agent \
  token_ttl=1h \
  token_max_ttl=24h
```

### Rate Limiting

```bash
# Configurar rate limit por usuario
vault write sys/quotas/rate-limit/api-gateway \
  role="agent-*" \
  rate=100 \
  interval=1m
```

### Audit Log

```bash
# Habilitar audit log
vault audit enable file file_path=/vault/logs/audit.log

# Ver accesos
tail -f /vault/logs/audit.log | grep api-gateway
```

## 📝 Próximos Pasos

- [ ] Implementar vault-auth-validator service
- [ ] Configurar forward_auth en Caddy
- [ ] Crear usuarios y roles en Vault
- [ ] Testing completo de todos los roles
- [ ] Documentar procedimiento de rotación de tokens
- [ ] Implementar rate limiting
- [ ] Configurar alertas de accesos no autorizados

## 📚 Referencias

- **Vault Policies:** `smarteros-specs/vault/policies/README.md`
- **MCP Registry:** `smarteros-specs/mcp/index.yml`
- **Infrastructure:** `smarteros-specs/infra/infrastructure.yml`
- **Vault API:** https://developer.hashicorp.com/vault/api-docs

---

**Principio:** Zero Trust - Autenticación basada en tokens de Vault con políticas granulares por rol/agente.
