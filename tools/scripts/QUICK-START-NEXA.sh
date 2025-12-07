#!/bin/bash
# Quick Start Script for Nexa Runtime Deployment
# Date: 2025-11-18T20:07:30.431Z

set -e

echo "🚀 SmarterOS Nexa Runtime - Quick Start"
echo "======================================="
echo ""

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Step 1: Check prerequisites
echo -e "${YELLOW}[1/5] Checking prerequisites...${NC}"
if ! command -v docker &> /dev/null; then
    echo -e "${RED}✗ Docker not found${NC}"
    exit 1
fi
echo -e "${GREEN}✓ Docker installed${NC}"

if ! command -v curl &> /dev/null; then
    echo -e "${RED}✗ curl not found${NC}"
    exit 1
fi
echo -e "${GREEN}✓ curl installed${NC}"

# Step 2: Validate compose file
echo ""
echo -e "${YELLOW}[2/5] Validating docker-compose.nexa.yml...${NC}"
if [ ! -f "/root/docker-compose.nexa.yml" ]; then
    echo -e "${RED}✗ docker-compose.nexa.yml not found${NC}"
    exit 1
fi
echo -e "${GREEN}✓ Compose file found${NC}"

# Step 3: Pull/build image
echo ""
echo -e "${YELLOW}[3/5] Preparing Nexa image...${NC}"
echo "Using existing nexa-server:latest image"
if ! docker images | grep -q "nexa-server"; then
    echo -e "${RED}✗ nexa-server image not found${NC}"
    echo "Build it with: cd /root/specs/services/nexa-runtime && docker build -t nexa-server:latest ."
    exit 1
fi
echo -e "${GREEN}✓ Image ready${NC}"

# Step 4: Start service
echo ""
echo -e "${YELLOW}[4/5] Starting Nexa Runtime...${NC}"
cd /root
docker-compose -f docker-compose.nexa.yml up -d

# Wait for service
echo "Waiting for service to start..."
sleep 10

# Step 5: Verify
echo ""
echo -e "${YELLOW}[5/5] Verifying deployment...${NC}"

# Check container
if docker ps | grep -q "smarteros-nexa-runtime"; then
    echo -e "${GREEN}✓ Container running${NC}"
else
    echo -e "${RED}✗ Container not running${NC}"
    docker logs smarteros-nexa-runtime --tail 20
    exit 1
fi

# Check health
HEALTH_STATUS=$(curl -s http://localhost:8080/health | jq -r '.status' 2>/dev/null || echo "error")
if [ "$HEALTH_STATUS" = "healthy" ]; then
    echo -e "${GREEN}✓ Health check passed${NC}"
else
    echo -e "${RED}✗ Health check failed${NC}"
    exit 1
fi

# Test endpoint
TEST_RESPONSE=$(curl -s -X POST http://localhost:8080/v1/chat/completions \
  -H "X-Tenant-Id: demo" \
  -H "Content-Type: application/json" \
  -d '{"model":"llama-3-8b-instruct","messages":[{"role":"user","content":"test"}]}' \
  | jq -r '.choices[0].message.content' 2>/dev/null || echo "error")

if [ "$TEST_RESPONSE" != "error" ]; then
    echo -e "${GREEN}✓ API endpoint working${NC}"
else
    echo -e "${RED}✗ API endpoint failed${NC}"
fi

echo ""
echo "============================================"
echo -e "${GREEN}✅ Nexa Runtime deployed successfully!${NC}"
echo "============================================"
echo ""
echo "🌐 Access:"
echo "   Health: http://localhost:8080/health"
echo "   Docs:   http://localhost:8080/docs"
echo "   API:    http://localhost:8080/v1/chat/completions"
echo ""
echo "📊 Monitor:"
echo "   Logs:   docker logs -f smarteros-nexa-runtime"
echo "   Status: docker ps | grep nexa"
echo ""
echo "🔧 Next steps:"
echo "   1. Configure in Dokploy with domain ai.smarterbot.store"
echo "   2. Import workflow to n8n: /root/specs/workflows/n8n-nexa-multitenant.json"
echo "   3. Create Shopify prompts table in Supabase"
echo ""
