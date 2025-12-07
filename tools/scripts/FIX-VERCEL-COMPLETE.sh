#!/bin/bash
set -e

echo "🔥 FIXING VERCEL DEPLOYMENTS - LIKE A PRO"
echo "=========================================="

# Switch to app.smarterbot.cl
echo ""
echo "📦 Configuring app.smarterbot.cl..."
vercel link --project=app.smarterbot.cl --scope=smarterbotcl --yes

# Remove and re-add Clerk keys
echo "Updating CLERK keys..."
vercel env rm NEXT_PUBLIC_CLERK_PUBLISHABLE_KEY production --yes || true
vercel env rm NEXT_PUBLIC_CLERK_PUBLISHABLE_KEY preview --yes || true
vercel env rm NEXT_PUBLIC_CLERK_PUBLISHABLE_KEY development --yes || true

echo "pk_test_c2V0dGxpbmctaG9nLTk3LmNsZXJrLmFjY291bnRzLmRldiQ" | vercel env add NEXT_PUBLIC_CLERK_PUBLISHABLE_KEY production
echo "pk_test_c2V0dGxpbmctaG9nLTk3LmNsZXJrLmFjY291bnRzLmRldiQ" | vercel env add NEXT_PUBLIC_CLERK_PUBLISHABLE_KEY preview
echo "pk_test_c2V0dGxpbmctaG9nLTk3LmNsZXJrLmFjY291bnRzLmRldiQ" | vercel env add NEXT_PUBLIC_CLERK_PUBLISHABLE_KEY development

vercel env rm CLERK_SECRET_KEY production --yes || true
vercel env rm CLERK_SECRET_KEY preview --yes || true
vercel env rm CLERK_SECRET_KEY development --yes || true

echo "sk_test_74O53iKBUH9ZZLkbZQuCAba3XJIxxBvwxTNY0lifPz" | vercel env add CLERK_SECRET_KEY production
echo "sk_test_74O53iKBUH9ZZLkbZQuCAba3XJIxxBvwxTNY0lifPz" | vercel env add CLERK_SECRET_KEY preview
echo "sk_test_74O53iKBUH9ZZLkbZQuCAba3XJIxxBvwxTNY0lifPz" | vercel env add CLERK_SECRET_KEY development

# Add bypass secret
echo "Adding VERCEL_AUTOMATION_BYPASS_SECRET..."
vercel env rm VERCEL_AUTOMATION_BYPASS_SECRET production --yes || true
vercel env rm VERCEL_AUTOMATION_BYPASS_SECRET preview --yes || true
vercel env rm VERCEL_AUTOMATION_BYPASS_SECRET development --yes || true

echo "a9F3xQ7mP2rL8tW5vZ1cB4nH6sD0kR8q" | vercel env add VERCEL_AUTOMATION_BYPASS_SECRET production
echo "a9F3xQ7mP2rL8tW5vZ1cB4nH6sD0kR8q" | vercel env add VERCEL_AUTOMATION_BYPASS_SECRET preview
echo "a9F3xQ7mP2rL8tW5vZ1cB4nH6sD0kR8q" | vercel env add VERCEL_AUTOMATION_BYPASS_SECRET development

echo ""
echo "✅ app.smarterbot.cl configured"

# Switch to app.smarterbot.store
echo ""
echo "📦 Configuring app.smarterbot.store..."
vercel link --project=app.smarterbot.store --scope=smarterbotcl --yes

# Update keys for store
echo "Updating CLERK keys for store..."
vercel env rm NEXT_PUBLIC_CLERK_PUBLISHABLE_KEY production --yes || true
vercel env rm NEXT_PUBLIC_CLERK_PUBLISHABLE_KEY preview --yes || true
vercel env rm NEXT_PUBLIC_CLERK_PUBLISHABLE_KEY development --yes || true

echo "pk_test_c2V0dGxpbmctaG9nLTk3LmNsZXJrLmFjY291bnRzLmRldiQ" | vercel env add NEXT_PUBLIC_CLERK_PUBLISHABLE_KEY production
echo "pk_test_c2V0dGxpbmctaG9nLTk3LmNsZXJrLmFjY291bnRzLmRldiQ" | vercel env add NEXT_PUBLIC_CLERK_PUBLISHABLE_KEY preview
echo "pk_test_c2V0dGxpbmctaG9nLTk3LmNsZXJrLmFjY291bnRzLmRldiQ" | vercel env add NEXT_PUBLIC_CLERK_PUBLISHABLE_KEY development

vercel env rm CLERK_SECRET_KEY production --yes || true
vercel env rm CLERK_SECRET_KEY preview --yes || true
vercel env rm CLERK_SECRET_KEY development --yes || true

echo "sk_test_74O53iKBUH9ZZLkbZQuCAba3XJIxxBvwxTNY0lifPz" | vercel env add CLERK_SECRET_KEY production
echo "sk_test_74O53iKBUH9ZZLkbZQuCAba3XJIxxBvwxTNY0lifPz" | vercel env add CLERK_SECRET_KEY preview
echo "sk_test_74O53iKBUH9ZZLkbZQuCAba3XJIxxBvwxTNY0lifPz" | vercel env add CLERK_SECRET_KEY development

vercel env rm VERCEL_AUTOMATION_BYPASS_SECRET production --yes || true
vercel env rm VERCEL_AUTOMATION_BYPASS_SECRET preview --yes || true
vercel env rm VERCEL_AUTOMATION_BYPASS_SECRET development --yes || true

echo "a9F3xQ7mP2rL8tW5vZ1cB4nH6sD0kR8q" | vercel env add VERCEL_AUTOMATION_BYPASS_SECRET production
echo "a9F3xQ7mP2rL8tW5vZ1cB4nH6sD0kR8q" | vercel env add VERCEL_AUTOMATION_BYPASS_SECRET preview
echo "a9F3xQ7mP2rL8tW5vZ1cB4nH6sD0kR8q" | vercel env add VERCEL_AUTOMATION_BYPASS_SECRET development

echo ""
echo "✅ app.smarterbot.store configured"

# Redeploy both
echo ""
echo "🚀 Redeploying both projects..."
echo ""
echo "Deploying app.smarterbot.cl..."
vercel link --project=app.smarterbot.cl --scope=smarterbotcl --yes
vercel deploy --prod --force --yes

echo ""
echo "Deploying app.smarterbot.store..."
vercel link --project=app.smarterbot.store --scope=smarterbotcl --yes
vercel deploy --prod --force --yes

echo ""
echo "🎉 DONE! Both projects configured and deployed."
echo ""
echo "Check:"
echo "  https://app.smarterbot.cl/dashboard"
echo "  https://app.smarterbot.store/dashboard"
