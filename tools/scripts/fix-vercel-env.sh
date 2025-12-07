#!/bin/bash
set -e

# Clerk keys
CLERK_PK="pk_test_c2V0dGxpbmctaG9nLTk3LmNsZXJrLmFjY291bnRzLmRldiQ"
CLERK_SK="sk_test_74O53iKBUH9ZZLkbZQuCAba3XJIxxBvwxTNY0lifPz"

# Deployment protection
BYPASS_SECRET="a9F3xQ7mP2rL8tW5vZ1cB4nH6sD0kR8q"

echo "🔧 Fixing app.smarterbot.cl..."
cd /root/app-smarterbot-cl

# Set Clerk keys
vercel env rm NEXT_PUBLIC_CLERK_PUBLISHABLE_KEY production --yes 2>/dev/null || true
vercel env rm CLERK_SECRET_KEY production --yes 2>/dev/null || true

echo "$CLERK_PK" | vercel env add NEXT_PUBLIC_CLERK_PUBLISHABLE_KEY production
echo "$CLERK_SK" | vercel env add CLERK_SECRET_KEY production

# Set bypass secret
echo "$BYPASS_SECRET" | vercel env add VERCEL_AUTOMATION_BYPASS_SECRET production

echo "✅ app.smarterbot.cl configurado"

echo "🔧 Fixing app.smarterbot.store..."
cd /root/app-smarterbot-store

# Set Clerk keys
vercel env rm NEXT_PUBLIC_CLERK_PUBLISHABLE_KEY production --yes 2>/dev/null || true
vercel env rm CLERK_SECRET_KEY production --yes 2>/dev/null || true

echo "$CLERK_PK" | vercel env add NEXT_PUBLIC_CLERK_PUBLISHABLE_KEY production
echo "$CLERK_SK" | vercel env add CLERK_SECRET_KEY production

# Set bypass secret
echo "$BYPASS_SECRET" | vercel env add VERCEL_AUTOMATION_BYPASS_SECRET production

echo "✅ app.smarterbot.store configurado"

echo ""
echo "🚀 Trigger redeployments..."
cd /root/app-smarterbot-cl && vercel deploy --prod --force &
cd /root/app-smarterbot-store && vercel deploy --prod --force &
wait

echo "✅ DONE - Both apps redeployed"
