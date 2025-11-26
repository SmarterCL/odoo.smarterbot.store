#!/bin/bash
#
# SMARTEROS - Vercel ENV Sync Script
# Fix app.smarterbot.cl environment variables
#
# Uso:
#   export VERCEL_TOKEN=<tu_token>
#   ./VERCEL-ENV-FIX-SCRIPT.sh
#

set -e

PROJECT="app-smarterbot-cl"
TEAM="smarter"

echo "🔧 SMARTEROS - Vercel ENV Fix"
echo "================================"
echo ""

# Verificar token
if [ -z "$VERCEL_TOKEN" ]; then
  echo "❌ Error: VERCEL_TOKEN no definido"
  echo ""
  echo "Para obtener tu token:"
  echo "1. Ve a: https://vercel.com/account/tokens"
  echo "2. Crea un nuevo token"
  echo "3. Ejecuta: export VERCEL_TOKEN=<tu_token>"
  echo "4. Vuelve a correr este script"
  exit 1
fi

echo "✅ Token encontrado"
echo ""

# Función para agregar ENV
add_env() {
  local key=$1
  local value=$2
  local env=$3
  
  echo "📝 Agregando $key para $env..."
  
  echo "$value" | vercel env add "$key" "$env" \
    --token="$VERCEL_TOKEN" \
    --scope="$TEAM" \
    --yes 2>/dev/null || echo "   ⚠️  Ya existe o error (ignorando)"
}

# === AGREGAR VARIABLES ===
echo "�� Agregando variables de entorno..."
echo ""

# NEXT_PUBLIC_DEMO_MODE
add_env "NEXT_PUBLIC_DEMO_MODE" "false" "production"
add_env "NEXT_PUBLIC_DEMO_MODE" "false" "preview"
add_env "NEXT_PUBLIC_DEMO_MODE" "false" "development"

# CLERK_COOKIE_DOMAIN
add_env "CLERK_COOKIE_DOMAIN" ".smarterbot.cl" "production"
add_env "CLERK_COOKIE_DOMAIN" ".smarterbot.cl" "preview"
add_env "CLERK_COOKIE_DOMAIN" ".smarterbot.cl" "development"

# MCP_ENABLED
add_env "MCP_ENABLED" "true" "production"
add_env "MCP_ENABLED" "true" "preview"
add_env "MCP_ENABLED" "true" "development"

# FASTAPI_URL
add_env "FASTAPI_URL" "https://api.smarterbot.cl" "production"
add_env "FASTAPI_URL" "https://api.smarterbot.cl" "preview"
add_env "FASTAPI_URL" "https://api.smarterbot.cl" "development"

echo ""
echo "⚠️  NOTA: CLERK_PUBLISHABLE_KEY debe agregarse manualmente"
echo "    Copia el valor de NEXT_PUBLIC_CLERK_PUBLISHABLE_KEY desde Vercel dashboard"
echo ""

# === ELIMINAR VARIABLES ===
echo "🗑️  Eliminando variables innecesarias..."
echo ""

vercel env rm NODE_ENV production \
  --token="$VERCEL_TOKEN" \
  --scope="$TEAM" \
  --yes 2>/dev/null || echo "✓ NODE_ENV (production) no existe o ya eliminada"

vercel env rm NODE_ENV preview \
  --token="$VERCEL_TOKEN" \
  --scope="$TEAM" \
  --yes 2>/dev/null || echo "✓ NODE_ENV (preview) no existe o ya eliminada"

vercel env rm NODE_ENV development \
  --token="$VERCEL_TOKEN" \
  --scope="$TEAM" \
  --yes 2>/dev/null || echo "✓ NODE_ENV (development) no existe o ya eliminada"

echo ""
echo "✅ Variables de entorno actualizadas"
echo ""
echo "🚀 Próximos pasos:"
echo "   1. Agregar CLERK_PUBLISHABLE_KEY manualmente en Vercel dashboard"
echo "   2. Hacer redeploy: vercel deploy --prod --token=\$VERCEL_TOKEN"
echo ""
