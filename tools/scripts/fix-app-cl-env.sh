#!/bin/bash
set -e

echo "🔧 Arreglando app.smarterbot.cl copiando ENV de .store"
echo ""

# Variables que faltan en .cl
echo "Agregando variables faltantes..."

vercel env add NEXT_PUBLIC_DEMO_MODE production "false" \
  --scope=smarter --yes

vercel env add CLERK_COOKIE_DOMAIN production ".smarterbot.cl" \
  --scope=smarter --yes

vercel env add MCP_ENABLED production "true" \
  --scope=smarter --yes

vercel env add FASTAPI_URL production "https://api.smarterbot.cl" \
  --scope=smarter --yes

# Copiar CLERK_PUBLISHABLE_KEY (sin NEXT_PUBLIC_)
CLERK_PK=$(vercel env ls production --scope=smarter | grep NEXT_PUBLIC_CLERK_PUBLISHABLE_KEY | awk '{print $2}')
vercel env add CLERK_PUBLISHABLE_KEY production "$CLERK_PK" \
  --scope=smarter --yes

echo ""
echo "✅ Variables agregadas correctamente"
echo ""
echo "🚀 Trigger redeploy..."
vercel --prod --scope=smarter --yes

echo ""
echo "✅ Deploy iniciado. Espera 2-3 minutos."
echo "   Verifica en: https://app.smarterbot.cl/dashboard"
