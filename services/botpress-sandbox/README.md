# Botpress Sandbox

Entorno local de desarrollo para agentes Botpress con soporte RAG y multi-tenant.

## 🚀 Quickstart

### 1. Levantar servicios

```bash
cd services/botpress-sandbox
docker-compose up -d
```

Esto despliega:
- **Botpress Server** (http://localhost:3010)
- **PostgreSQL 16** (localhost:5433)
- **Redis 7.2** (localhost:6380)
- **Duckling NLU** (localhost:8000)

### 2. Verificar estado

```bash
docker-compose ps
```

Deberías ver 4 contenedores en estado `Up`:
```
botpress-sandbox      botpress/server:latest   Up   0.0.0.0:3010->3000/tcp
botpress-postgres     postgres:16-alpine       Up   0.0.0.0:5433->5432/tcp
botpress-redis        redis:7.2-alpine         Up   0.0.0.0:6380->6379/tcp
botpress-duckling     rasa/duckling:latest     Up   0.0.0.0:8000->8000/tcp
```

### 3. Acceder a Botpress UI

Abrir navegador en: **http://localhost:3010**

Primera vez:
1. Crear cuenta admin (email/password)
2. Crear workspace: `smarteros-dev`
3. Crear primer bot: `triage-agent`

### 4. Configurar PostgreSQL para RAG

```bash
# Conectar a PostgreSQL
docker exec -it botpress-postgres psql -U botpress -d botpress_dev

# Habilitar pgvector extension
CREATE EXTENSION IF NOT EXISTS vector;

# Verificar
\dx vector
```

## 🧪 Test RAG

### 1. Crear knowledge base

```bash
curl -X POST http://localhost:3010/api/v1/knowledge-base \
  -H "Authorization: Bearer YOUR_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "tenant-test-kb",
    "embedding_model": "text-embedding-3-small"
  }'
```

### 2. Ingerir documento

```bash
curl -X POST http://localhost:3010/api/v1/knowledge-base/tenant-test-kb/documents \
  -H "Authorization: Bearer YOUR_API_KEY" \
  -F "file=@test-invoice.pdf" \
  -F "metadata={\"tenant_id\": \"test-tenant\", \"type\": \"invoice\"}"
```

### 3. Query semantic search

```bash
curl -X POST http://localhost:3010/api/v1/knowledge-base/tenant-test-kb/search \
  -H "Authorization: Bearer YOUR_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "query": "¿Cuánto debo?",
    "top_k": 5
  }'
```

## 📁 Estructura de Archivos

```
botpress-sandbox/
├── docker-compose.yml       # Stack completo
├── README.md               # Esta guía
├── agents/                 # Definiciones ADK (YAML)
│   ├── triage.yml         # Router agent
│   ├── billing.yml        # Specialist
│   └── support.yml        # Specialist
├── actions/               # Custom actions (TypeScript)
│   ├── execute_workflow.ts
│   ├── query_odoo.ts
│   └── send_email.ts
└── .env.example           # Environment variables template
```

## 🔧 Configuración Avanzada

### Variables de Entorno

Crear `.env` desde `.env.example`:

```bash
# Botpress License (opcional para dev)
BP_LICENSE_KEY=your_license_key

# OpenAI for RAG embeddings
OPENAI_API_KEY=sk-...

# n8n webhook integration
N8N_WEBHOOK_URL=http://host.docker.internal:5678/webhook/botpress-action
N8N_HMAC_SECRET=your_hmac_secret

# Vault integration (opcional)
VAULT_ADDR=http://vault.smarterbot.cl:8200
VAULT_TOKEN=hvs.your_token
```

### Ports

Si tienes conflictos de puertos, edita `docker-compose.yml`:

```yaml
ports:
  - "3011:3000"  # Botpress UI
  - "5434:5432"  # PostgreSQL
  - "6381:6379"  # Redis
```

## 🧹 Cleanup

### Detener servicios

```bash
docker-compose down
```

### Borrar datos (reset completo)

```bash
docker-compose down -v
# Esto elimina volumes: botpress-data, postgres-data, redis-data
```

## 📊 Monitoring

### Logs en vivo

```bash
# Todos los servicios
docker-compose logs -f

# Solo Botpress
docker-compose logs -f botpress

# Solo Postgres
docker-compose logs -f postgres
```

### Health check

```bash
# Botpress
curl http://localhost:3010/api/v1/health

# PostgreSQL
docker exec botpress-postgres pg_isready -U botpress

# Redis
docker exec botpress-redis redis-cli ping
```

## 🔗 Integración con SmarterOS

### 1. Webhook de Chatwoot → Botpress

```bash
# Configurar en Chatwoot UI:
# Settings → Integrations → Webhooks
# URL: http://localhost:3010/api/v1/chat
# Events: message_created, conversation_updated
# Secret: (obtener de Vault secret/chatwoot/hmac)
```

### 2. Botpress → n8n Action

```typescript
// actions/execute_workflow.ts
const response = await fetch('http://host.docker.internal:5678/webhook/botpress-action', {
  method: 'POST',
  headers: {
    'X-SMOS-Identity': 'smarterbotcl@gmail.com',
    'X-SMOS-HMAC': generateHMAC(payload)
  },
  body: JSON.stringify(payload)
});
```

### 3. Botpress ↔ MCP

```typescript
// actions/query_odoo.ts
const response = await fetch('http://mcp.smarterbot.cl/api/odoo/invoices', {
  method: 'GET',
  headers: {
    'X-SMOS-Identity': 'smarterbotcl@gmail.com',
    'X-SMOS-HMAC': generateHMAC({ tenant_id })
  }
});
```

## 🐛 Troubleshooting

### Error: "Database connection failed"

```bash
# Verificar Postgres está corriendo
docker-compose ps postgres

# Revisar logs
docker-compose logs postgres

# Reiniciar Postgres
docker-compose restart postgres
```

### Error: "Redis connection refused"

```bash
# Verificar Redis está corriendo
docker exec botpress-redis redis-cli ping
# Expected: PONG

# Reiniciar Redis
docker-compose restart redis
```

### Error: "Botpress UI no carga"

```bash
# Verificar contenedor está corriendo
docker-compose ps botpress

# Revisar logs para errores
docker-compose logs botpress | tail -50

# Reiniciar Botpress
docker-compose restart botpress
```

### Error: "pgvector extension not found"

```bash
# Instalar extension manualmente
docker exec -it botpress-postgres psql -U botpress -d botpress_dev -c "CREATE EXTENSION vector;"

# Verificar instalación
docker exec -it botpress-postgres psql -U botpress -d botpress_dev -c "\dx vector"
```

## 📚 Referencias

- **Botpress Docs:** https://botpress.com/docs
- **Botpress ADK:** https://github.com/botpress/adk
- **pgvector:** https://github.com/pgvector/pgvector
- **SmarterOS Spec:** [`../botpress-agent.yml`](../botpress-agent.yml)

## 🆘 Support

Issues o preguntas:
- GitHub: [SmarterCL/smarteros-specs/issues](https://github.com/SmarterCL/smarteros-specs/issues)
- Email: smarterbotcl@gmail.com
- WhatsApp: +56 9 1234 5678 (fundador)
