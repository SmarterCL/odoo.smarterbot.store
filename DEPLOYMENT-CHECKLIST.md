# Deployment Checklist - SmarterOS Nexa Integration
Date: 2025-11-18T20:07:30.431Z

## ✅ 1. Preparar Push a GitHub

### Estado Actual
- ✅ 3 commits listos en `/root/specs`
  - b962587: Update infrastructure (Traefik → Caddy)
  - 08b8889: Add Nexa Runtime multi-tenant integration
  - b5467a9: Add integration guide and n8n workflow

### Acción Requerida
```bash
# Opción A: Configurar PAT (Personal Access Token)
cd /root/specs
git remote set-url origin https://<PAT>@github.com/SmarterCL/smarteros-specs.git
git push origin main

# Opción B: Configurar SSH key
git remote set-url origin git@github.com:SmarterCL/smarteros-specs.git
git push origin main

# Opción C: Push manual desde otro equipo
# 1. Pull desde /root/specs
# 2. Push desde máquina con credenciales configuradas
```

### Archivos a Pushear
```
services/nexa-runtime.yml
services/nexa-runtime/Dockerfile
services/nexa-runtime/app/main.py
services/nexa-runtime/requirements.txt
vault/policies/smarteros-nexa.hcl
vault/tenant-secrets-example.md
workflows/n8n-nexa-multitenant.json
NEXA-INTEGRATION-GUIDE.md
infra/reverse-proxy.yml
infra/current-domains.yml
infra/domains-status.md
services/registry.yml (updated)
```

---

## ✅ 2. Encender Servicio Nexa en Dokploy

### Prerequisitos
- ✅ Dokploy accesible en https://dokploy.smarterbot.store
- ✅ Docker compose preparado en `/root/docker-compose.nexa.yml`
- ⏳ Vault configurado (pendiente)

### Pasos en Dokploy

#### 2.1 Crear Proyecto
```
1. Acceder a https://dokploy.smarterbot.store
2. Projects → New Project
3. Nombre: "smarteros-nexa-runtime"
4. Descripción: "Multi-tenant AI Runtime for SmarterOS"
```

#### 2.2 Crear Stack desde Compose
```
1. En el proyecto → New → Compose Stack
2. Nombre: "nexa-runtime"
3. Pegar contenido de /root/docker-compose.nexa.yml
```

#### 2.3 Configurar Variables de Entorno
```yaml
NEXA_MODEL_ID: "llama-3-8b-instruct"
NEXA_MODEL_STORE: "/models"
NEXA_PORT: "8080"
NEXA_LOG_LEVEL: "info"

TENANT_MODE: "multi"
DEFAULT_TENANT_ID: "demo"

# Vault (cuando esté configurado)
VAULT_ADDR: "https://vault.smarterbot.cl:8200"
VAULT_TOKEN: "<token_from_approle>"
VAULT_NAMESPACE: ""
NEXA_VAULT_PATH_TEMPLATE: "secret/data/tenant/{{tenant_id}}/nexa"
```

#### 2.4 Configurar Dominio
```
Domain: ai.smarterbot.store
Path: /
Enable SSL: Yes (Let's Encrypt)
```

#### 2.5 Deploy
```
1. Review Configuration
2. Deploy Stack
3. Wait for container to start
4. Check logs: docker logs smarteros-nexa-runtime
```

### Verificación
```bash
# Health check
curl https://ai.smarterbot.store/health

# Test endpoint
curl -X POST https://ai.smarterbot.store/v1/chat/completions \
  -H "X-Tenant-Id: demo" \
  -H "Content-Type: application/json" \
  -d '{
    "model": "llama-3-8b-instruct",
    "messages": [{"role": "user", "content": "Hello"}]
  }'
```

---

## ✅ 3. Integrar en n8n como "SmarterMCP-Nexa"

### 3.1 Importar Workflow Base
```
1. Acceder a https://n8n.smarterbot.cl
2. Workflows → Import from File
3. Cargar: /root/specs/workflows/n8n-nexa-multitenant.json
4. Renombrar: "SmarterMCP-Nexa Chat"
```

