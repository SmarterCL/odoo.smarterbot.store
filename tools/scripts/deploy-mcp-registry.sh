#!/bin/bash
# Deploy MCP Registry to mcp.smarterbot.cl
# Usage: ./deploy-mcp-registry.sh

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🚀 Deploying MCP Registry to mcp.smarterbot.cl"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Check if source exists
if [ ! -d "/root/mcp-smarterbot" ]; then
    echo -e "${RED}✗ Source directory not found: /root/mcp-smarterbot${NC}"
    exit 1
fi

echo -e "${GREEN}✓ Source directory found${NC}"
echo ""

# Create web root
WEB_ROOT="/var/www/mcp.smarterbot.cl"
echo "Creating web root: $WEB_ROOT"
sudo mkdir -p "$WEB_ROOT"
echo -e "${GREEN}✓ Web root created${NC}"
echo ""

# Copy files
echo "Copying files..."
sudo cp -r /root/mcp-smarterbot/* "$WEB_ROOT/"
sudo chown -R www-data:www-data "$WEB_ROOT" 2>/dev/null || sudo chown -R caddy:caddy "$WEB_ROOT" 2>/dev/null || true
echo -e "${GREEN}✓ Files copied${NC}"
echo ""

# Check if Caddy is installed
if command -v caddy &> /dev/null; then
    echo "Configuring Caddy..."
    
    # Backup Caddyfile
    if [ -f "/etc/caddy/Caddyfile" ]; then
        sudo cp /etc/caddy/Caddyfile /etc/caddy/Caddyfile.bak.$(date +%Y%m%d_%H%M%S)
        echo -e "${GREEN}✓ Caddyfile backed up${NC}"
    fi
    
    # Check if mcp.smarterbot.cl already configured
    if grep -q "mcp.smarterbot.cl" /etc/caddy/Caddyfile 2>/dev/null; then
        echo -e "${YELLOW}⚠ mcp.smarterbot.cl already in Caddyfile${NC}"
    else
        # Add configuration
        sudo tee -a /etc/caddy/Caddyfile > /dev/null << 'EOF'

# MCP Registry
mcp.smarterbot.cl {
  root * /var/www/mcp.smarterbot.cl
  file_server
  encode gzip
  
  header {
    X-Frame-Options "SAMEORIGIN"
    X-Content-Type-Options "nosniff"
    X-XSS-Protection "1; mode=block"
    Referrer-Policy "strict-origin-when-cross-origin"
  }
  
  log {
    output file /var/log/caddy/mcp.smarterbot.cl.log
  }
}
EOF
        echo -e "${GREEN}✓ Caddy configuration added${NC}"
    fi
    
    # Reload Caddy
    echo "Reloading Caddy..."
    sudo caddy reload --config /etc/caddy/Caddyfile 2>&1 | grep -v "admin endpoint disabled" || true
    echo -e "${GREEN}✓ Caddy reloaded${NC}"
    
elif command -v nginx &> /dev/null; then
    echo "Configuring Nginx..."
    
    # Create Nginx config
    sudo tee /etc/nginx/sites-available/mcp.smarterbot.cl > /dev/null << 'EOF'
server {
    listen 80;
    server_name mcp.smarterbot.cl;
    
    root /var/www/mcp.smarterbot.cl;
    index index.html;
    
    location / {
        try_files $uri $uri/ =404;
    }
    
    gzip on;
    gzip_types text/plain text/css application/json application/javascript text/xml application/xml application/xml+rss text/javascript;
    
    access_log /var/log/nginx/mcp.smarterbot.cl.access.log;
    error_log /var/log/nginx/mcp.smarterbot.cl.error.log;
}
EOF
    
    # Enable site
    sudo ln -sf /etc/nginx/sites-available/mcp.smarterbot.cl /etc/nginx/sites-enabled/
    
    # Test and reload
    sudo nginx -t && sudo systemctl reload nginx
    echo -e "${GREEN}✓ Nginx configured and reloaded${NC}"
    
else
    echo -e "${YELLOW}⚠ No web server detected (Caddy/Nginx)${NC}"
    echo "  Files copied to $WEB_ROOT but not served"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📊 Deployment Summary"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Web Root: $WEB_ROOT"
echo "Files:"
ls -lh "$WEB_ROOT"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🔧 Next Steps"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "1. Configure DNS:"
echo "   - Add A record: mcp.smarterbot.cl → 89.116.23.167"
echo "   - Or use Cloudflare MCP to automate"
echo ""
echo "2. Test local access:"
echo "   curl -I http://localhost/ -H 'Host: mcp.smarterbot.cl'"
echo ""
echo "3. Test public access (after DNS):"
echo "   curl -I https://mcp.smarterbot.cl"
echo ""
echo "4. Monitor logs:"
echo "   tail -f /var/log/caddy/mcp.smarterbot.cl.log"
echo ""
echo -e "${GREEN}✓ Deployment complete!${NC}"
