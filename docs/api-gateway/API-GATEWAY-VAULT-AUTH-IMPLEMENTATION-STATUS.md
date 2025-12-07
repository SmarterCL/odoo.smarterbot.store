# 🔐 Vault Authentication Implementation Status

**Fecha:** 2025-11-19 13:00 UTC
**Servidor:** 89.116.23.167

## ✅ Completado

### 1. Vault Auth Validator Service

**Container:** `vault-auth-validator`
**Puerto:** 8082 → 8080
**Estado:** ✅ Running
**Health:** ⚠️ Unhealthy (Vault MCP no responde correctamente)

```bash
# Check status
docker ps | grep vault-auth-validator

# Check logs
docker logs vault-auth-validator

# Test health
curl http://localhost:8082/health
```

**Endpoints disponibles:**
- `GET /health` - Health check del validador
- `POST /validate` - Valida token de Vault
- `GET /` - Info del servicio

### 2. Docker Image

**Image:** `vault-auth-validator:latest`
**Size:** ~20MB (Alpine based)
**Go Version:** 1.21

**Features:**
- Health check integrado
- Logging estructurado
- Multi-stage build (optimizado)
- CA certificates incluidos

### 3. Código Implementado

**Archivo:** `/root/vault-auth-validator/main.go`

**Funcionalidades:**
```go
✅ validateToken() - Valida tokens contra Vault
✅ healthCheck() - Verifica conectividad con Vault
✅ loggingMiddleware() - Logs de requests
✅ respondError() - Manejo de errores JSON
```

**Validación de token:**
- Extrae token del header `Authorization: Bearer <token>`
- Valida contra Vault usando `token.LookupSelf()`
- Retorna metadata del token (user, policies)
- Agrega headers `X-Vault-*` para Caddy

### 4. Docker Compose

**Archivo:** `/root/docker-compose-vault-auth.yml`

**Configuración:**
- Network: `smarter-net` (compartida con otros servicios)
- Environment: `VAULT_ADDR=http://smarteros-vault-mcp:8080`
- Port mapping: `8082:8080`
- Health check cada 30s
- Restart policy: `unless-stopped`

## ⏳ Pendiente

### 1. Configurar Forward Auth en Caddy

Actualmente el API Gateway **NO** valida tokens. Todas las APIs son públicas.

**Necesario:**

```caddyfile
# /root/Caddyfile
api.smarterbot.cl, api.smarterbot.store {
    
    # AGREGAR Forward Auth
    forward_auth vault-auth-validator:8080 {
        uri /validate
        copy_headers X-Vault-Policies X-Auth-User
    }
    
    # ... resto de configuración
}
```

**⚠️ IMPORTANTE:** Caddy standard no incluye `forward_auth`. Necesita:
- Caddy con plugin `forward_auth`, O
- Usar plugin `http.authentication.providers.forward_auth`, O
- Implementar con `handle` + `reverse_proxy` + validación manual

### 2. Fix Vault MCP Health

El Vault MCP Server está en estado `unhealthy`:

```bash
docker ps | grep vault-mcp
# smarteros-vault-mcp   Up 16 hours (unhealthy)
```

**Diagnóstico necesario:**
```bash
# Check logs
docker logs smarteros-vault-mcp --tail 50

# Check health endpoint
curl http://localhost:8081/health

# Check MCP endpoint  
curl http://localhost:8081/mcp
```

### 3. Crear Usuarios en Vault

Crear usuarios basados en las policies de `smarteros-specs/vault/policies`:

```bash
# Enable userpass auth
vault auth enable userpass

# Admin
vault write auth/userpass/users/admin \
  password="$(openssl rand -base64 32)" \
  policies="mcp-admin-full"

# Agente Gemini (15 MCPs)
vault write auth/userpass/users/gemini-agent \
  password="$(openssl rand -base64 32)" \
  policies="agent-gemini-mcp-access"

# Agente Copilot (4 MCPs)
vault write auth/userpass/users/copilot-agent \
  password="$(openssl rand -base64 32)" \
  policies="agent-copilot-mcp-access"

# Agente Codex (9 MCPs)
vault write auth/userpass/users/codex-agent \
  password="$(openssl rand -base64 32)" \
  policies="agent-codex-mcp-access"
```