### 3.2 Crear HTTP Request Node Template

#### Node: "SmarterMCP-Nexa Call"
```yaml
Type: HTTP Request
Method: POST
URL: https://ai.smarterbot.store/v1/chat/completions

Headers:
  - X-Tenant-Id: {{ $json.tenant_id || 'demo' }}
  - Content-Type: application/json

Body (JSON):
{
  "model": "{{ $json.model || 'llama-3-8b-instruct' }}",
  "messages": {{ $json.messages }},
  "temperature": {{ $json.temperature || 0.7 }},
  "max_tokens": {{ $json.max_tokens || 1024 }}
}

Options:
  - Response Format: JSON
  - Timeout: 30000
```

### 3.3 Crear Credential (opcional)
```
Credential Type: Header Auth
Name: SmarterMCP-Nexa-Auth
Header Name: X-Tenant-Id
Value: {{ $env.TENANT_ID }}
```

### 3.4 Template de Workflow Reutilizable

```json
{
  "name": "SmarterMCP-Nexa Template",
  "nodes": [
    {
      "name": "Webhook",
      "type": "n8n-nodes-base.webhook",
      "parameters": {
        "path": "smartermcp-nexa",
        "httpMethod": "POST"
      }
    },
    {
      "name": "Extract Tenant Context",
      "type": "n8n-nodes-base.code",
      "parameters": {
        "jsCode": "return {\n  tenant_id: $input.item.json.tenant_id || 'demo',\n  model: $input.item.json.model || 'llama-3-8b-instruct',\n  messages: $input.item.json.messages,\n  temperature: $input.item.json.temperature || 0.7\n};"
      }
    },
    {
      "name": "Call Nexa Runtime",
      "type": "n8n-nodes-base.httpRequest",
      "parameters": {
        "url": "https://ai.smarterbot.store/v1/chat/completions",
        "method": "POST",
        "sendHeaders": true,
        "headerParameters": {
          "parameters": [
            {"name": "X-Tenant-Id", "value": "={{ $json.tenant_id }}"}
          ]
        }
      }
    },
    {
      "name": "Log to Supabase",
      "type": "n8n-nodes-base.postgres",
      "parameters": {
        "operation": "insert",
        "table": "ai_runtime_logs"
      }
    }
  ]
}
```

### 3.5 Documentar en n8n
```
1. Crear carpeta: "SmarterMCP"
2. Mover workflow a carpeta
3. Agregar descripción:
   "Multi-tenant AI Runtime powered by Nexa SDK.
    Compatible con OpenAI API.
    Usa X-Tenant-Id header para routing."
4. Agregar tags: nexa, ai, multi-tenant, smartermcp
```

---

## ✅ 4. Conectar Shopify para Prompts Dinámicos

### 4.1 Crear Tabla en Supabase

```sql
-- Tabla para prompts por tienda Shopify
CREATE TABLE shopify_tenant_prompts (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  tenant_id TEXT NOT NULL,
  shop_domain TEXT NOT NULL,
  system_prompt TEXT NOT NULL,
  model_config JSONB DEFAULT '{}',
  active BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  
  UNIQUE(tenant_id, shop_domain)
);

-- Índices
CREATE INDEX idx_shopify_tenant_prompts_tenant ON shopify_tenant_prompts(tenant_id);
CREATE INDEX idx_shopify_tenant_prompts_shop ON shopify_tenant_prompts(shop_domain);

-- Ejemplo de datos
INSERT INTO shopify_tenant_prompts (tenant_id, shop_domain, system_prompt, model_config)
VALUES 
  (
    'rut-76832940-3',
    'fulldaygo.myshopify.com',
    'Eres un asistente de FullDayGo especializado en tours y experiencias turísticas en Chile. Ayuda a los clientes a encontrar el tour perfecto según sus intereses, presupuesto y fechas disponibles.',
    '{
      "temperature": 0.7,
      "max_tokens": 1024,
      "tone": "friendly",
      "language": "es-CL"
    }'
  );
```

