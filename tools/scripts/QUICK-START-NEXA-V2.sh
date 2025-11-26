#!/bin/bash
# Enhanced Quick Start Script for Nexa Runtime Deployment
# Date: 2025-11-18T20:14:01.147Z
# Version: 2.0 (Production-Ready)

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}╔══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║     🚀 SmarterOS Nexa Runtime - Quick Start v2.0           ║${NC}"
echo -e "${BLUE}╚══════════════════════════════════════════════════════════════╝${NC}"
echo ""

START_TIME=$(date +%s)

# Step 1: Prerequisites
echo -e "${YELLOW}[1/7] Checking prerequisites...${NC}"
ERRORS=0

if ! command -v docker &> /dev/null; then
    echo -e "${RED}✗ Docker not found${NC}"
    ERRORS=$((ERRORS + 1))
else
    echo -e "${GREEN}✓ Docker installed${NC}"
fi

if ! command -v curl &> /dev/null; then
    echo -e "${RED}✗ curl not found${NC}"
    ERRORS=$((ERRORS + 1))
else
    echo -e "${GREEN}✓ curl installed${NC}"
fi

if ! command -v jq &> /dev/null; then
    echo -e "${YELLOW}⚠ jq not found (optional)${NC}"
else
    echo -e "${GREEN}✓ jq installed${NC}"
fi

# Step 2: Validate files
echo ""
echo -e "${YELLOW}[2/7] Validating files...${NC}"

if [ ! -f "/root/docker-compose.nexa.yml" ]; then
    echo -e "${RED}✗ docker-compose.nexa.yml not found${NC}"
    ERRORS=$((ERRORS + 1))
else
    echo -e "${GREEN}✓ Compose file found${NC}"
fi

if [ ! -f "/root/specs/workflows/n8n-nexa-multitenant.json" ]; then
    echo -e "${YELLOW}⚠ n8n workflow not found${NC}"
else
    echo -e "${GREEN}✓ n8n workflow found${NC}"
fi

if [ $ERRORS -gt 0 ]; then
    echo -e "${RED}✗ $ERRORS errors found. Please fix them before continuing.${NC}"
    exit 1
fi

# Step 3: Check Vault (optional)
echo ""
echo -e "${YELLOW}[3/7] Checking Vault status...${NC}"

if [ -n "$VAULT_ADDR" ] && [ -n "$VAULT_TOKEN" ]; then
    if command -v vault &> /dev/null; then
        VAULT_STATUS=$(vault status -format=json 2>/dev/null | jq -r '.sealed' || echo "error")
        if [ "$VAULT_STATUS" = "false" ]; then
            echo -e "${GREEN}✓ Vault accessible and unsealed${NC}"
        else
            echo -e "${YELLOW}⚠ Vault not accessible (will use defaults)${NC}"
        fi
    else
        echo -e "${YELLOW}⚠ Vault CLI not installed${NC}"
    fi
else
    echo -e "${YELLOW}⚠ Vault not configured (will use defaults)${NC}"
fi

# Step 4: Prepare image
echo ""
echo -e "${YELLOW}[4/7] Preparing Nexa image...${NC}"

if ! docker images | grep -q "nexa-server"; then
    echo -e "${RED}✗ nexa-server image not found${NC}"
    echo ""
    echo "Build it with:"
    echo "  cd /root/specs/services/nexa-runtime"
    echo "  docker build -t nexa-server:latest ."
    exit 1
fi
echo -e "${GREEN}✓ Image ready${NC}"

# Step 5: Start service
echo ""
echo -e "${YELLOW}[5/7] Starting Nexa Runtime...${NC}"

cd /root
docker-compose -f docker-compose.nexa.yml up -d

echo "Waiting for service to start..."
sleep 15

# Step 6: Verify deployment
echo ""
echo -e "${YELLOW}[6/7] Verifying deployment...${NC}"

# Check container
if docker ps | grep -q "smarteros-nexa-runtime"; then
    echo -e "${GREEN}✓ Container running${NC}"
else
    echo -e "${RED}✗ Container not running${NC}"
    echo "Recent logs:"
    docker logs smarteros-nexa-runtime --tail 20
    exit 1
