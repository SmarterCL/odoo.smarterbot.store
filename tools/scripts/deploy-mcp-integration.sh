#!/bin/bash
# Deploy MCP Integration Layer

set -e

echo "🔥 Deploying SmarterOS MCP Integration Layer"
echo ""

# Check if network exists
if ! docker network inspect smarteros-network >/dev/null 2>&1; then
  echo "Creating smarteros-network..."
  docker network create smarteros-network
fi

# Check environment file
if [ ! -f "/root/smarteros-engine/.env" ]; then
  echo "⚠️  .env file not found. Creating from example..."
  cp /root/smarteros-engine/.env.example /root/smarteros-engine/.env
  echo "⚠️  Please edit /root/smarteros-engine/.env with your credentials"
  exit 1
fi

# Create data directories
echo "Creating data directories..."
mkdir -p /root/smarteros-engine/data/{security-cache,db-cache,engine-logs,engine-cache}
mkdir -p /root/smarteros-engine/secrets

# Build and start services
echo "Building and starting MCP services..."
cd /root
docker-compose -f docker-compose-mcp-integration.yml up -d --build

echo ""
echo "✅ MCP Integration Layer deployed!"
echo ""
echo "Services:"
echo "  • MCP Engine: http://localhost:8100"
echo "  • MCP Console: http://localhost:3100"
echo ""
echo "Check status:"
echo "  docker-compose -f docker-compose-mcp-integration.yml ps"
echo ""
echo "View logs:"
echo "  docker-compose -f docker-compose-mcp-integration.yml logs -f smarteros-engine"
echo ""
echo "Test health:"
echo "  curl http://localhost:8100/health"
echo ""
