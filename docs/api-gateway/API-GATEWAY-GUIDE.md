# API Gateway Centralizado - SmarterBot

**Última actualización:** 2025-11-19 12:40 UTC

## 🚀 Descripción

Gateway unificado que expone todas las APIs de los servicios SmarterBot bajo un único subdominio.

## 🌐 URLs Base

- **Producción CL:** https://api.smarterbot.cl
- **Producción Store:** https://api.smarterbot.store

## 📡 APIs Disponibles

### 1. Dokploy API (Infraestructura)

**Base URL:** `https://api.smarterbot.cl/dokploy`

```bash
# Login
POST /dokploy/api/auth/login
{
  "email": "user@domain.com",
  "password": "password"
}

# Listar proyectos
GET /dokploy/api/project
Authorization: Bearer TOKEN

# Crear deployment
POST /dokploy/api/deployment
Authorization: Bearer TOKEN
```

### 2. n8n API (Automatización)

**Base URL:** `https://api.smarterbot.cl/n8n`

```bash
# Listar workflows
GET /n8n/api/v1/workflows
X-N8N-API-KEY: your_api_key

# Ejecutar workflow
POST /n8n/api/v1/workflows/{id}/execute
X-N8N-API-KEY: your_api_key

# Webhook
POST /n8n/webhook/your-webhook-id
```

### 3. Chatwoot API (Soporte)

**Base URL:** `https://api.smarterbot.cl/chatwoot`

```bash
# Listar conversaciones
GET /chatwoot/api/v1/accounts/{account_id}/conversations
api_access_token: your_token

# Enviar mensaje
POST /chatwoot/api/v1/accounts/{account_id}/conversations/{id}/messages
api_access_token: your_token
{
  "content": "Hello!",
  "message_type": "outgoing"
}
```

### 4. Metabase API (Analytics)

**Base URL:** `https://api.smarterbot.cl/metabase`

```bash
# Login
POST /metabase/api/session
{
  "username": "user@domain.com",
  "password": "password"
}

# Ejecutar query
POST /metabase/api/dataset
X-Metabase-Session: session_token
{
  "database": 1,
  "type": "native",
  "native": {
    "query": "SELECT * FROM table"
  }
}
```

### 5. Odoo API (ERP)

**Base URL:** `https://api.smarterbot.cl/odoo`

```bash
# Autenticar
POST /odoo/web/session/authenticate
{
  "jsonrpc": "2.0",
  "params": {
    "db": "database",
    "login": "user",
    "password": "password"
  }
}

# Llamar método
POST /odoo/web/dataset/call_kw
{
  "jsonrpc": "2.0",
  "params": {
    "model": "res.partner",
    "method": "search_read",
    "args": [[]]
  }
}
```

### 6. Portainer API (Docker)

**Base URL:** `https://api.smarterbot.cl/portainer`

```bash
# Listar endpoints
GET /portainer/api/endpoints
X-API-Key: your_api_key

# Listar contenedores
GET /portainer/api/endpoints/{id}/docker/containers/json
X-API-Key: your_api_key
```

### 7. Botpress API (Chatbot)

**Base URL:** `https://api.smarterbot.cl/botpress`

```bash
# Conversar con bot
POST /botpress/api/v1/bots/{bot_id}/converse/{user_id}
Authorization: Bearer TOKEN
{
  "type": "text",
  "text": "Hello bot!"
}

# Webhook
POST /botpress/webhook/{webhook_id}
```

## 🔄 Compatibilidad Retroactiva

Las URLs sin prefijo apuntan a Dokploy por defecto:

```bash
https://api.smarterbot.cl/api/auth/login
# Equivalente a:
https://api.smarterbot.cl/dokploy/api/auth/login
```

## 🔒 Seguridad

### Headers Configurados

```
X-Frame-Options: SAMEORIGIN
X-Content-Type-Options: nosniff
Referrer-Policy: strict-origin-when-cross-origin
Access-Control-Allow-Origin: *
Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS
Access-Control-Allow-Headers: Authorization, Content-Type
```

### SSL/TLS

- Certificados Let's Encrypt automáticos
- Renovación automática cada 60 días
- HTTPS forzado en producción

### Autenticación

Cada API mantiene su propio sistema de autenticación:

- **Dokploy:** Bearer Token (JWT)
- **n8n:** X-N8N-API-KEY header
- **Chatwoot:** api_access_token
- **Metabase:** X-Metabase-Session
- **Odoo:** Session cookie
- **Portainer:** X-API-Key
- **Botpress:** Bearer Token

## 📊 Monitoreo

### Logs

Todos los requests se registran en:
```bash
/var/log/caddy/api.log
```

Ver logs en tiempo real:
```bash
docker exec caddy-proxy tail -f /var/log/caddy/api.log
```

### Health Checks

```bash
# Verificar gateway
curl -I https://api.smarterbot.cl/

# Verificar servicio específico
curl -I https://api.smarterbot.cl/n8n/healthz
```

## 🧪 Testing

### Ejemplo completo con Dokploy

```bash
# 1. Login
TOKEN=$(curl -s -X POST https://api.smarterbot.cl/dokploy/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"admin@smarterbot.cl","password":"your_pass"}' \
  | jq -r '.token')

# 2. Listar proyectos
curl -X GET https://api.smarterbot.cl/dokploy/api/project \
  -H "Authorization: Bearer $TOKEN" \
  | jq .
```

### Ejemplo con n8n webhook

```bash
curl -X POST https://api.smarterbot.cl/n8n/webhook/test-webhook \
  -H "Content-Type: application/json" \
  -d '{"event":"test","data":"hello"}'
```

## 🔧 Configuración Caddy

Archivo: `/root/Caddyfile`

```caddyfile
api.smarterbot.cl, api.smarterbot.store {
    handle_path /dokploy/* {
        reverse_proxy dokploy:3000
    }
    handle_path /n8n/* {
        reverse_proxy smarter-n8n:5678
    }
    # ... más servicios
}
```

## 📚 Documentación Oficial

- **Dokploy:** https://docs.dokploy.com/api
- **n8n:** https://docs.n8n.io/api/
- **Chatwoot:** https://www.chatwoot.com/developers/api/
- **Metabase:** https://www.metabase.com/docs/latest/api-documentation
- **Odoo:** https://www.odoo.com/documentation/master/developer/reference/external_api.html
- **Portainer:** https://docs.portainer.io/api/
- **Botpress:** https://botpress.com/docs/

## 🚨 Troubleshooting

### Error 502 Bad Gateway

```bash
# Verificar que el servicio esté corriendo
docker ps | grep nombre-servicio

# Ver logs del servicio
docker logs nombre-servicio --tail 50
```

### CORS Issues

Si tienes problemas con CORS, los headers ya están configurados en el gateway. Verifica que tu request incluya:
- `Origin` header
- Método correcto (GET, POST, etc.)

### SSL Certificate Issues

```bash
# Verificar certificado
echo | openssl s_client -connect api.smarterbot.cl:443 \
  -servername api.smarterbot.cl 2>/dev/null | \
  openssl x509 -noout -dates
```

## 🔄 Actualización de Configuración

```bash
# Editar Caddyfile
nano /root/Caddyfile

# Recargar Caddy
docker exec caddy-proxy caddy reload --config /etc/caddy/Caddyfile
```

## 📞 Soporte

- **Documentación:** /root/DOKPLOY-API-CONFIG.md
- **Logs:** /var/log/caddy/api.log
- **Config:** /root/Caddyfile

---

**Mantenido por:** SmarterBot DevOps Team
**Versión:** 1.0.0
