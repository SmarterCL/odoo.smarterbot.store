#!/bin/bash
set -e

echo "🚀 Triggering Vercel Redeployments"
echo "===================================="
echo ""

# Trigger app.smarterbot.cl redeploy
echo "Deploying app.smarterbot.cl..."
vercel deploy --prod --force --yes \
  --scope=smarterbotcl \
  --token="$VERCEL_TOKEN" \
  --cwd=/tmp \
  https://github.com/SmarterCL/app.smarterbot.cl

echo ""
echo "Deploying app.smarterbot.store..."
vercel deploy --prod --force --yes \
  --scope=smarterbotcl \
  --token="$VERCEL_TOKEN" \
  --cwd=/tmp \
  https://github.com/SmarterCL/app.smarterbot.store

echo ""
echo "✅ Both deployments triggered!"