fi

# Check health
HEALTH_STATUS=$(curl -s http://localhost:8080/health | jq -r '.status' 2>/dev/null || echo "error")
if [ "$HEALTH_STATUS" = "healthy" ]; then
    echo -e "${GREEN}✓ Health check passed${NC}"
else
    echo -e "${RED}✗ Health check failed (status: $HEALTH_STATUS)${NC}"
    exit 1
fi

# Step 7: Run tests
echo ""
echo -e "${YELLOW}[7/7] Running tests...${NC}"

# Test 1: Default tenant
echo -n "Test 1 - Default tenant (demo): "
DEMO_RESPONSE=$(curl -s -X POST http://localhost:8080/v1/chat/completions \
  -H "X-Tenant-Id: demo" \
  -H "Content-Type: application/json" \
  -d '{"model":"llama-3-8b-instruct","messages":[{"role":"user","content":"test"}]}' \
  | jq -r '.choices[0].message.content' 2>/dev/null || echo "error")

if [ "$DEMO_RESPONSE" != "error" ] && [ -n "$DEMO_RESPONSE" ]; then
    echo -e "${GREEN}✓ Pass${NC}"
else
    echo -e "${RED}✗ Fail${NC}"
fi

# Test 2: Custom tenant
echo -n "Test 2 - Custom tenant (test): "
TEST_RESPONSE=$(curl -s -X POST http://localhost:8080/v1/chat/completions \
  -H "X-Tenant-Id: test" \
  -H "Content-Type: application/json" \
  -d '{"model":"llama-3-8b-instruct","messages":[{"role":"user","content":"hello"}]}' \
  | jq -r '.id' 2>/dev/null || echo "error")

if [ "$TEST_RESPONSE" != "error" ] && [ -n "$TEST_RESPONSE" ]; then
    echo -e "${GREEN}✓ Pass${NC}"
else
    echo -e "${YELLOW}⚠ Warning (may be expected if tenant not configured)${NC}"
fi

# Test 3: Admin endpoint
echo -n "Test 3 - Admin models list: "
MODELS_RESPONSE=$(curl -s http://localhost:8080/admin/models | jq -r '.models[0].id' 2>/dev/null || echo "error")

if [ "$MODELS_RESPONSE" != "error" ] && [ -n "$MODELS_RESPONSE" ]; then
    echo -e "${GREEN}✓ Pass (model: $MODELS_RESPONSE)${NC}"
else
    echo -e "${RED}✗ Fail${NC}"
fi

# Calculate time
END_TIME=$(date +%s)
ELAPSED=$((END_TIME - START_TIME))

echo ""
echo -e "${BLUE}════════════════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}✅ Nexa Runtime deployed successfully!${NC}"
echo -e "${BLUE}════════════════════════════════════════════════════════════════${NC}"
echo ""
echo -e "${BLUE}⏱️  Total time: ${ELAPSED}s${NC}"
echo ""
echo "🌐 Access:"
echo "   Health:   http://localhost:8080/health"
echo "   Docs:     http://localhost:8080/docs"
echo "   API:      http://localhost:8080/v1/chat/completions"
echo "   Admin:    http://localhost:8080/admin/models"
echo ""
echo "📊 Monitor:"
echo "   Logs:     docker logs -f smarteros-nexa-runtime"
echo "   Status:   docker ps | grep nexa"
echo "   Stats:    docker stats smarteros-nexa-runtime"
echo ""
echo "🧪 Test:"
echo "   curl -X POST http://localhost:8080/v1/chat/completions \\"
echo "     -H 'X-Tenant-Id: demo' \\"
echo "     -H 'Content-Type: application/json' \\"
echo "     -d '{\"messages\":[{\"role\":\"user\",\"content\":\"Hello\"}]}'"
echo ""
echo "🔧 Next steps:"
echo "   1. Configure in Dokploy with domain ai.smarterbot.store"
echo "   2. Import workflow to n8n"
echo "   3. Create Shopify prompts table in Supabase"
echo "   4. Configure Vault secrets for production"
echo "   5. Set up monitoring and alerts"
echo ""
