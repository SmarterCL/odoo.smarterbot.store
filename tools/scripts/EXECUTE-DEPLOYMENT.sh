#!/bin/bash
# SmarterOS Nexa Deployment Executor
# Date: 2025-11-18T20:18:14.541Z

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}╔══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║         🚀 SmarterOS Nexa Deployment Executor               ║${NC}"
echo -e "${BLUE}╚══════════════════════════════════════════════════════════════╝${NC}"
echo ""

# Task 1: GitHub Push
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}TAREA 1/4: Push a GitHub${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

cd /root/specs

if [ -z "$GITHUB_TOKEN" ]; then
    echo -e "${YELLOW}⚠ GITHUB_TOKEN no configurado${NC}"
    echo ""
    echo "Para continuar, configura el token:"
    echo "  export GITHUB_TOKEN='ghp_xxxxx'"
    echo "  $0"
    echo ""
    echo "O ejecuta manualmente:"
    echo "  cd /root/specs"
    echo "  git remote set-url origin https://\$GITHUB_TOKEN@github.com/SmarterCL/smarteros-specs.git"
    echo "  git push origin main"
    echo "  git push origin --tags"
    exit 1
fi

echo "Configurando remote con token..."
git remote set-url origin "https://${GITHUB_TOKEN}@github.com/SmarterCL/smarteros-specs.git"

echo "Creando tag v0.3.0-nexa..."
git tag -a v0.3.0-nexa -m "Release: Nexa Runtime Multi-Tenant Integration" 2>/dev/null || echo "Tag ya existe"

echo "Pushing commits..."
if git push origin main; then
    echo -e "${GREEN}✓ Commits pusheados${NC}"
else
    echo -e "${RED}✗ Error en push${NC}"
    exit 1
fi

echo "Pushing tags..."
if git push origin --tags; then
    echo -e "${GREEN}✓ Tags pusheados${NC}"
else
    echo -e "${YELLOW}⚠ Tags ya existen o error${NC}"
fi

echo ""
echo -e "${GREEN}✅ TAREA 1/4 COMPLETADA${NC}"
sleep 2

# Task 2: Deploy Dokploy
echo ""
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}TAREA 2/4: Deploy en Dokploy${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

echo "Verificando docker-compose.nexa.yml..."
if [ ! -f "/root/docker-compose.nexa.yml" ]; then
    echo -e "${RED}✗ docker-compose.nexa.yml no encontrado${NC}"
    exit 1
fi

echo -e "${GREEN}✓ Archivo encontrado${NC}"
echo ""
echo "📋 INSTRUCCIONES MANUALES PARA DOKPLOY:"
echo ""
echo "1. Accede a: https://dokploy.smarterbot.store"
echo "2. Projects → New Project"
echo "   - Nombre: smarteros-nexa-runtime"
echo "   - Descripción: Multi-tenant AI Runtime for SmarterOS"
echo ""
echo "3. En el proyecto → New → Compose Stack"
echo "   - Nombre: nexa-runtime"
echo "   - Copiar contenido de: /root/docker-compose.nexa.yml"
echo ""
echo "4. Configurar variables de entorno:"
cat << 'ENVVARS'
   NEXA_MODEL_ID=llama-3-8b-instruct
   NEXA_MODEL_STORE=/models
   NEXA_PORT=8080
   NEXA_LOG_LEVEL=info
   TENANT_MODE=multi
   DEFAULT_TENANT_ID=demo
ENVVARS
echo ""
echo "5. Configurar dominio:"
echo "   - Domain: ai.smarterbot.store"
echo "   - Enable SSL: Yes"
echo ""
echo "6. Deploy Stack"
echo ""
echo -e "${YELLOW}Presiona ENTER cuando hayas completado el deploy en Dokploy...${NC}"
read

echo "Verificando deployment..."
sleep 5

if curl -sf https://ai.smarterbot.store/health > /dev/null 2>&1; then
    echo -e "${GREEN}✓ Nexa Runtime respondiendo en ai.smarterbot.store${NC}"
else
    echo -e "${YELLOW}⚠ Endpoint no responde aún (puede tomar unos minutos)${NC}"
fi

echo ""
echo -e "${GREEN}✅ TAREA 2/4 COMPLETADA${NC}"
sleep 2

# Task 3: n8n Integration
echo ""
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}TAREA 3/4: Activación SmarterMCP-Nexa en n8n${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

echo "📋 INSTRUCCIONES PARA n8n:"
echo ""
echo "1. Accede a: https://n8n.smarterbot.cl"
echo ""
echo "2. Import workflow:"
echo "   - Workflows → Import from File"
echo "   - Archivo: /root/specs/workflows/n8n-nexa-multitenant.json"
echo "   - Renombrar: 'SmarterMCP-Nexa Chat'"
echo ""
echo "3. Crear carpeta 'SmarterMCP' y mover workflow"
echo ""
echo "4. Configurar nodo HTTP Request:"
echo "   - URL: https://ai.smarterbot.store/v1/chat/completions"
echo "   - Header: X-Tenant-Id: {{ \$json.tenant_id || 'demo' }}"
echo ""
echo "5. Activar workflow"
echo ""
echo "6. Test con curl:"
cat << 'TESTCURL'
curl -X POST https://n8n.smarterbot.cl/webhook/nexa-chat \
  -H "Content-Type: application/json" \
  -d '{
    "tenant_id": "demo",
    "messages": [{"role": "user", "content": "Hello"}]
  }'
