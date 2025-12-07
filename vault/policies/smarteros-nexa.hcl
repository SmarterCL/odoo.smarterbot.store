# Vault Policy for Nexa Runtime Multi-Tenant Access
# Path: policies/smarteros-nexa.hcl

# Allow reading tenant-specific Nexa configuration
# tenant_id is resolved from JWT identity or AppRole metadata
path "secret/data/tenant/{{identity.entity.metadata.tenant_id}}/nexa" {
  capabilities = ["read"]
}

# Optional: Allow listing metadata for discovery
path "secret/metadata/tenant/{{identity.entity.metadata.tenant_id}}/nexa" {
  capabilities = ["read", "list"]
}

# Allow reading shared/default configuration
path "secret/data/nexa/defaults" {
  capabilities = ["read"]
}

# Allow service to renew its own token
path "auth/token/renew-self" {
  capabilities = ["update"]
}

# Allow service to lookup its own token info
path "auth/token/lookup-self" {
  capabilities = ["read"]
}
