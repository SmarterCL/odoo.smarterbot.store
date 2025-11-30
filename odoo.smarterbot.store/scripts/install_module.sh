#!/usr/bin/env bash
# Auto-installer for website_smarteros_seo module
set -euo pipefail

DB_NAME="${1:-}"
CONTAINER_NAME="${2:-odoo}"
ODOO_BIN="${3:-odoo}"

if [ -z "$DB_NAME" ]; then
  echo "Usage: $0 <database_name> [container_name] [odoo_binary]"
  echo "Example: $0 production odoo-web odoo"
  exit 1
fi

echo "🚀 Installing website_smarteros_seo module..."
echo "   Database: $DB_NAME"
echo "   Container: $CONTAINER_NAME"

# Check if running in container
if command -v docker &> /dev/null && docker ps | grep -q "$CONTAINER_NAME"; then
  echo "📦 Detected Docker container: $CONTAINER_NAME"
  docker exec -it "$CONTAINER_NAME" "$ODOO_BIN" -u website_smarteros_seo -d "$DB_NAME" --stop-after-init
else
  echo "🖥️  Running locally"
  "$ODOO_BIN" -u website_smarteros_seo -d "$DB_NAME" --stop-after-init
fi

echo ""
echo "✅ Module installation complete!"
echo ""
echo "Next steps:"
echo "  1. Restart Odoo service/container"
echo "  2. Verify: curl -s https://odoo.smarterbot.store/ | grep canonical"
echo "  3. Check robots.txt: curl https://odoo.smarterbot.store/robots.txt"
echo "  4. Optional: Run scripts/optimize_images.sh for WebP generation"
echo ""
