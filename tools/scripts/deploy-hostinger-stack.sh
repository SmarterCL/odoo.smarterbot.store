#!/bin/bash
set -e

echo "🚀 Deploying Hostinger + Smarter Integration Stack"
echo ""

# Colores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 1. Verificar Docker
if ! command -v docker &> /dev/null; then
    echo -e "${RED}❌ Docker no está instalado${NC}"
    exit 1
fi
echo -e "${GREEN}✅ Docker OK${NC}"

# 2. Crear red smarteros
if docker network inspect smarteros &> /dev/null; then
    echo -e "${YELLOW}⚠️  Red smarteros ya existe${NC}"
else
    docker network create smarteros
    echo -e "${GREEN}✅ Red smarteros creada${NC}"
fi

# 3. Verificar .env.hostinger
if [ ! -f /root/.env.hostinger ]; then
    echo -e "${RED}❌ Falta /root/.env.hostinger${NC}"
    echo "Copia .env.hostinger y configura tus tokens"
    exit 1
fi

# Verificar que no tenga valores placeholder
if grep -q "your_hostinger_api_token_here" /root/.env.hostinger; then
    echo -e "${RED}❌ Debes configurar HOSTINGER_API_TOKEN en .env.hostinger${NC}"
    exit 1
fi
echo -e "${GREEN}✅ .env.hostinger configurado${NC}"

# 4. Levantar stack
cd /root
echo "🐳 Levantando servicios..."
docker-compose -f docker-compose-hostinger-smarter.yml --env-file .env.hostinger up -d

# 5. Esperar 10 segundos
echo "⏳ Esperando 10s para que servicios inicien..."
sleep 10

# 6. Verificar salud
echo ""
echo "🔍 Verificando servicios..."
docker ps --filter "name=hostinger-mcp" --filter "name=n8n-hostinger" --filter "name=smarter-mcp" --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"

echo ""
echo "📊 Health checks:"

# n8n
if curl -sf http://localhost:5678/healthz &> /dev/null; then
    echo -e "${GREEN}✅ n8n-hostinger: OK (http://localhost:5678)${NC}"
else
    echo -e "${YELLOW}⚠️  n8n-hostinger: No responde (puede estar iniciando)${NC}"
fi

# Smarter MCP
if curl -sf http://localhost:3001/health &> /dev/null; then
    echo -e "${GREEN}✅ smarter-mcp: OK (http://localhost:3001)${NC}"
else
    echo -e "${YELLOW}⚠️  smarter-mcp: No responde (puede estar instalando npm)${NC}"
fi

# Hostinger MCP (no tiene health endpoint, solo verificamos que corre)
if docker ps --filter "name=hostinger-mcp" --filter "status=running" | grep -q hostinger-mcp; then
    echo -e "${GREEN}✅ hostinger-mcp: Running${NC}"
else
    echo -e "${RED}❌ hostinger-mcp: No está corriendo${NC}"
fi

echo ""
echo "📋 Próximos pasos:"
echo "1. Verificar logs: docker logs smarter-mcp"
echo "2. Configurar Clerk Features en: https://dashboard.clerk.com"
echo "3. Importar repos de Hostinger a SmarterCL"
echo "4. Abrir n8n: https://n8n.smarterbot.store"
echo "5. Instalar community node: n8n-nodes-hostinger-api"
echo ""
echo "📖 Documentación completa: /root/HOSTINGER-SMARTER-INTEGRATION.md"
echo ""
echo -e "${GREEN}🎉 Stack desplegado exitosamente${NC}"