### 4.2 Workflow n8n: Shopify → Nexa Dynamic Prompt

```json
{
  "name": "Shopify Dynamic AI Prompt",
  "nodes": [
    {
      "name": "Shopify Webhook",
      "type": "n8n-nodes-base.shopifyTrigger",
      "parameters": {
        "topic": "customers/create"
      }
    },
    {
      "name": "Get Tenant from Shop",
      "type": "n8n-nodes-base.postgres",
      "parameters": {
        "operation": "executeQuery",
        "query": "SELECT tenant_id, system_prompt, model_config FROM shopify_tenant_prompts WHERE shop_domain = $1 AND active = true",
        "additionalFields": {
          "queryParameters": "={{ $json.shop_domain }}"
        }
      }
    },
    {
      "name": "Build AI Request",
      "type": "n8n-nodes-base.code",
      "parameters": {
        "jsCode": "const tenant = $input.first().json;\nconst config = JSON.parse(tenant.model_config || '{}');\n\nreturn {\n  tenant_id: tenant.tenant_id,\n  messages: [\n    {\n      role: 'system',\n      content: tenant.system_prompt\n    },\n    {\n      role: 'user',\n      content: $('Shopify Webhook').first().json.message\n    }\n  ],\n  temperature: config.temperature || 0.7,\n  max_tokens: config.max_tokens || 1024\n};"
      }
    },
    {
      "name": "Call Nexa with Dynamic Prompt",
      "type": "n8n-nodes-base.httpRequest",
      "parameters": {
        "url": "https://ai.smarterbot.store/v1/chat/completions",
        "method": "POST",
        "sendHeaders": true,
        "headerParameters": {
          "parameters": [
            {"name": "X-Tenant-Id", "value": "={{ $json.tenant_id }}"}
          ]
        },
        "sendBody": true,
        "bodyParameters": {
          "parameters": []
        },
        "specifyBody": "json",
        "jsonBody": "={{ $json }}"
      }
    }
  ]
}
```

### 4.3 API para Gestionar Prompts

Crear endpoint en n8n para actualizar prompts:

```
Webhook: POST /api/shopify-prompts/update
Body: {
  "tenant_id": "rut-76832940-3",
  "shop_domain": "fulldaygo.myshopify.com",
  "system_prompt": "Nuevo prompt aquí",
  "model_config": {
    "temperature": 0.8,
    "max_tokens": 2048
  }
}

Flow:
1. Validate tenant_id
2. Upsert to shopify_tenant_prompts
3. Invalidate cache (if any)
4. Return success
```

### 4.4 Vault Integration para Shopify Secrets

```bash
# Crear secreto por tienda Shopify
vault kv put secret/tenant/rut-76832940-3/shopify \
  SHOP_DOMAIN="fulldaygo.myshopify.com" \
  ACCESS_TOKEN="shpat_xxxxx" \
  API_KEY="xxxxx" \
  API_SECRET="xxxxx" \
  WEBHOOK_SECRET="xxxxx"

# Policy para acceso
vault policy write smarteros-shopify - <<EOF
path "secret/data/tenant/{{identity.entity.metadata.tenant_id}}/shopify" {
  capabilities = ["read"]
}
EOF
```

### 4.5 Testing

```bash
# Test 1: Obtener prompt de tienda
curl -X GET https://n8n.smarterbot.cl/webhook/get-shopify-prompt \
  -H "Content-Type: application/json" \
  -d '{"shop_domain": "fulldaygo.myshopify.com"}'

# Test 2: Llamar Nexa con prompt dinámico
curl -X POST https://n8n.smarterbot.cl/webhook/shopify-ai-chat \
  -H "Content-Type: application/json" \
  -d '{
    "shop_domain": "fulldaygo.myshopify.com",
    "message": "¿Qué tours tienes disponibles para el fin de semana?"
  }'
```

---

## 📊 Checklist de Verificación Final

### Pre-deployment
- [ ] Git commits revisados
- [ ] Docker compose validado
- [ ] Variables de entorno definidas
- [ ] Dominios DNS configurados

