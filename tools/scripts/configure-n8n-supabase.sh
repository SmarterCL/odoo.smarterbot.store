#!/bin/bash
# Configurar credenciales de Supabase en N8N
# Fecha: 2025-11-25

set -e

echo "🔐 Configurando credenciales Supabase para N8N..."

# Colores
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Verificar que existe el archivo de secrets
if [ ! -f /root/vault-secrets/smarterbot-supabase.json ]; then
    echo "❌ Error: No se encuentra el archivo de credenciales Supabase"
    exit 1
fi

# Leer credenciales
SUPABASE_URL=$(jq -r '.supabase.url' /root/vault-secrets/smarterbot-supabase.json)
SERVICE_KEY=$(jq -r '.supabase.service_role_key' /root/vault-secrets/smarterbot-supabase.json)
ANON_KEY=$(jq -r '.supabase.anon_key' /root/vault-secrets/smarterbot-supabase.json)

echo -e "${GREEN}✓${NC} Credenciales leídas de vault-secrets"

# Crear archivo de environment para N8N
cat > /tmp/n8n-supabase.env << ENVFILE
# Supabase Configuration - Tenant: smarterbot
SUPABASE_URL=${SUPABASE_URL}
SUPABASE_SERVICE_KEY=${SERVICE_KEY}
SUPABASE_ANON_KEY=${ANON_KEY}
SUPABASE_PROJECT_ID=jukuyzipwgpinuhxwglr

# Vault MCP
VAULT_ADDR=http://smarteros-vault-mcp:8080
VAULT_TENANT=smarterbot
ENVFILE

echo -e "${GREEN}✓${NC} Archivo de environment generado"

# Mostrar instrucciones
cat << INSTRUCTIONS

${YELLOW}📋 INSTRUCCIONES PARA CONFIGURAR N8N:${NC}

Opción 1: Variables de Entorno (Recomendado)
--------------------------------------------
1. Copiar variables al archivo env de N8N:
   cat /tmp/n8n-supabase.env >> /vault/secrets/n8n.env

2. Reiniciar N8N:
   docker restart smarter-n8n

Opción 2: Credential en N8N UI
--------------------------------------------
1. Ir a: https://n8n.smarterbot.cl
2. Settings → Credentials → Add Credential
3. Buscar "Supabase" o "HTTP Request"
4. Configurar:
   - URL: ${SUPABASE_URL}
   - API Key: ${SERVICE_KEY}
   - Nombre: "Supabase Smarterbot"

Opción 3: Verificar Conexión
--------------------------------------------
curl ${SUPABASE_URL}/rest/v1/ \
  -H "apikey: ${SERVICE_KEY}" \
  -H "Authorization: Bearer ${SERVICE_KEY}"

${YELLOW}📖 Documentación completa:${NC}
/root/SUPABASE-N8N-CREDENTIALS-GUIDE.md

INSTRUCTIONS

echo ""
read -p "¿Deseas agregar las variables al env de N8N ahora? (s/n): " -n 1 -r
echo
if [[ $REPLY =~ ^[Ss]$ ]]; then
    # Backup del archivo actual
    if [ -f /vault/secrets/n8n.env ]; then
        cp /vault/secrets/n8n.env /vault/secrets/n8n.env.bak
        echo -e "${GREEN}✓${NC} Backup creado: /vault/secrets/n8n.env.bak"
    fi
    
    # Agregar variables
    cat /tmp/n8n-supabase.env >> /vault/secrets/n8n.env
    echo -e "${GREEN}✓${NC} Variables agregadas a /vault/secrets/n8n.env"
    
    echo ""
    read -p "¿Reiniciar N8N para aplicar cambios? (s/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Ss]$ ]]; then
        docker restart smarter-n8n
        echo -e "${GREEN}✓${NC} N8N reiniciado"
        sleep 5
        echo ""
        echo "Verificando N8N..."
        docker logs smarter-n8n --tail 20
    fi
fi

echo ""
echo -e "${GREEN}✅ Configuración completada${NC}"
echo ""
