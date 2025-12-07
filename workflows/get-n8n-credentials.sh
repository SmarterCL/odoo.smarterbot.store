#!/bin/bash
# 🔐 N8N Credentials Setup Helper
# Obtiene credenciales de Vault y las prepara para N8N

set -e

echo "🔐 Obteniendo credenciales de Vault para N8N..."
echo ""

# Verificar que Vault CLI esté disponible
if ! command -v vault &> /dev/null; then
    echo "❌ Vault CLI no está instalado"
    echo "Instalar con: brew install vault"
    exit 1
fi

# Verificar que VAULT_ADDR y VAULT_TOKEN estén configurados
if [ -z "$VAULT_ADDR" ] || [ -z "$VAULT_TOKEN" ]; then
    echo "⚠️  Variables de entorno no configuradas"
    echo ""
    echo "Configura:"
    echo "  export VAULT_ADDR=https://vault.smarterbot.cl"
    echo "  export VAULT_TOKEN=hvs.XXXXXXXXXXXX"
    exit 1
fi

echo "✅ Vault configurado: $VAULT_ADDR"
echo ""

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# 1. OpenAI Credentials
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

echo "📝 1. OpenAI API Key"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

OPENAI_DATA=$(vault kv get -format=json smarteros/mcp/openai 2>/dev/null)

if [ $? -eq 0 ]; then
    OPENAI_API_KEY=$(echo "$OPENAI_DATA" | jq -r '.data.data.api_key')
    OPENAI_ORG_ID=$(echo "$OPENAI_DATA" | jq -r '.data.data.organization_id // "N/A"')
    
    echo "API Key: ${OPENAI_API_KEY:0:20}... (${#OPENAI_API_KEY} chars)"
    echo "Org ID: $OPENAI_ORG_ID"
    echo ""
    echo "📋 Configurar en N8N:"
    echo "  Credentials → Add Credential → OpenAI"
    echo "  API Key: $OPENAI_API_KEY"
    [ "$OPENAI_ORG_ID" != "N/A" ] && echo "  Organization ID: $OPENAI_ORG_ID"
    echo ""
else
    echo "❌ No se encontró smarteros/mcp/openai en Vault"
    echo ""
fi

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# 2. Google Gemini Credentials
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

echo "📝 2. Google Gemini API Key"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

GEMINI_DATA=$(vault kv get -format=json smarteros/mcp/gemini 2>/dev/null)

if [ $? -eq 0 ]; then
    GEMINI_API_KEY=$(echo "$GEMINI_DATA" | jq -r '.data.data.api_key')
    
    echo "API Key: ${GEMINI_API_KEY:0:20}... (${#GEMINI_API_KEY} chars)"
    echo ""
    echo "📋 Configurar en N8N:"
    echo "  Credentials → Add Credential → Google Gemini"
    echo "  API Key: $GEMINI_API_KEY"
    echo ""
else
    echo "❌ No se encontró smarteros/mcp/gemini en Vault"
    echo ""
fi

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# 3. SmarterMCP Server Token
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

echo "📝 3. SmarterMCP Auth Token"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

SMARTERMCP_DATA=$(vault kv get -format=json smarteros/mcp/smartermcp 2>/dev/null)

if [ $? -eq 0 ]; then
    SMARTERMCP_TOKEN=$(echo "$SMARTERMCP_DATA" | jq -r '.data.data.auth_token // .data.data.api_token')
    SMARTERMCP_URL=$(echo "$SMARTERMCP_DATA" | jq -r '.data.data.server_url // "http://smarter-mcp:3000"')
    
    echo "Auth Token: ${SMARTERMCP_TOKEN:0:20}... (${#SMARTERMCP_TOKEN} chars)"
    echo "Server URL: $SMARTERMCP_URL"
    echo ""
    echo "📋 Configurar en N8N:"
    echo "  Credentials → Add Credential → HTTP Header Auth"
    echo "  Name: SmarterMCP Auth Token"
    echo "  Header Name: X-MCP-Token"
    echo "  Header Value: $SMARTERMCP_TOKEN"
    echo ""
    echo "  Settings → Variables → Add Variable"
    echo "  SMARTER_MCP_SERVER=$SMARTERMCP_URL"
    echo ""
else
    echo "⚠️  No se encontró smarteros/mcp/smartermcp en Vault"
    echo "   Usando valor por defecto"
    echo ""
    echo "📋 Configurar manualmente:"
    echo "  Server URL: http://smarter-mcp:3000"
    echo "  Token: [Generar nuevo token en SmarterMCP]"
    echo ""
fi

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# 4. Vault Token (para Save Log via MCP)
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

echo "📝 4. Vault Token (para logs)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

echo "Token actual: ${VAULT_TOKEN:0:20}... (${#VAULT_TOKEN} chars)"
echo ""
echo "📋 Configurar en N8N:"
echo "  Credentials → Add Credential → HTTP Header Auth"
echo "  Name: Vault Token"
echo "  Header Name: X-Vault-Token"
echo "  Header Value: $VAULT_TOKEN"
echo ""
echo "  Settings → Variables → Add Variable"
echo "  VAULT_ADDR=$VAULT_ADDR"
echo ""

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Summary
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ Resumen de credenciales obtenidas"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Total credenciales en Vault:"
[ ! -z "$OPENAI_API_KEY" ] && echo "  ✅ OpenAI API Key"
[ ! -z "$GEMINI_API_KEY" ] && echo "  ✅ Google Gemini API Key"
[ ! -z "$SMARTERMCP_TOKEN" ] && echo "  ✅ SmarterMCP Auth Token"
echo "  ✅ Vault Token (de env)"
echo ""
echo "🔗 Siguiente paso:"
echo "  1. Ir a https://n8n.smarterbot.cl/workflow/BWdJF4keyeKKIfaS"
echo "  2. Click en cada nodo con icono de llave 🔑"
echo "  3. Agregar las credenciales copiadas arriba"
echo "  4. Activar el workflow"
echo ""

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Export para uso en scripts
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

echo "💾 Exportando variables (para copiar/pegar):"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
[ ! -z "$OPENAI_API_KEY" ] && echo "export OPENAI_API_KEY='$OPENAI_API_KEY'"
[ ! -z "$GEMINI_API_KEY" ] && echo "export GEMINI_API_KEY='$GEMINI_API_KEY'"
[ ! -z "$SMARTERMCP_TOKEN" ] && echo "export SMARTERMCP_TOKEN='$SMARTERMCP_TOKEN'"
[ ! -z "$SMARTERMCP_URL" ] && echo "export SMARTER_MCP_SERVER='$SMARTERMCP_URL'"
echo "export VAULT_TOKEN='$VAULT_TOKEN'"
echo "export VAULT_ADDR='$VAULT_ADDR'"
echo ""
