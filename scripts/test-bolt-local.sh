#!/bin/bash
#
# Bolt Lab - Local Test Script
# Purpose: Validate Bolt container builds and runs locally before VPS deployment
# Usage: ./test-bolt-local.sh
#

set -e

echo "======================================"
echo "🧪 Bolt Lab - Local Test"
echo "======================================"
echo

# Check if we're in the right directory
if [ ! -f "smarterbolt-lab.yml" ]; then
    echo "❌ Error: smarterbolt-lab.yml not found"
    echo "   Please run this script from /Users/mac/dev/2025/"
    exit 1
fi

# Check required files
echo "📋 Checking required files..."
required_files=(
    "docker/BoltLab.Dockerfile"
    "docker/requirements-bolt.txt"
    "specs/versions.lock"
    "specs/os.md"
    "specs/BRANDING.md"
    "scripts/birth_of_bolt.py"
)

for file in "${required_files[@]}"; do
    if [ -f "$file" ]; then
        echo "   ✅ $file"
    else
        echo "   ❌ Missing: $file"
        exit 1
    fi
done

echo

# Check for OPENAI_API_KEY
if [ -z "$OPENAI_API_KEY" ]; then
    echo "⚠️  OPENAI_API_KEY not set in environment"
    echo "   Bolt will not be able to generate docs without it"
    echo
    read -p "Continue anyway? (y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

# Build the container
echo "🏗️  Building Bolt Lab container..."
docker compose -f smarterbolt-lab.yml build

echo
echo "✅ Build successful!"
echo

# Start the container
echo "🚀 Starting Bolt Lab container..."
docker compose -f smarterbolt-lab.yml up -d

echo
echo "✅ Container started!"
echo

# Wait for container to be ready
echo "⏳ Waiting for container to be ready..."
sleep 3

# Check container status
if docker ps | grep -q smarterbolt-lab; then
    echo "✅ Container is running"
else
    echo "❌ Container failed to start"
    docker logs smarterbolt-lab
    exit 1
fi

echo
echo "======================================"
echo "✅ Local Test Complete"
echo "======================================"
echo
echo "📌 Next steps:"
echo
echo "1. Enter container:"
echo "   docker exec -it smarterbolt-lab bash"
echo
echo "2. Run Bolt inside container:"
echo "   python /root/smarteros/scripts/birth_of_bolt.py"
echo
echo "3. Check generated docs:"
echo "   ls -la /root/smarteros/docs/"
echo
echo "4. View docs on host:"
echo "   ls -la ./docs/"
echo
echo "5. Stop container:"
echo "   docker compose -f smarterbolt-lab.yml down"
echo
