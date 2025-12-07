#!/bin/bash
set -e

echo "🔥 SmarterOS - Metabase v57 Upgrade Script"
echo "=========================================="
echo ""

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

# 1. Backup actual
echo -e "${BLUE}📦 Step 1: Backing up current Metabase...${NC}"
BACKUP_DATE=$(date +%Y%m%d-%H%M%S)
docker commit smarteros-metabase metabase-backup:pre-v57-$BACKUP_DATE
echo -e "${GREEN}✅ Backup created: metabase-backup:pre-v57-$BACKUP_DATE${NC}"
echo ""

# 2. Generar secret key si no existe
echo -e "${BLUE}🔐 Step 2: Generating embedding secret key...${NC}"
if ! grep -q "MB_EMBEDDING_SECRET_KEY" /root/.env 2>/dev/null; then
    SECRET=$(openssl rand -hex 32)
    echo "MB_EMBEDDING_SECRET_KEY=$SECRET" >> /root/.env
    echo -e "${GREEN}✅ Secret key generated${NC}"
else
    echo -e "${GREEN}✅ Secret key already exists${NC}"
fi
echo ""

# 3. Detener versión actual
echo -e "${BLUE}🛑 Step 3: Stopping current Metabase...${NC}"
docker stop smarteros-metabase || true
docker rename smarteros-metabase smarteros-metabase-old 2>/dev/null || true
echo -e "${GREEN}✅ Old version stopped${NC}"
echo ""

# 4. Deploy v57
echo -e "${BLUE}🚀 Step 4: Deploying Metabase v57...${NC}"
cd /root
source /root/.env
docker compose -f docker-compose-metabase-v57.yml up -d
echo -e "${GREEN}✅ Metabase v57 deployed${NC}"
echo ""

# 5. Esperar inicialización
echo -e "${BLUE}⏳ Step 5: Waiting for Metabase to start...${NC}"
sleep 30
for i in {1..30}; do
    if docker exec smarteros-metabase-v57 curl -s http://localhost:3000/api/health | grep -q "ok"; then
        echo -e "${GREEN}✅ Metabase is healthy!${NC}"
        break
    fi
    echo "Waiting... ($i/30)"
    sleep 5
done
echo ""

# 6. Verificación
echo -e "${BLUE}✅ Step 6: Verification${NC}"
echo "Health check:"
curl -s http://localhost:3000/api/health
echo ""
echo ""
echo "Container status:"
docker ps --filter "name=metabase" --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
echo ""

echo -e "${GREEN}=========================================="
echo "🎉 Metabase v57 upgrade complete!"
echo "=========================================="
echo ""
echo "Next steps:"
echo "1. Access https://kpi.smarterbot.cl"
echo "2. Go to Account Settings → Appearance"
echo "3. Set Dark mode as default"
echo ""
echo "Rollback command (if needed):"
echo "docker stop smarteros-metabase-v57 && docker rm smarteros-metabase-v57 && docker rename smarteros-metabase-old smarteros-metabase && docker start smarteros-metabase"
echo -e "${NC}"
