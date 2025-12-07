#!/bin/bash
# Bolt Lab Activation Script
# Usage: ./activate-bolt.sh YOUR_OPENAI_API_KEY

set -e

echo "╔═══════════════════════════════════════════════════════════════╗"
echo "║         🚀 BOLT LAB ACTIVATION SCRIPT                        ║"
echo "╚═══════════════════════════════════════════════════════════════╝"
echo ""

# Check if API key is provided
if [ -z "$1" ]; then
    echo "❌ ERROR: API Key not provided"
    echo ""
    echo "Usage:"
    echo "  ./activate-bolt.sh YOUR_OPENAI_API_KEY"
    echo ""
    echo "Or set environment variable:"
    echo "  export OPENAI_API_KEY='your-key'"
    echo "  ./activate-bolt.sh"
    exit 1
fi

API_KEY="$1"

# Validate API key format (basic check)
if [[ ! "$API_KEY" =~ ^sk- ]]; then
    echo "⚠️  WARNING: API key doesn't start with 'sk-'"
    echo "   Are you sure this is a valid OpenAI API key?"
    read -p "Continue anyway? (y/N) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

echo "🔑 Configuring API Key..."
export OPENAI_API_KEY="$API_KEY"

echo "🔄 Restarting Bolt Lab container..."
cd /root/smarteros
docker compose -f smarterbolt-lab.yml restart

echo "⏳ Waiting for container to be healthy..."
sleep 5

echo ""
echo "✅ Bolt Lab activated successfully!"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🚀 Ready to generate documentation!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Run Birth of Bolt:"
echo "  docker exec smarterbolt-lab python /root/smarteros/scripts/birth_of_bolt.py"
echo ""
echo "Or enter the container:"
echo "  docker exec -it smarterbolt-lab bash"
echo ""
echo "View generated docs:"
echo "  ls -la /root/smarteros/docs/"
echo ""
