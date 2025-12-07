# FastAPI gateway tenant read policy
# Replace TENANT_ID at bootstrap time

path "secret/data/tenant/TENANT_ID/chatwoot" {
  capabilities = ["read"]
}
path "secret/data/tenant/TENANT_ID/botpress" {
  capabilities = ["read"]
}
path "secret/data/tenant/TENANT_ID/odoo" {
  capabilities = ["read"]
}
path "secret/data/tenant/TENANT_ID/supabase" {
  capabilities = ["read"]
}
