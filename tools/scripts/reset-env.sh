#!/bin/bash
set -e

CLERK_PK="pk_test_c2V0dGxpbmctaG9nLTk3LmNsZXJrLmFjY291bnRzLmRldiQ"
CLERK_SK="sk_test_74O53iKBUH9ZZLkbZQuCAba3XJIxxBvwxTNY0lifPz"

echo "🔥 Removing old Clerk vars..."
vercel env rm NEXT_PUBLIC_CLERK_PUBLISHABLE_KEY production --yes 2>/dev/null || true
vercel env rm CLERK_SECRET_KEY production --yes 2>/dev/null || true
vercel env rm CLERK_PUBLISHABLE_KEY production --yes 2>/dev/null || true

echo "✅ Adding new Clerk vars..."
echo "$CLERK_PK" | vercel env add NEXT_PUBLIC_CLERK_PUBLISHABLE_KEY production
echo "$CLERK_SK" | vercel env add CLERK_SECRET_KEY production

echo "🚀 Triggering redeploy..."
vercel deploy --prod --force

echo "✅ DONE for app.smarterbot.cl"
