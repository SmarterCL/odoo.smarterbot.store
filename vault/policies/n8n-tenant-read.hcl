# n8n tenant read policy (example)
# Replace TENANT_ID dynamically when provisioning

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
