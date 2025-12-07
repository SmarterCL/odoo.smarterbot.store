# 🚀 N8N MCP Integration - Deployment Guide

## Arquitectura Implementada: DUAL MCP

```
┌─────────────────────────────────────────────────────────────┐
│                     SmarterMCP Server                        │
│         (35 herramientas: vault, docker, supabase, etc.)     │
└────────────▲────────────────────────────────▲────────────────┘
             │                                │
             │ MCP Client                     │ MCP Server
             │ (HTTP Request Node)            │ (n8n-mcp-server)
             │                                │
┌────────────┴────────────────────────────────┴────────────────┐
│                         N8N Instance                          │
│  ┌──────────────────────────────────────────────────────┐   │
│  │         SmarterAgent MCP Native Workflow             │   │
│  │  • Webhook → Router → MCP Client/AI → Response       │   │
│  │  • OpenAI GPT-4 (código)                             │   │
│  │  • Gemini 1.5 Pro (estrategia)                       │   │
│  │  • Direct MCP tool execution                         │   │
│  └──────────────────────────────────────────────────────┘   │
└───────────────────────────────────────────────────────────────┘
```

## 🎯 Capacidades

### Dirección 1: N8N → SmarterMCP (Cliente)
- ✅ Ejecutar herramientas MCP desde workflows
- ✅ vault_read, vault_write
- ✅ docker_run, docker_stop
- ✅ supabase_query, supabase_upsert
- ✅ github_create_issue, github_create_pr
- ✅ shopify_sync_orders
- ✅ clerk_validate_session
- ✅ cloudflare_update_dns
- ✅ hostinger_create_backup

### Dirección 2: SmarterMCP → N8N (Servidor)
- ✅ list_workflows
- ✅ get_workflow
- ✅ create_workflow
- ✅ update_workflow
- ✅ execute_workflow
- ✅ get_executions
- ✅ list_credentials
- ✅ activate_workflow

## 📦 Deployment Steps

### 1. Deploy N8N MCP Server

```bash
cd /Users/mac/dev/2025/dkcompose

# Crear .env
cat > .env.n8n-mcp <<EOF
N8N_HOST=n8n.smarterbot.cl
N8N_PROTOCOL=https
N8N_API_KEY=your-n8n-api-key-here
N8N_DB_NAME=n8n
N8N_DB_USER=n8n
N8N_DB_PASSWORD=secure-password-here
N8N_ENCRYPTION_KEY=your-encryption-key-here
N8N_BASIC_AUTH_USER=admin
N8N_BASIC_AUTH_PASSWORD=secure-password-here
MCP_SERVER_PORT=3100
LOG_LEVEL=info
EOF

# Deploy
docker-compose -f n8n-mcp-server.yml up -d

# Verificar logs
docker logs -f n8n-mcp-server

# Test health
curl http://localhost:3100/health
curl http://localhost:3100/tools | jq .
```

### 2. Import Workflow to N8N

```bash
# Via UI
1. Ir a https://n8n.smarterbot.cl
2. Click "Add workflow" → "Import from File"
3. Seleccionar: smarteros-specs/workflows/smarter-agent-mcp-native.json
4. Click "Import"

# Configurar credenciales:
- "SmarterMCP Auth Token" → HTTP Header Auth
  * Header Name: X-MCP-Token
  * Header Value: [obtener de Vault]

- "OpenAI API" → OpenAI Credentials
  * API Key: [obtener de Vault: smarteros/mcp/openai]

- "Google Gemini API" → Gemini Credentials
  * API Key: [obtener de Vault: smarteros/mcp/gemini]
```

### 3. Configure Environment Variables

En N8N Settings → Environment Variables:

```bash
SMARTER_MCP_SERVER=http://smarter-mcp-server:3000
# O si SmarterMCP está en otro host:
SMARTER_MCP_SERVER=https://mcp.smarterbot.cl
```

### 4. Register N8N in MCP Registry

Agregar a `agents/mcp-registry.yml`:

```yaml
providers:
  n8n:
    tier: 5
    category: "devops"
    protocol: "mcp"
    server_url: "http://n8n-mcp-server:3100"
    vault_path: "smarteros/mcp/n8n"
    capabilities:
      - "workflow_management"
      - "execution_control"
      - "automation"
    tools:
      - list_workflows
      - create_workflow
      - update_workflow
      - execute_workflow
      - get_executions
      - list_credentials
      - activate_workflow
      - get_workflow
    tools_count: 8
    status: "active"
```

### 5. Test Integration

