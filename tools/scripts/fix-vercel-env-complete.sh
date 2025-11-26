#!/bin/bash
set -e

echo "🔥 FULL RESET - Vercel ENV for both projects"

# Projects
PROJECT_CL="app.smarterbot.cl"
PROJECT_STORE="app.smarterbot.store"

# Core Clerk credentials
CLERK_PK="pk_test_c2V0dGxpbmctaG9nLTk3LmNsZXJrLmFjY291bnRzLmRldiQ"
CLERK_SK="sk_test_74O53iKBUH9ZZLkbZQuCAba3XJIxxBvwxTNY0lifPz"

echo "📦 Configuring app.smarterbot.cl..."
vercel env rm NEXT_PUBLIC_CLERK_PUBLISHABLE_KEY production --yes -A $PROJECT_CL 2>/dev/null || true
vercel env rm CLERK_SECRET_KEY production --yes -A $PROJECT_CL 2>/dev/null || true
vercel env rm CLERK_PUBLISHABLE_KEY production --yes -A $PROJECT_CL 2>/dev/null || true

echo "$CLERK_PK" | vercel env add NEXT_PUBLIC_CLERK_PUBLISHABLE_KEY production -A $PROJECT_CL
echo "$CLERK_SK" | vercel env add CLERK_SECRET_KEY production -A $PROJECT_CL
echo "$CLERK_PK" | vercel env add CLERK_PUBLISHABLE_KEY production -A $PROJECT_CL

echo "📦 Configuring app.smarterbot.store..."
vercel env rm NEXT_PUBLIC_CLERK_PUBLISHABLE_KEY production --yes -A $PROJECT_STORE 2>/dev/null || true
vercel env rm CLERK_SECRET_KEY production --yes -A $PROJECT_STORE 2>/dev/null || true
vercel env rm CLERK_PUBLISHABLE_KEY production --yes -A $PROJECT_STORE 2>/dev/null || true

echo "$CLERK_PK" | vercel env add NEXT_PUBLIC_CLERK_PUBLISHABLE_KEY production -A $PROJECT_STORE
echo "$CLERK_SK" | vercel env add CLERK_SECRET_KEY production -A $PROJECT_STORE
echo "$CLERK_PK" | vercel env add CLERK_PUBLISHABLE_KEY production -A $PROJECT_STORE

echo "🚀 Redeploying both projects..."
cd /root/app-smarterbot-cl
git commit --allow-empty -m "fix: force redeploy after env reset [$(date +%H:%M)]"
git push origin main

cd /root/app-smarterbot-store
git commit --allow-empty -m "fix: force redeploy after env reset [$(date +%H:%M)]"
git push origin main

echo "✅ DONE - Wait 2 minutes for deployments"