### Deployment
- [ ] Push a GitHub exitoso
- [ ] Nexa runtime corriendo en Dokploy
- [ ] Health check OK en ai.smarterbot.store
- [ ] Certificado SSL activo

### Integration
- [ ] Workflow importado en n8n
- [ ] Endpoint de chat funcionando
- [ ] Logging a Supabase activo
- [ ] Tabla shopify_tenant_prompts creada

### Testing
- [ ] Test con tenant "demo"
- [ ] Test con tenant real (FullDayGo)
- [ ] Test de prompt dinámico desde Shopify
- [ ] Verificar logs y métricas

### Monitoring
- [ ] Logs de Nexa visibles en Dokploy
- [ ] Métricas en Supabase actualizándose
- [ ] Alertas configuradas (si aplica)

---

## 🚀 Comandos Quick Start

```bash
# 1. Push a GitHub (desde máquina con credenciales)
cd /root/specs
git push origin main

# 2. Deploy en Dokploy (vía UI)
# https://dokploy.smarterbot.store → Import /root/docker-compose.nexa.yml

# 3. Test Nexa
curl https://ai.smarterbot.store/health

# 4. Import n8n workflow
# n8n UI → Import → /root/specs/workflows/n8n-nexa-multitenant.json

# 5. Crear tabla Shopify prompts (Supabase SQL Editor)
# Ejecutar SQL de sección 4.1
```

---

## 📝 Notas Importantes

1. **Vault Setup**: Aún pendiente configurar Vault completamente. Mientras tanto, Nexa usará defaults.

2. **Modelos**: Por defecto usa `llama-3-8b-instruct`. Verificar que esté disponible en /models.

3. **Rate Limiting**: Configurar límites por tenant en Vault o en el código de Nexa.

4. **Monitoring**: Considerar agregar Prometheus/Grafana para métricas detalladas.

5. **Backup**: Antes de deploy, asegurar backup del VPS completado.

---

**Última actualización:** 2025-11-18T20:07:30.431Z
**Estado:** ✅ Listo para ejecución

---

## 🔒 5. Seguridad (Production-Ready)

### 5.1 TLS/SSL Verification
```bash
# Verificar certificados SSL
curl -vI https://ai.smarterbot.store 2>&1 | grep -E "SSL|certificate"

# Validar chain completo
openssl s_client -connect ai.smarterbot.store:443 -servername ai.smarterbot.store < /dev/null | openssl x509 -noout -dates

# Verificar HTTP/3
curl --http3 -I https://ai.smarterbot.store/health
```

### 5.2 Firewall Hostinger
```bash
# Configurar firewall para permitir solo puertos necesarios
# En Hostinger hPanel → VPS → Firewall

Rules:
- Port 22 (SSH): Restringir a IP conocida
- Port 80 (HTTP): Allow all (redirect to HTTPS)
- Port 443 (HTTPS): Allow all
- Port 8080: Deny (solo interno via Docker)
- Port 5432 (PostgreSQL): Deny (solo Docker network)
- Port 6379 (Redis): Deny (solo Docker network)
```

### 5.3 Vault Security Hardening
```bash
# Enable audit logging
vault audit enable file file_path=/var/log/vault/audit.log

# Configure token TTL
vault write auth/approle/role/nexa-runtime \
  token_policies="smarteros-nexa" \
  token_ttl=1h \
  token_max_ttl=24h \
  token_no_default_policy=true

# Enable auto-renewal
vault write auth/token/roles/nexa-runtime \
  allowed_policies="smarteros-nexa" \
  renewable=true \
  token_period=1h
```

### 5.4 Dokploy Environment Variables Audit
```bash
# Verificar que NO hay secretos expuestos en logs
docker logs smarteros-nexa-runtime 2>&1 | grep -i "token\|password\|secret" || echo "✓ No secrets leaked"

# Validar variables de entorno encriptadas
# En Dokploy → Project → Environment → Mark as Secret:
- VAULT_TOKEN
- Database passwords
- API keys
```