### 4. Aplicar Vault Policies

Copiar policies desde `smarteros-specs/vault/policies/` y aplicarlas:

```bash
# Clone specs repo si no está
cd /root
git clone https://github.com/SmarterCL/smarteros-specs.git

# Aplicar todas las policies
cd smarteros-specs/vault/policies
for policy in *.hcl; do
  name=$(basename "$policy" .hcl)
  vault policy write "$name" "$policy"
  echo "✅ Applied: $name"
done
```

### 5. Testing de Autenticación

```bash
# Test 1: Sin token (debe fallar 401)
curl -I https://api.smarterbot.cl/n8n/api/v1/workflows

# Test 2: Login y usar token
TOKEN=$(curl -s -X POST http://localhost:8200/v1/auth/userpass/login/gemini-agent \
  -d '{"password":"xxx"}' | jq -r '.auth.client_token')

curl https://api.smarterbot.cl/n8n/api/v1/workflows \
  -H "Authorization: Bearer $TOKEN"

# Test 3: Validar directamente contra el validator
curl -X POST http://localhost:8082/validate \
  -H "Authorization: Bearer $TOKEN"
```

## 🔧 Alternativa Rápida: API Key Simple

Si Caddy no tiene `forward_auth`, implementar autenticación básica con API key:

```caddyfile
api.smarterbot.cl {
    
    @authenticated {
        header Authorization "Bearer secret-api-key-123"
    }
    
    handle @authenticated {
        # Todas las rutas de APIs aquí
        handle_path /dokploy/* {
            reverse_proxy dokploy:3000
        }
        # ...
    }
    
    handle {
        respond "Unauthorized" 401
    }
}
```

**Pros:**
- Implementación inmediata (5 min)
- No necesita servicio adicional
- Simple de mantener

**Cons:**
- No usa Vault (no sigue specs)
- API key estática
- Sin roles/policies granulares
- Sin audit log

## 📋 Próximos Pasos (Orden Recomendado)

1. **[5 min]** Diagnosticar y fix Vault MCP health
2. **[10 min]** Aplicar Vault policies desde specs
3. **[10 min]** Crear usuarios en Vault
4. **[20 min]** Investigar solución forward_auth en Caddy
   - Opción A: Caddy con plugin
   - Opción B: Reescribir con `handle` + validación manual
   - Opción C: API key temporal mientras tanto
5. **[15 min]** Testing completo de autenticación
6. **[10 min]** Documentar credenciales y tokens

## 🚨 Bloqueadores

### 1. Caddy Forward Auth

Caddy standard no tiene `forward_auth` directive. Opciones:

**A) Rebuild Caddy con plugin:**
```bash
xcaddy build --with github.com/caddyserver/forwardauth
```

**B) Usar Traefik en su lugar:**
Traefik tiene `forwardAuth` nativo y es más común para este patrón.

**C) Implementar con handle:**
```caddyfile
handle {
    # Hacer request al validator
    reverse_proxy http://vault-auth-validator:8080/validate {
        @error status 401 403
        handle_response @error {
            respond "Unauthorized" 401
        }
    }
    # Si OK, continuar al backend
}
```

### 2. Vault MCP Connection

El validator no puede conectarse a Vault MCP. Verificar:
- Network connectivity
- Vault MCP listening port
- Vault initialization status

## 📚 Documentación Generada

- ✅ `/root/API-GATEWAY-VAULT-AUTH.md` - Guía completa
- ✅ `/root/vault-auth-validator/main.go` - Código del validator
- ✅ `/root/vault-auth-validator/Dockerfile` - Build image
- ✅ `/root/docker-compose-vault-auth.yml` - Deployment

## 🔗 Referencias

- **Specs Vault Policies:** https://github.com/SmarterCL/smarteros-specs/tree/main/vault/policies
- **Vault API:** https://developer.hashicorp.com/vault/api-docs
- **Caddy Forward Auth Issue:** https://github.com/caddyserver/caddy/discussions/4550

---

**Estado General:** 
- ✅ Validator service: OK
- ⚠️ Vault MCP: Needs fix
- ⏳ Caddy integration: Pending
- ⏳ Vault users: Not created
- ⏳ Testing: Not done

**Estimado para completar:** 1-2 horas
