#!/bin/bash
set -e

echo "🧪 Testing SSO Flow"
echo "===================="

# Test 1: API Gateway Health
echo "1. Testing API Gateway..."
API_HEALTH=$(curl -s http://localhost:8001/health)
echo "   API Health: $API_HEALTH"

# Test 2: Odoo SSO Endpoint
echo "2. Testing Odoo SSO endpoint..."
ODOO_SSO=$(curl -I -s http://localhost:8069/auth/clerk/login | head -1)
echo "   Odoo SSO: $ODOO_SSO"

# Test 3: Generate mock JWT
echo "3. Generating mock JWT..."
python3 << 'PYEOF'
import jwt
import json

payload = {
    "email": "test@smarterbot.cl",
    "sub": "user_test123",
    "name": "Test User"
}

token = jwt.encode(payload, "mock_secret", algorithm="HS256")
print(f"   Token: {token[:50]}...")

# Test login
import urllib.request
url = f"http://localhost:8069/auth/clerk/login?token={token}"
try:
    response = urllib.request.urlopen(url)
    print(f"   ✅ Odoo SSO Response: {response.status}")
except Exception as e:
    print(f"   ⚠️  Odoo SSO Error: {e}")
PYEOF

echo ""
echo "✅ Basic tests completed"
echo "⚠️  Full E2E requires real Clerk credentials"