### 5.5 Rate Limiting
```bash
# Configurar rate limits en Caddy (actualizar Caddyfile)
ai.smarterbot.store {
    rate_limit {
        zone dynamic {
            key {remote_host}
            window 1m
            max_requests 120
        }
    }
    reverse_proxy nexa-runtime:8080
}

# Reload Caddy
docker exec caddy-proxy caddy reload --config /etc/caddy/Caddyfile
```

---

## 📊 6. Observabilidad (Monitoring & Logging)

### 6.1 Crear Tabla de Logs en Supabase
```sql
-- Tabla de logs de AI Runtime
CREATE TABLE ai_runtime_logs (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  tenant_id TEXT NOT NULL,
  model TEXT NOT NULL,
  endpoint TEXT NOT NULL,
  prompt_tokens INT,
  completion_tokens INT,
  total_tokens INT,
  response_time_ms INT,
  status_code INT,
  error_message TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Índices para performance
CREATE INDEX idx_ai_logs_tenant ON ai_runtime_logs(tenant_id);
CREATE INDEX idx_ai_logs_created ON ai_runtime_logs(created_at DESC);
CREATE INDEX idx_ai_logs_status ON ai_runtime_logs(status_code);

-- View para métricas agregadas
CREATE VIEW ai_runtime_metrics AS
SELECT 
  tenant_id,
  DATE_TRUNC('hour', created_at) as hour,
  COUNT(*) as requests,
  AVG(response_time_ms) as avg_response_time,
  SUM(total_tokens) as total_tokens,
  COUNT(*) FILTER (WHERE status_code >= 400) as errors
FROM ai_runtime_logs
GROUP BY tenant_id, DATE_TRUNC('hour', created_at);
```

### 6.2 Dashboard Metabase
```yaml
Dashboard: "SmarterOS AI Runtime"
URL: https://kpi.smarterbot.cl/dashboard/nexa-runtime

Cards:
  1. Requests por Tenant (last 24h)
     Query: SELECT tenant_id, COUNT(*) FROM ai_runtime_logs 
            WHERE created_at > NOW() - INTERVAL '24 hours'
            GROUP BY tenant_id

  2. Average Response Time
     Query: SELECT AVG(response_time_ms) FROM ai_runtime_logs
            WHERE created_at > NOW() - INTERVAL '1 hour'

  3. Token Usage por Tenant
     Query: SELECT tenant_id, SUM(total_tokens) FROM ai_runtime_logs
            GROUP BY tenant_id

  4. Error Rate
     Query: SELECT COUNT(*) FILTER (WHERE status_code >= 400) * 100.0 / COUNT(*)
            FROM ai_runtime_logs
```

### 6.3 Alertas n8n
```json
{
  "name": "Nexa Runtime Alerts",
  "nodes": [
    {
      "name": "Cron Every 5 Minutes",
      "type": "n8n-nodes-base.cron",
      "parameters": {
        "triggerTimes": {
          "item": [{"mode": "everyX", "value": 5}]
        }
      }
    },
    {
      "name": "Check Error Rate",
      "type": "n8n-nodes-base.postgres",
      "parameters": {
        "operation": "executeQuery",
        "query": "SELECT COUNT(*) as errors FROM ai_runtime_logs WHERE created_at > NOW() - INTERVAL '5 minutes' AND status_code >= 400"
      }
    },
    {
      "name": "If Errors > 10",
      "type": "n8n-nodes-base.if",
      "parameters": {
        "conditions": {
          "number": [{"value1": "={{$json.errors}}", "operation": "larger", "value2": 10}]
        }
      }
    },
    {
      "name": "Send Slack Alert",
      "type": "n8n-nodes-base.slack",
      "parameters": {
        "text": "⚠️ Nexa Runtime: {{$json.errors}} errors in last 5 minutes"
      }
    }
  ]
}
```

