#!/bin/bash

echo "🔧 Fixing api.smarterbot.cl redirect loop"
echo "==========================================="
echo ""

# Backup current config
docker exec traefik-api-gateway cp /etc/traefik/dynamic.yml /etc/traefik/dynamic.yml.bak

# Add default root router for api.smarterbot.cl
docker exec traefik-api-gateway sh -c 'cat >> /etc/traefik/dynamic.yml << "EOFDYNAMIC"

    # API Gateway - Root/Default
    api-root:
      rule: "Host(\`api.smarterbot.cl\`, \`api.smarterbot.store\`)"
      service: api-info
      priority: 1
      entryPoints:
        - websecure
      tls:
        certResolver: letsencrypt
      middlewares:
        - security-headers

  services:
    api-info:
      loadBalancer:
        servers:
          - url: "http://vault-auth-validator:8080"
    
    dokploy:
      loadBalancer:
        servers:
          - url: "http://dokploy:3000"
    
    n8n:
      loadBalancer:
        servers:
          - url: "http://smarter-n8n:5678"
    
    chatwoot:
      loadBalancer:
        servers:
          - url: "http://smarter-chatwoot:3000"
EOFDYNAMIC
'

# Restart Traefik to apply changes
echo "Restarting Traefik..."
docker restart traefik-api-gateway

sleep 5

echo ""
echo "✅ Configuration updated!"
echo ""
echo "Testing api.smarterbot.cl..."
curl -I https://api.smarterbot.cl 2>&1 | head -10

