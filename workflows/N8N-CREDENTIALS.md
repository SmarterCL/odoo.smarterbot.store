# 🔐 N8N Workflow Credentials Setup Guide
# Workflow: BWdJF4keyeKKIfaS (SmarterAgent)

## Credenciales Requeridas

### 1. OpenAI API
**Tipo:** OpenAI Credentials  
**Nombre sugerido:** `OpenAI API`

**Campos:**
- API Key: `[Obtener de Vault: smarteros/mcp/openai]`
- Organization ID: `[Opcional]`

**Comando Vault:**
```bash
vault kv get -field=api_key smarteros/mcp/openai
```

**Nodos que lo usan:**
- `OpenAI (Code Focus)` - Node ID: `openai-node`
- `OpenAI (Code + MCP Tools)` - Node ID: `openai-with-mcp`

---

### 2. Google Gemini API
**Tipo:** Google Gemini Credentials  
**Nombre sugerido:** `Google Gemini API`

**Campos:**
- API Key: `[Obtener de Vault: smarteros/mcp/gemini]`

**Comando Vault:**
```bash
vault kv get -field=api_key smarteros/mcp/gemini
```

**Nodos que lo usan:**
- `Gemini (Analysis Focus)` - Node ID: `gemini-node`
- `Gemini (Strategy + MCP)` - Node ID: `gemini-analysis-mcp`

---

### 3. SmarterMCP Auth Token
**Tipo:** HTTP Header Auth  
**Nombre sugerido:** `SmarterMCP Auth Token`

**Campos:**
- Header Name: `X-MCP-Token`
- Header Value: `[Obtener de Vault: smarteros/mcp/smartermcp]`

**Comando Vault:**
```bash
vault kv get -field=auth_token smarteros/mcp/smartermcp
# O si no existe, generar nuevo token en SmarterMCP
```

**Nodos que lo usan:**
- `MCP Client → SmarterMCP` - Node ID: `mcp-client-node`
- `MCP List Available Tools` - Node ID: `mcp-list-tools`
- `Save Log via MCP` - Node ID: `save-via-mcp`

---

### 4. Vault Token
**Tipo:** HTTP Header Auth  
**Nombre sugerido:** `Vault Token`

**Campos:**
- Header Name: `X-Vault-Token`
- Header Value: `[Tu VAULT_TOKEN actual]`

**Obtener:**
```bash
echo $VAULT_TOKEN
```

**Nodos que lo usan:**
- `Save to Vault` - Node ID: `save-to-vault`

---

## Variables de Entorno

Configurar en N8N → Settings → Variables:

### SMARTER_MCP_SERVER
**Valor:** URL del servidor SmarterMCP

```bash
# Opción 1: Docker interno
SMARTER_MCP_SERVER=http://smarter-mcp:3000

# Opción 2: URL pública
SMARTER_MCP_SERVER=https://mcp.smarterbot.cl

# Obtener de Vault
vault kv get -field=server_url smarteros/mcp/smartermcp
```

### VAULT_ADDR
**Valor:** URL del servidor Vault

```bash
VAULT_ADDR=https://vault.smarterbot.cl
# O usar variable de entorno actual
echo $VAULT_ADDR
```

---

## 🚀 Setup Rápido

### Script Automático

```bash
# 1. Ejecutar script de obtención
cd /Users/mac/dev/2025/smarteros-specs/workflows
chmod +x get-n8n-credentials.sh
./get-n8n-credentials.sh

# 2. El script mostrará todas las credenciales
# 3. Copiar cada valor en N8N UI
```

### Manual via UI

1. **Ir al workflow**
   ```
   https://n8n.smarterbot.cl/workflow/BWdJF4keyeKKIfaS
   ```

2. **Agregar OpenAI Credential**
   - Click en nodo "OpenAI (Code Focus)"
   - Click en "Select Credential" → "Create New"
   - Type: OpenAI
   - API Key: `[pegar valor de Vault]`
   - Save

3. **Agregar Gemini Credential**
   - Click en nodo "Gemini (Analysis Focus)"
   - Click en "Select Credential" → "Create New"
   - Type: Google Gemini
   - API Key: `[pegar valor de Vault]`
   - Save

4. **Agregar SmarterMCP Auth**
   - Click en nodo "MCP Client → SmarterMCP"
   - Click en "Select Credential" → "Create New"
   - Type: HTTP Header Auth
   - Name: `SmarterMCP Auth Token`
   - Header Name: `X-MCP-Token`
   - Header Value: `[pegar token]`
   - Save

5. **Agregar Vault Token**
   - Click en nodo "Save to Vault"
   - Click en "Select Credential" → "Create New"
   - Type: HTTP Header Auth
   - Name: `Vault Token`
   - Header Name: `X-Vault-Token`
   - Header Value: `[pegar VAULT_TOKEN]`
   - Save

6. **Configurar Variables**
   - Settings → Variables
   - Add Variable: `SMARTER_MCP_SERVER` = `http://smarter-mcp:3000`
   - Add Variable: `VAULT_ADDR` = `https://vault.smarterbot.cl`
   - Save

7. **Activar Workflow**
   - Toggle "Active" en la parte superior
   - Verificar que no haya errores de credenciales

---

## 🧪 Testing

### Test básico
```bash
# Test webhook trigger
curl -X POST https://n8n.smarterbot.cl/webhook/smarter-agent \
  -H "Content-Type: application/json" \
  -d '{
    "query": "test de conectividad",
    "context": "general",
    "tenant_id": "test"
  }'
```

### Test con MCP tool
```bash
# Test ejecución de herramienta MCP
curl -X POST https://n8n.smarterbot.cl/webhook/smarter-agent-mcp \
  -H "Content-Type: application/json" \
  -d '{
    "command": "execute_tool",
    "args": {
      "tool": "vault_read",
      "params": {"path": "smarteros/mcp/clerk"}
    },
    "tenant_id": "fulldaygo"
  }'
```

### Ver resultados
- N8N UI → Executions
- Filtrar por workflow "SmarterAgent"
- Revisar logs de cada ejecución

---

## ⚠️ Troubleshooting

### Error: "Credentials are required"
- Verificar que todas las credenciales estén configuradas
- Revisar que los nombres coincidan con los IDs de credential

### Error: "Cannot connect to MCP server"
- Verificar SMARTER_MCP_SERVER está configurado
- Test conectividad: `curl http://smarter-mcp:3000/health`

### Error: "Vault permission denied"
- Verificar que VAULT_TOKEN tenga permisos de lectura
- Test: `vault kv get smarteros/mcp/openai`

### Error: "Invalid API key"
- Verificar que las keys en Vault estén actualizadas
- Re-generar keys si es necesario

---

## 📊 Monitoring

### Ver credenciales configuradas
N8N UI → Credentials → Ver lista de todas las credenciales

### Ver ejecuciones
N8N UI → Executions → Filtrar por workflow

### Ver logs en Vault
```bash
vault kv get smarteros/agents/logs/[tenant_id]/[date]
```

---

## 🔒 Security Notes

1. **Nunca commitear credenciales** en git
2. **Rotar tokens** cada 30-60 días
3. **Usar least privilege** - solo permisos necesarios
4. **Monitorear accesos** en Vault audit logs
5. **Revocar tokens** inmediatamente si se comprometen

---

**Última actualización:** 17 Nov 2025  
**Workflow ID:** BWdJF4keyeKKIfaS  
**Status:** Ready for credentials setup
