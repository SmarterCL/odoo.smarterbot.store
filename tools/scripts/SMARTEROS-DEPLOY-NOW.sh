#!/bin/bash
set -e

echo "🔥 SMARTEROS 1.0 - FULL DEPLOYMENT SCRIPT 🔥"
echo "============================================="
echo ""

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Function to check service
check_service() {
    local name=$1
    local url=$2
    echo -n "Checking $name... "
    if curl -s -o /dev/null -w "%{http_code}" "$url" | grep -q "200\|302\|301"; then
        echo -e "${GREEN}✅ OK${NC}"
        return 0
    else
        echo -e "${RED}❌ DOWN${NC}"
        return 1
    fi
}

echo "📋 PASO 1: Verificar servicios backend"
echo "======================================="
docker ps --format "table {{.Names}}\t{{.Status}}" | grep -E "odoo|chatwoot|metabase|caddy|dokploy"
echo ""

echo "📋 PASO 2: Verificar conectividad"
echo "=================================="
check_service "Odoo ERP" "https://odoo.smarterbot.cl/web/login" || true
check_service "API Gateway" "https://api.smarterbot.cl/docs" || true
check_service "Chatwoot" "https://chatwoot.smarterbot.cl" || true
check_service "Metabase" "https://metabase.smarterbot.cl" || true
check_service "BlogBowl" "https://mkt.smarterbot.cl" || true
check_service "Dokploy" "https://dokploy.smarterbot.store" || true
echo ""

echo "📋 PASO 3: Verificar documentación"
echo "==================================="
ls -lh /root/*.md | grep -E "INSTALL|DEPLOYMENT|ABOUT|DOCUMENTACION" || true
echo ""

echo "📋 PASO 4: Estado de contenedores"
echo "=================================="
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" | head -15
echo ""

echo "🎉 DEPLOYMENT CHECK COMPLETO"
echo "============================"
echo ""
echo "Siguiente paso: Configurar Clerk SSO"
echo "1. Obtener credentials de dashboard.clerk.com"
echo "2. Ejecutar: export CLERK_PUBLISHABLE_KEY='...'"
echo "3. Ejecutar: export CLERK_SECRET_KEY='...'"
echo "4. Reiniciar servicios"
echo ""
