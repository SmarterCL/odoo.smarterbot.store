#!/bin/bash
set -e

echo "🔧 Fixing both Vercel apps..."

# Fix app.smarterbot.cl
echo "📦 Setting ENV for app.smarterbot.cl..."
vercel link --project=app-smarterbot-cl --scope=smartercl --yes
vercel env rm NEXT_PUBLIC_CLERK_PUBLISHABLE_KEY production --yes 2>/dev/null || true
vercel env add NEXT_PUBLIC_CLERK_PUBLISHABLE_KEY production <<< "pk_test_c2V0dGxpbmctaG9nLTk3LmNsZXJrLmFjY291bnRzLmRldiQ"
vercel env rm CLERK_SECRET_KEY production --yes 2>/dev/null || true
vercel env add CLERK_SECRET_KEY production <<< "sk_test_74O53iKBUH9ZZLkbZQuCAba3XJIxxBvwxTNY0lifPz"

# Fix app.smarterbot.store
echo "📦 Setting ENV for app.smarterbot.store..."
vercel link --project=app-smarterbot-store --scope=smartercl --yes
vercel env rm NEXT_PUBLIC_CLERK_PUBLISHABLE_KEY production --yes 2>/dev/null || true
vercel env add NEXT_PUBLIC_CLERK_PUBLISHABLE_KEY production <<< "pk_test_c2V0dGxpbmctaG9nLTk3LmNsZXJrLmFjY291bnRzLmRldiQ"
vercel env rm CLERK_SECRET_KEY production --yes 2>/dev/null || true
vercel env add CLERK_SECRET_KEY production <<< "sk_test_74O53iKBUH9ZZLkbZQuCAba3XJIxxBvwxTNY0lifPz"

echo "✅ Redeploying both..."
vercel --prod --force

echo "🎯 DONE! Both apps fixed."