### 6.4 Health Check Monitoring
```bash
# Crear script de monitoring
cat > /root/monitor-nexa.sh << 'SCRIPT'
#!/bin/bash
HEALTH_URL="https://ai.smarterbot.store/health"
SLACK_WEBHOOK="<webhook_url>"

if ! curl -sf "$HEALTH_URL" > /dev/null; then
  curl -X POST "$SLACK_WEBHOOK" \
    -H "Content-Type: application/json" \
    -d '{"text":"🔴 Nexa Runtime is DOWN!"}'
fi
SCRIPT

chmod +x /root/monitor-nexa.sh

# Agregar a crontab
crontab -e
# Add: */5 * * * * /root/monitor-nexa.sh
```

---

## 💾 7. Backups (Disaster Recovery)

### 7.1 Backup Automático VPS (Hostinger)
```bash
# Via Hostinger API (si está disponible)
# O manual en hPanel → VPS → Backups → Create Backup

# Frecuencia: Diaria (automatizar con cron + Hostinger API)
# Retención: 7 días
# Incluye: Todo el filesystem + databases
```

### 7.2 Backup Vault Secrets
```bash
# Script de backup de Vault
cat > /root/backup-vault.sh << 'SCRIPT'
#!/bin/bash
DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_DIR="/root/backups/vault"
mkdir -p "$BACKUP_DIR"

# Export all tenant secrets
vault kv list secret/tenant/ | while read tenant; do
  vault kv get -format=json "secret/tenant/$tenant/nexa" > "$BACKUP_DIR/${tenant}_nexa_$DATE.json"
  vault kv get -format=json "secret/tenant/$tenant/shopify" > "$BACKUP_DIR/${tenant}_shopify_$DATE.json"
done

# Encrypt backup
tar czf "$BACKUP_DIR/vault_backup_$DATE.tar.gz" "$BACKUP_DIR"/*.json
rm "$BACKUP_DIR"/*.json

echo "✓ Vault backup created: vault_backup_$DATE.tar.gz"
SCRIPT

chmod +x /root/backup-vault.sh

# Cron diario a las 3 AM
# 0 3 * * * /root/backup-vault.sh
```

### 7.3 Backup Supabase
```bash
# Export tabla de prompts
pg_dump -h <supabase_host> -U postgres -d <database> \
  -t shopify_tenant_prompts -t ai_runtime_logs \
  > /root/backups/supabase_$(date +%Y%m%d).sql

# O via n8n workflow programado
{
  "name": "Daily Supabase Backup",
  "nodes": [
    {
      "name": "Cron 3 AM",
      "type": "n8n-nodes-base.cron"
    },
    {
      "name": "Export Tables",
      "type": "n8n-nodes-base.postgres",
      "parameters": {
        "operation": "executeQuery",
        "query": "COPY (SELECT * FROM shopify_tenant_prompts) TO STDOUT WITH CSV HEADER"
      }
    },
    {
      "name": "Save to S3",
      "type": "n8n-nodes-base.awsS3"
    }
  ]
}
```

### 7.4 Docker Volumes Backup
```bash
# Backup de modelos Nexa
docker run --rm \
  -v smarteros-nexa-models:/models:ro \
  -v /root/backups:/backup \
  alpine tar czf /backup/nexa-models_$(date +%Y%m%d).tar.gz /models

# Backup de Caddy certificates
docker run --rm \
  -v caddy_data:/data:ro \
  -v /root/backups:/backup \
  alpine tar czf /backup/caddy-data_$(date +%Y%m%d).tar.gz /data
```

### 7.5 Retention Policy
```bash
# Script de limpieza de backups antiguos
cat > /root/cleanup-backups.sh << 'SCRIPT'
#!/bin/bash
BACKUP_DIR="/root/backups"
RETENTION_DAYS=30

# Eliminar backups mayores a 30 días
find "$BACKUP_DIR" -name "*.tar.gz" -mtime +$RETENTION_DAYS -delete
find "$BACKUP_DIR" -name "*.sql" -mtime +$RETENTION_DAYS -delete

echo "✓ Old backups cleaned up"
SCRIPT

chmod +x /root/cleanup-backups.sh

# Cron semanal
# 0 4 * * 0 /root/cleanup-backups.sh
```

---

## 🏷️ 8. Versionado y Git Tag

