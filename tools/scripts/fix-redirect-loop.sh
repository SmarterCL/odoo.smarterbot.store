#!/bin/bash

echo "🔧 Fixing redirect loop for api.smarterbot.cl"
echo "================================================"
echo ""

# Stop Traefik (causing conflict with Caddy)
echo "1. Stopping Traefik..."
docker stop traefik-api-gateway

# Check if API service is running
echo "2. Checking API service..."
docker ps | grep -E "api|fastapi|smarteros" || echo "⚠️  No API service found"

# Restart Caddy to clear config
echo "3. Restarting Caddy..."
docker restart caddy-proxy

# Wait for Caddy
sleep 5

# Test api.smarterbot.cl
echo "4. Testing api.smarterbot.cl..."
curl -I http://localhost 2>&1 | head -5

echo ""
echo "✅ Done!"
echo ""
echo "📋 Next steps:"
echo "1. Verify Caddy config has api.smarterbot.cl"
echo "2. Check: curl -I http://api.smarterbot.cl"
echo "3. If still issues, check Caddyfile"
