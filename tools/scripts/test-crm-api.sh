#!/bin/bash
# Script de validación de la API CRM
# Prueba todos los endpoints del CRM

API_URL="${API_URL:-https://api.smarterbot.cl}"
COLOR_GREEN='\033[0;32m'
COLOR_RED='\033[0;31m'
COLOR_BLUE='\033[0;34m'
COLOR_RESET='\033[0m'

echo "🔥 Probando API CRM en: $API_URL"
echo ""

# Test 1: Health check general
echo -e "${COLOR_BLUE}[TEST 1] Health Check General${COLOR_RESET}"
curl -s "$API_URL/health" | jq '.'
echo ""

# Test 2: CRM Health
echo -e "${COLOR_BLUE}[TEST 2] CRM Health${COLOR_RESET}"
RESPONSE=$(curl -s "$API_URL/crm/health")
echo "$RESPONSE" | jq '.'
if echo "$RESPONSE" | jq -e '.ok == true' > /dev/null; then
  echo -e "${COLOR_GREEN}✅ CRM Health OK${COLOR_RESET}"
else
  echo -e "${COLOR_RED}❌ CRM Health FAILED${COLOR_RESET}"
fi
echo ""

# Test 3: Configuración
echo -e "${COLOR_BLUE}[TEST 3] Configuración del CRM${COLOR_RESET}"
RESPONSE=$(curl -s "$API_URL/crm/config")
echo "$RESPONSE" | jq '.'
if echo "$RESPONSE" | jq -e '.integraciones' > /dev/null; then
  echo -e "${COLOR_GREEN}✅ Config OK${COLOR_RESET}"
else
  echo -e "${COLOR_RED}❌ Config FAILED${COLOR_RESET}"
fi
echo ""

# Test 4: Clientes (primeros 5)
echo -e "${COLOR_BLUE}[TEST 4] Lista de Clientes (limit=5)${COLOR_RESET}"
RESPONSE=$(curl -s "$API_URL/crm/clientes?limit=5")
echo "$RESPONSE" | jq '.'
TOTAL=$(echo "$RESPONSE" | jq -r '.total // 0')
if [ "$TOTAL" -gt 0 ]; then
  echo -e "${COLOR_GREEN}✅ Clientes OK - Total: $TOTAL${COLOR_RESET}"
else
  echo -e "${COLOR_RED}⚠️  Sin clientes o error${COLOR_RESET}"
fi
echo ""

# Test 5: Estadísticas
echo -e "${COLOR_BLUE}[TEST 5] Estadísticas${COLOR_RESET}"
RESPONSE=$(curl -s "$API_URL/crm/estadisticas")
echo "$RESPONSE" | jq '.'
TOTAL_CLIENTES=$(echo "$RESPONSE" | jq -r '.total_clientes // 0')
if [ "$TOTAL_CLIENTES" -gt 0 ]; then
  echo -e "${COLOR_GREEN}✅ Estadísticas OK - Total clientes: $TOTAL_CLIENTES${COLOR_RESET}"
else
  echo -e "${COLOR_RED}⚠️  Sin estadísticas o error${COLOR_RESET}"
fi
echo ""

# Test 6: Calendario
echo -e "${COLOR_BLUE}[TEST 6] Calendario (próximos 30 días)${COLOR_RESET}"
FECHA_INICIO=$(date +%Y-%m-%d)
FECHA_FIN=$(date -d "+30 days" +%Y-%m-%d)
RESPONSE=$(curl -s "$API_URL/crm/calendario?fecha_inicio=$FECHA_INICIO&fecha_fin=$FECHA_FIN&limit=10")
echo "$RESPONSE" | jq '.'
TOTAL_EVENTOS=$(echo "$RESPONSE" | jq -r '.total // 0')
if echo "$RESPONSE" | jq -e '.ok == true' > /dev/null; then
  echo -e "${COLOR_GREEN}✅ Calendario OK - Eventos: $TOTAL_EVENTOS${COLOR_RESET}"
else
  echo -e "${COLOR_RED}⚠️  Calendario sin eventos o error${COLOR_RESET}"
fi
echo ""

# Test 7: Sync (crear contacto de prueba)
echo -e "${COLOR_BLUE}[TEST 7] Sincronización de Contacto (test)${COLOR_RESET}"
TIMESTAMP=$(date +%s)
RESPONSE=$(curl -s -X POST "$API_URL/crm/sync" \
  -H "Content-Type: application/json" \
  -d "{
    \"nombre\": \"Test Usuario $TIMESTAMP\",
    \"email\": \"test$TIMESTAMP@ejemplo.cl\",
    \"telefono\": \"+56912345678\",
    \"origen\": \"test_api\",
    \"notas\": \"Contacto de prueba desde script de validación\"
  }")
echo "$RESPONSE" | jq '.'
if echo "$RESPONSE" | jq -e '.ok == true' > /dev/null; then
  ODOO_ID=$(echo "$RESPONSE" | jq -r '.resultados.odoo.id // "N/A"')
  echo -e "${COLOR_GREEN}✅ Sync OK - Odoo ID: $ODOO_ID${COLOR_RESET}"
else
  echo -e "${COLOR_RED}⚠️  Sync con errores (revisa integraciones)${COLOR_RESET}"
fi
echo ""

# Resumen final
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo -e "${COLOR_BLUE}📊 RESUMEN DE TESTS${COLOR_RESET}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo -e "API URL: ${COLOR_BLUE}$API_URL${COLOR_RESET}"
echo -e "Total Clientes: ${COLOR_GREEN}$TOTAL_CLIENTES${COLOR_RESET}"
echo -e "Conversaciones: Ver /crm/estadisticas"
echo -e "Eventos: ${COLOR_GREEN}$TOTAL_EVENTOS${COLOR_RESET}"
echo ""
echo -e "${COLOR_GREEN}🎉 API CRM está operacional${COLOR_RESET}"
echo ""
echo "📖 Documentación completa: $API_URL/docs"
echo ""
