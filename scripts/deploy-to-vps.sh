#!/bin/bash
#
# SmarterOS VPS Deployment Script
# Purpose: Deploy Bolt Lab and core OS components to VPS
# Usage: ./deploy-to-vps.sh [VPS_IP]
#

set -e

VPS_IP="${1:-89.116.23.167}"
VPS_USER="root"
REMOTE_DIR="/root/smarteros"

echo "======================================"
echo "🚀 SmarterOS VPS Deployment"
echo "======================================"
echo
echo "Target: $VPS_USER@$VPS_IP"
echo "Remote: $REMOTE_DIR"
echo

# Check if SSH is accessible
echo "🔍 Checking SSH connectivity..."
if ! ssh -o ConnectTimeout=5 -q "$VPS_USER@$VPS_IP" exit; then
    echo "❌ Cannot connect to VPS at $VPS_IP"
    echo "   Please check:"
    echo "   - VPS is running"
    echo "   - SSH port (22) is open"
    echo "   - SSH keys are configured"
    echo "   - Firewall allows connection"
    exit 1
fi
echo "✅ SSH connection successful"
echo

# Create directory structure on VPS
echo "📁 Creating directory structure on VPS..."
ssh "$VPS_USER@$VPS_IP" "mkdir -p $REMOTE_DIR/{specs,scripts,docker,docs}"
echo "✅ Directories created"
echo

# Upload specs
echo "📤 Uploading specifications..."
rsync -avz --progress specs/ "$VPS_USER@$VPS_IP:$REMOTE_DIR/specs/"
echo "✅ Specs uploaded"
echo

# Upload scripts
echo "📤 Uploading scripts..."
rsync -avz --progress scripts/ "$VPS_USER@$VPS_IP:$REMOTE_DIR/scripts/"
ssh "$VPS_USER@$VPS_IP" "chmod +x $REMOTE_DIR/scripts/*.sh $REMOTE_DIR/scripts/*.py"
echo "✅ Scripts uploaded and made executable"
echo

# Upload Docker files
echo "📤 Uploading Docker files..."
rsync -avz --progress docker/ "$VPS_USER@$VPS_IP:$REMOTE_DIR/docker/"
echo "✅ Docker files uploaded"
echo

# Upload compose file
echo "📤 Uploading docker-compose file..."
scp smarterbolt-lab.yml "$VPS_USER@$VPS_IP:$REMOTE_DIR/"
echo "✅ Compose file uploaded"
echo

# Verify files on VPS
echo "🔍 Verifying files on VPS..."
ssh "$VPS_USER@$VPS_IP" "ls -R $REMOTE_DIR"
echo

# Check for Docker
echo "🐳 Checking Docker installation..."
if ssh "$VPS_USER@$VPS_IP" "command -v docker > /dev/null 2>&1"; then
    echo "✅ Docker is installed"
    ssh "$VPS_USER@$VPS_IP" "docker --version"
else
    echo "⚠️  Docker not found. Please install Docker first."
    echo "   Run: curl -fsSL https://get.docker.com | sh"
fi
echo

# Check for Docker Compose
echo "🐳 Checking Docker Compose..."
if ssh "$VPS_USER@$VPS_IP" "docker compose version > /dev/null 2>&1"; then
    echo "✅ Docker Compose is installed"
    ssh "$VPS_USER@$VPS_IP" "docker compose version"
else
    echo "⚠️  Docker Compose not found or outdated."
fi
echo

echo "======================================"
echo "✅ Deployment Complete"
echo "======================================"
echo
echo "📌 Next steps on VPS:"
echo
echo "1. SSH into VPS:"
echo "   ssh $VPS_USER@$VPS_IP"
echo
echo "2. Set OpenAI API key:"
echo "   export OPENAI_API_KEY='your-key-here'"
echo
echo "3. Navigate to smarteros:"
echo "   cd $REMOTE_DIR"
echo
echo "4. Build and start Bolt Lab:"
echo "   docker compose -f smarterbolt-lab.yml up -d --build"
echo
echo "5. Enter container:"
echo "   docker exec -it smarterbolt-lab bash"
echo
echo "6. Run Bolt:"
echo "   python /root/smarteros/scripts/birth_of_bolt.py"
echo
echo "7. Check generated docs:"
echo "   ls -la /root/smarteros/docs/"
echo
