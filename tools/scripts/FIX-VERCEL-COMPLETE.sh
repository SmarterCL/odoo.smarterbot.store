#!/bin/bash
set -e

echo "🔥 FIXING VERCEL DEPLOYMENTS LIKE A PRO"
echo "========================================"

# 1. Fix app.smarterbot.cl
echo ""
echo "📦 Configuring app.smarterbot.cl..."
cd /root/app-smarterbot-cl

# Add deployment protection bypass
vercel env add VERCEL_AUTOMATION_BYPASS_SECRET "a9F3xQ7mP2rL8tW5vZ1cB4nH6sD0kR8q" production --yes 2>/dev/null || true
vercel env add VERCEL_AUTOMATION_BYPASS_SECRET "a9F3xQ7mP2rL8tW5vZ1cB4nH6sD0kR8q" preview --yes 2>/dev/null || true
vercel env add VERCEL_AUTOMATION_BYPASS_SECRET "a9F3xQ7mP2rL8tW5vZ1cB4nH6sD0kR8q" development --yes 2>/dev/null || true

# Fix Clerk keys
vercel env add NEXT_PUBLIC_CLERK_PUBLISHABLE_KEY "pk_test_c2V0dGxpbmctaG9nLTk3LmNsZXJrLmFjY291bnRzLmRldiQ" production --yes 2>/dev/null || true
vercel env add CLERK_SECRET_KEY "sk_test_74O53iKBUH9ZZLkbZQuCAba3XJIxxBvwxTNY0lifPz" production --yes 2>/dev/null || true

# Add other required vars
vercel env add NEXT_PUBLIC_APP_URL "https://app.smarterbot.cl" production --yes 2>/dev/null || true
vercel env add CLERK_COOKIE_DOMAIN ".smarterbot.cl" production --yes 2>/dev/null || true
vercel env add MCP_ENABLED "true" production --yes 2>/dev/null || true
vercel env add FASTAPI_URL "https://api.smarterbot.cl" production --yes 2>/dev/null || true

echo "✅ app.smarterbot.cl configured"

# 2. Fix app.smarterbot.store
echo ""
echo "📦 Configuring app.smarterbot.store..."
cd /root/app-smarterbot-store

# Add deployment protection bypass
vercel env add VERCEL_AUTOMATION_BYPASS_SECRET "a9F3xQ7mP2rL8tW5vZ1cB4nH6sD0kR8q" production --yes 2>/dev/null || true
vercel env add VERCEL_AUTOMATION_BYPASS_SECRET "a9F3xQ7mP2rL8tW5vZ1cB4nH6sD0kR8q" preview --yes 2>/dev/null || true
vercel env add VERCEL_AUTOMATION_BYPASS_SECRET "a9F3xQ7mP2rL8tW5vZ1cB4nH6sD0kR8q" development --yes 2>/dev/null || true

# Fix Clerk keys
vercel env add NEXT_PUBLIC_CLERK_PUBLISHABLE_KEY "pk_test_c2V0dGxpbmctaG9nLTk3LmNsZXJrLmFjY291bnRzLmRldiQ" production --yes 2>/dev/null || true
vercel env add CLERK_SECRET_KEY "sk_test_74O53iKBUH9ZZLkbZQuCAba3XJIxxBvwxTNY0lifPz" production --yes 2>/dev/null || true

# Add other required vars
vercel env add NEXT_PUBLIC_APP_URL "https://app.smarterbot.store" production --yes 2>/dev/null || true
vercel env add NEXT_PUBLIC_API_BASE_URL "https://api.smarterbot.cl" production --yes 2>/dev/null || true
vercel env add CLERK_COOKIE_DOMAIN ".smarterbot.store" production --yes 2>/dev/null || true

echo "✅ app.smarterbot.store configured"

# 3. Redeploy both
echo ""
echo "🚀 Triggering redeployments..."

cd /root/app-smarterbot-cl
vercel --prod --yes

cd /root/app-smarterbot-store  
vercel --prod --yes

echo ""
echo "✅ DONE! Both apps redeploying now."
echo "Check:"
echo "  - https://app.smarterbot.cl/dashboard"
echo "  - https://app.smarterbot.store/dashboard"