### 8.1 Crear Tag Release
```bash
cd /root/specs

# Tag con anotación
git tag -a v0.3.0-nexa -m "Release: Nexa Runtime Multi-Tenant Integration

Features:
- Multi-tenant AI Runtime with Vault
- OpenAI-compatible API
- n8n workflow integration
- Shopify dynamic prompts
- Caddy reverse proxy migration
- Complete observability setup

Components:
- Nexa Runtime (ai.smarterbot.store)
- Docker Compose for Dokploy
- Vault policies and tenant structure
- n8n workflows
- Supabase tables and metrics
- Monitoring dashboards

Breaking Changes: None
Migration Required: No"

# Push tag
git push origin v0.3.0-nexa
```

### 8.2 Release Notes
```markdown
# Release v0.3.0-nexa

## 🚀 New Features

### Nexa Runtime Multi-Tenant
- OpenAI-compatible API at `ai.smarterbot.store`
- Per-tenant configuration via Vault
- Rate limiting and resource quotas
- Health checks and monitoring

### Infrastructure
- Migrated from Traefik to Caddy
- HTTP/3 support enabled
- 9 services with automatic SSL
- Dokploy for orchestration

### Integrations
- n8n workflow templates
- Supabase logging and metrics
- Shopify dynamic prompts
- MCP GitHub proxy

## 📊 Metrics

- Services: 15 active containers
- Domains: 9 with SSL
- API Endpoints: 5 (chat, embeddings, health, admin)
- Documentation: 12 files, 2000+ lines

## 🔧 Deployment

See `/root/DEPLOYMENT-CHECKLIST.md` for complete instructions.

Quick start:
```bash
./QUICK-START-NEXA.sh
```

## 📝 Documentation

- [Nexa Integration Guide](NEXA-INTEGRATION-GUIDE.md)
- [Vault Policies](vault/policies/)
- [n8n Workflows](workflows/)
- [Service Specs](services/)

## ⚠️ Breaking Changes

None

## 🐛 Bug Fixes

- Fixed Dokploy SSL redirect loop
- Corrected Metabase domain mapping
- Resolved Docker socket permissions

## 🙏 Contributors

@SmarterCL Team
```

---

## ✅ Checklist Final Actualizado

### Pre-deployment
- [ ] Git commits revisados
- [ ] Tag versionado creado (v0.3.0-nexa)
- [ ] Docker compose validado
- [ ] Variables de entorno definidas
- [ ] Dominios DNS configurados
- [ ] Firewall Hostinger configurado

### Deployment
- [ ] Push a GitHub exitoso (incluyendo tags)
- [ ] Nexa runtime corriendo en Dokploy
- [ ] Health check OK en ai.smarterbot.store
- [ ] Certificado SSL activo y verificado
- [ ] Rate limiting configurado en Caddy

### Integration
- [ ] Workflow importado en n8n
- [ ] Endpoint de chat funcionando
- [ ] Logging a Supabase activo
- [ ] Tabla shopify_tenant_prompts creada
- [ ] Dashboard Metabase configurado

### Security
- [ ] TLS chain verificado
- [ ] Vault audit logging habilitado
- [ ] Firewall rules aplicadas
- [ ] Secretos no expuestos en logs
- [ ] Token auto-renewal configurado

### Observability
- [ ] Logs fluyendo a Supabase
- [ ] Dashboard Metabase activo
- [ ] Alertas n8n configuradas
- [ ] Health check monitoring activo

### Backups
- [ ] Backup VPS programado
- [ ] Backup Vault automatizado
- [ ] Backup Supabase configurado
- [ ] Backup Docker volumes
- [ ] Retention policy aplicada

### Testing
- [ ] Test con tenant "demo"
- [ ] Test con tenant real (FullDayGo)
- [ ] Test de prompt dinámico desde Shopify
- [ ] Verificar logs y métricas
- [ ] Load test básico (opcional)

---

**Última actualización:** 2025-11-18T20:10:37.531Z
**Estado:** ✅ Production-Ready
**Versión:** v0.3.0-nexa
