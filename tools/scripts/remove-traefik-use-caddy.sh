#!/bin/bash

echo "🔧 Removing Traefik and configuring Caddy only"
echo "=============================================="
echo ""

# Step 1: Stop and remove Traefik
echo "Step 1: Stopping and removing Traefik..."
docker stop traefik-api-gateway
docker rm traefik-api-gateway

echo "✅ Traefik removed"
echo ""

# Step 2: Backup current Caddyfile
echo "Step 2: Backing up Caddyfile..."
docker exec caddy-proxy cp /etc/caddy/Caddyfile /etc/caddy/Caddyfile.backup

# Step 3: Update Caddyfile for api.smarterbot.cl
echo "Step 3: Updating Caddyfile..."
docker exec caddy-proxy sh -c 'cat > /tmp/api-block.txt << "APIBLOCK"
api.smarterbot.cl, api.smarterbot.store {
    # API Gateway - proxy to Vault MCP (or your FastAPI backend)
    reverse_proxy smarteros-vault-mcp:8080 {
        header_up Host {host}
        header_up X-Real-IP {remote_host}
        header_up X-Forwarded-For {remote_host}
        header_up X-Forwarded-Proto {scheme}
    }
    
    encode gzip
    log {
        output file /var/log/caddy/api-gateway.log
    }
}
APIBLOCK
'

echo "✅ Caddyfile updated"
echo ""

# Step 4: Reload Caddy
echo "Step 4: Reloading Caddy..."
docker exec caddy-proxy caddy reload --config /etc/caddy/Caddyfile

echo "✅ Caddy reloaded"
echo ""

# Step 5: Test api.smarterbot.cl
echo "Step 5: Testing api.smarterbot.cl..."
sleep 3
curl -I https://api.smarterbot.cl

echo ""
echo "=============================================="
echo "✅ Done! Traefik removed, Caddy configured"
echo ""
echo "📋 Next steps:"
echo "1. Verify: curl https://api.smarterbot.cl"
echo "2. Check logs: docker logs caddy-proxy"
echo "3. If issues, check: docker exec caddy-proxy cat /etc/caddy/Caddyfile"