#### Test 1: N8N → SmarterMCP (Cliente)

```bash
# Ejecutar herramienta MCP desde workflow
curl -X POST https://n8n.smarterbot.cl/webhook/smarter-agent-mcp \
  -H "Content-Type: application/json" \
  -d '{
    "command": "execute_tool",
    "args": {
      "tool": "vault_read",
      "params": {
        "path": "smarteros/mcp/clerk"
      }
    },
    "tenant_id": "fulldaygo",
    "context": "general"
  }'

# Respuesta esperada:
{
  "command": "execute_tool",
  "tenant_id": "fulldaygo",
  "timestamp": "2025-11-17T10:30:00Z",
  "agent": "SmarterAgent-MCP-Native",
  "version": "2.0",
  "execution_path": ["mcp-direct"],
  "mcp_result": {
    "tool": "vault_read",
    "status": "success",
    "output": {
      "publishable_key": "pk_test_...",
      "secret_key": "sk_test_..."
    }
  }
}
```

#### Test 2: SmarterMCP → N8N (Servidor)

```bash
# Desde SmarterMCP CLI (cuando esté implementado)
smartermcp execute \
  --provider n8n \
  --tool list_workflows \
  --params '{"active_only": true}'

# O directo a N8N MCP Server
curl -X POST http://localhost:3100/tools/list_workflows \
  -H "Content-Type: application/json" \
  -H "X-N8N-API-Key: your-api-key" \
  -d '{
    "active_only": true,
    "tags": ["automation"]
  }'
```

#### Test 3: AI Analysis with MCP Tools

```bash
# Solicitar análisis estratégico que use herramientas MCP
curl -X POST https://n8n.smarterbot.cl/webhook/smarter-agent-mcp \
  -H "Content-Type: application/json" \
  -d '{
    "command": "analizar rendimiento backup",
    "context": "analysis",
    "tenant_id": "fulldaygo"
  }'

# Gemini analizará y sugerirá usar vault_read para obtener métricas
```

## 🔧 Troubleshooting

### N8N MCP Server no inicia

```bash
# Ver logs
docker logs n8n-mcp-server

# Verificar variables de entorno
docker exec n8n-mcp-server env | grep N8N

# Verificar conectividad a N8N
docker exec n8n-mcp-server wget -O- http://n8n:5678/healthz
```

### Workflow no puede conectarse a SmarterMCP

```bash
# Verificar que SMARTER_MCP_SERVER esté configurado
# En N8N UI: Settings → Environment Variables

# Test manual
docker exec -it n8n sh
wget -O- http://smarter-mcp-server:3000/health
```

### Credenciales no funcionan

```bash
# Obtener valores correctos de Vault
vault kv get smarteros/mcp/openai
vault kv get smarteros/mcp/gemini
vault kv get smarteros/mcp/n8n

# Actualizar en N8N UI: Credentials
```

## 📊 Monitoring

### Ver ejecuciones en N8N
- UI: https://n8n.smarterbot.cl → Executions
- Filtrar por: Workflow "SmarterAgent MCP Native"

### Ver logs en Vault
```bash
vault kv get smarteros/agents/logs/fulldaygo/2025-11-17-10
```

### Métricas
- Total executions: N8N UI → Executions → Count
- MCP tool calls: Parse logs por `execution_path: ["mcp-direct"]`
- AI model usage: Parse logs por `models_used`

## 🚀 Next Steps

1. **Deploy docker-compose** ✅ (archivo listo)
2. **Import workflow** ⏳ (manual via UI)
3. **Configure credentials** ⏳ (obtener de Vault)
4. **Test bidirectional flows** ⏳
5. **Monitor executions** ⏳
6. **Document tenant patterns** ⏳

## 📁 Files Created

- `workflows/smarter-agent-mcp-native.json` - Workflow N8N con MCP Client
- `workflows/agent-n8n-mcp.yml` - Spec completo de arquitectura dual
- `dkcompose/n8n-mcp-server.yml` - Docker compose con N8N + MCP Server
- `workflows/DEPLOY-N8N-MCP.md` - Esta guía

## 🔗 Resources

- N8N MCP Server: https://github.com/leonardsellem/n8n-mcp-server
- N8N Docs: https://docs.n8n.io
- MCP Spec: https://modelcontextprotocol.io
- SmarterOS Specs: /smarteros-specs/workflows/

---

**Última actualización:** 17 Nov 2025  
**Status:** Ready for deployment  
**Tags:** #OS #MCP-Native #Agent #Dual-Architecture