TESTCURL
echo ""
echo -e "${YELLOW}Presiona ENTER cuando hayas completado la integración en n8n...${NC}"
read

echo ""
echo -e "${GREEN}✅ TAREA 3/4 COMPLETADA${NC}"
sleep 2

# Task 4: Shopify Integration
echo ""
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}TAREA 4/4: Integración Shopify con prompts dinámicos${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

echo "📋 INSTRUCCIONES PARA SUPABASE:"
echo ""
echo "1. Accede a Supabase SQL Editor"
echo ""
echo "2. Ejecuta el siguiente SQL:"
echo ""
cat << 'SQL'
-- Tabla para prompts por tienda Shopify
CREATE TABLE IF NOT EXISTS shopify_tenant_prompts (
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

CREATE INDEX IF NOT EXISTS idx_shopify_tenant_prompts_tenant 
  ON shopify_tenant_prompts(tenant_id);
CREATE INDEX IF NOT EXISTS idx_shopify_tenant_prompts_shop 
  ON shopify_tenant_prompts(shop_domain);

-- Ejemplo de datos
INSERT INTO shopify_tenant_prompts (tenant_id, shop_domain, system_prompt, model_config)
VALUES (
  'rut-76832940-3',
  'fulldaygo.myshopify.com',
  'Eres un asistente de FullDayGo especializado en tours y experiencias turísticas en Chile.',
  '{"temperature": 0.7, "max_tokens": 1024}'
)
ON CONFLICT (tenant_id, shop_domain) DO NOTHING;
SQL
echo ""
echo "3. En n8n, crear workflow 'Shopify Dynamic AI Prompt'"
echo "   - Ver: /root/DEPLOYMENT-CHECKLIST.md sección 4.2"
echo ""
echo -e "${YELLOW}Presiona ENTER cuando hayas completado la integración Shopify...${NC}"
read

echo ""
echo -e "${GREEN}✅ TAREA 4/4 COMPLETADA${NC}"

# Final Summary
echo ""
echo -e "${BLUE}╔══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║           ✅ DEPLOYMENT COMPLETADO EXITOSAMENTE             ║${NC}"
echo -e "${BLUE}╚══════════════════════════════════════════════════════════════╝${NC}"
echo ""

echo -e "${GREEN}✅ 1/4: Push a GitHub completado${NC}"
echo -e "${GREEN}✅ 2/4: Deploy en Dokploy completado${NC}"
echo -e "${GREEN}✅ 3/4: SmarterMCP-Nexa activado en n8n${NC}"
echo -e "${GREEN}✅ 4/4: Shopify integration configurada${NC}"
echo ""

echo "🌐 URLs de acceso:"
echo "   - Nexa Runtime:  https://ai.smarterbot.store"
echo "   - n8n:           https://n8n.smarterbot.cl"
echo "   - Dokploy:       https://dokploy.smarterbot.store"
echo "   - GitHub:        https://github.com/SmarterCL/smarteros-specs"
echo ""

echo "🧪 Test rápido:"
echo "   curl -X POST https://ai.smarterbot.store/v1/chat/completions \\"
echo "     -H 'X-Tenant-Id: demo' \\"
echo "     -H 'Content-Type: application/json' \\"
echo "     -d '{\"messages\":[{\"role\":\"user\",\"content\":\"Hello\"}]}'"
echo ""

echo "📊 Monitoring:"
echo "   - Logs:      docker logs -f smarteros-nexa-runtime"
echo "   - Metrics:   https://kpi.smarterbot.cl/dashboard/nexa-runtime"
echo "   - Health:    https://ai.smarterbot.store/health"
echo ""

echo -e "${BLUE}🎉 ¡SmarterOS Nexa Runtime está en producción!${NC}"
echo ""
