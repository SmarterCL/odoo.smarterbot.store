#!/usr/bin/env bash
set -euo pipefail

TENANT_ID="$1"  # e.g. tenant_demo_001
RUT="${2:-}"      # optional Chilean RUT

if [ -z "$TENANT_ID" ]; then
  echo "Usage: $0 <TENANT_ID> [rut]" >&2
  exit 1
fi

VAULT_ADDR="${VAULT_ADDR:-http://127.0.0.1:8200}"
VAULT_TOKEN="${VAULT_TOKEN:-}"
if [ -z "$VAULT_TOKEN" ]; then
  echo "VAULT_TOKEN must be set in environment" >&2
  exit 1
fi

echo "➡ Creating tenant secrets structure for $TENANT_ID"

create_secret() {
  local path="$1"; shift
  local json="$1"; shift || true
  echo "  • $path"
  vault kv put "secret/tenant/$TENANT_ID/$path" data="$(echo "$json" | base64)" >/dev/null 2>&1 || true
}

# Chatwoot
vault kv put secret/tenant/$TENANT_ID/chatwoot \
  BASE_URL="https://chatwoot.smarterbot.cl" \
  API_TOKEN="REPLACE_TOKEN" \
  ACCOUNT_ID="1" \
  INBOX_ID="1" >/dev/null

# Botpress
vault kv put secret/tenant/$TENANT_ID/botpress \
  URL="https://botpress.smarterbot.cl" \
  API_KEY="REPLACE_API_KEY" \
  BOT_ID="leadbot" \
  WORKSPACE_ID="workspace-main" >/dev/null

# Odoo
vault kv put secret/tenant/$TENANT_ID/odoo \
  URL="https://odoo.smarterbot.cl" \
  DB="${TENANT_ID}_db" \
  USER="user@example.com" \
  PASSWORD="REPLACE_PASSWORD" >/dev/null

# Supabase
vault kv put secret/tenant/$TENANT_ID/supabase \
  URL="https://<project>.supabase.co" \
  SERVICE_ROLE="REPLACE_SERVICE_ROLE" >/dev/null

echo "✅ Vault paths created under secret/tenant/$TENANT_ID/*"

# Policies (render from templates)
for policy in n8n-tenant-read api-tenant-read; do
  sed "s/TENANT_ID/$TENANT_ID/g" "$(dirname "$0")/../vault/policies/$policy.hcl" > "/tmp/$policy-$TENANT_ID.hcl"
  echo "➡ Writing policy $policy-$TENANT_ID"
  vault policy write "$policy-$TENANT_ID" "/tmp/$policy-$TENANT_ID.hcl" >/dev/null
done

echo "➡ (Optional) Mapping policies to tokens requires manual step or approle creation"

echo "➡ Register tenant in Supabase (manual SQL if not automated)"
cat <<SQL
INSERT INTO tenants (id, rut, name) VALUES ('$TENANT_ID', '${RUT:-NULL}', '$TENANT_ID');
SQL

echo "🎉 Tenant $TENANT_ID bootstrap complete"
