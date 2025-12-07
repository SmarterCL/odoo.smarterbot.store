# Vault Tenant Secrets Structure for Nexa Runtime

## Overview

Each tenant has isolated secrets in Vault for Nexa Runtime configuration.

## Path Structure

```
secret/data/tenant/{tenant_id}/nexa
```

## Example Tenants

### Tenant: rut-76832940-3 (FullDayGo)

**Path:** `secret/data/tenant/rut-76832940-3/nexa`

```json
{
  "data": {
    "NEXA_MODEL_ID": "llama-3-8b-instruct",
    "NEXA_MODEL_VARIANT": "q4_k_m",
    "NEXA_MODEL_URL": "https://models.smarterbot.cl/llama-3-8b.q4_k_m.gguf",
    "NEXA_MAX_CONTEXT_TOKENS": "8192",
    "NEXA_MAX_OUTPUT_TOKENS": "768",
    "NEXA_TEMPERATURE": "0.7",
    "TENANT_HARD_LIMIT_RPM": "120",
    "TENANT_HARD_LIMIT_CONCURRENCY": "4",
    "TENANT_CUSTOM_SYSTEM_PROMPT": "Eres un asistente de FullDayGo especializado en turismo.",
    "TENANT_FEATURES": "chat,embeddings,vision",
    "TENANT_LOGGING_ENABLED": "true"
  }
}
```

### Tenant: demo (Default/Test)

**Path:** `secret/data/tenant/demo/nexa`

```json
{
  "data": {
    "NEXA_MODEL_ID": "llama-3-8b-instruct",
    "NEXA_MODEL_VARIANT": "q4_k_m",
    "NEXA_MAX_CONTEXT_TOKENS": "4096",
    "NEXA_MAX_OUTPUT_TOKENS": "512",
    "NEXA_TEMPERATURE": "0.7",
    "TENANT_HARD_LIMIT_RPM": "60",
    "TENANT_HARD_LIMIT_CONCURRENCY": "2",
    "TENANT_FEATURES": "chat",
    "TENANT_LOGGING_ENABLED": "false"
  }
}
```

## Shared Defaults

**Path:** `secret/data/nexa/defaults`

```json
{
  "data": {
    "NEXA_MODEL_ID": "llama-3-8b-instruct",
    "NEXA_MAX_CONTEXT_TOKENS": "8192",
    "NEXA_MAX_OUTPUT_TOKENS": "1024",
    "NEXA_TEMPERATURE": "0.7",
    "TENANT_HARD_LIMIT_RPM": "100",
    "TENANT_HARD_LIMIT_CONCURRENCY": "3"
  }
}
```

## Vault CLI Commands

### Create tenant secret

```bash
# For tenant rut-76832940-3
vault kv put secret/tenant/rut-76832940-3/nexa \
  NEXA_MODEL_ID="llama-3-8b-instruct" \
  NEXA_MODEL_VARIANT="q4_k_m" \
  NEXA_MAX_CONTEXT_TOKENS="8192" \
  NEXA_MAX_OUTPUT_TOKENS="768" \
  NEXA_TEMPERATURE="0.7" \
  TENANT_HARD_LIMIT_RPM="120" \
  TENANT_HARD_LIMIT_CONCURRENCY="4"
```

### Read tenant secret

```bash
vault kv get secret/tenant/rut-76832940-3/nexa
```

### List all tenant secrets

```bash
vault kv list secret/tenant/
```

### Update specific field

```bash
vault kv patch secret/tenant/rut-76832940-3/nexa \
  NEXA_TEMPERATURE="0.8"
```

## Policy Application

### Create the policy

```bash
vault policy write smarteros-nexa /path/to/smarteros-nexa.hcl
```

### Create AppRole for Nexa Runtime

```bash
# Enable AppRole
vault auth enable approle

# Create role
vault write auth/approle/role/nexa-runtime \
  token_policies="smarteros-nexa" \
  token_ttl=1h \
  token_max_ttl=24h \
  bind_secret_id=true

# Get role_id
vault read auth/approle/role/nexa-runtime/role-id

# Generate secret_id
vault write -f auth/approle/role/nexa-runtime/secret-id
```

### Login with AppRole

```bash
vault write auth/approle/login \
  role_id="<role_id>" \
  secret_id="<secret_id>"
```

## Integration with Nexa Runtime

### Environment Variables

```bash
VAULT_ADDR=https://vault.smarterbot.cl:8200
VAULT_TOKEN=<token_from_approle_login>
NEXA_VAULT_PATH_TEMPLATE=secret/data/tenant/{{tenant_id}}/nexa
```

### Request Flow

1. Client sends request with `X-Tenant-Id: rut-76832940-3`
2. Nexa Runtime resolves tenant ID
3. Constructs Vault path: `secret/data/tenant/rut-76832940-3/nexa`
4. Fetches configuration from Vault
5. Applies tenant-specific limits and settings
6. Processes request with configured parameters

## Security Considerations

- ✅ Each tenant can only access their own secrets
- ✅ Secrets are encrypted at rest in Vault
- ✅ Token renewal handled automatically
- ✅ Audit logging enabled in Vault
- ✅ Short-lived tokens (1h TTL)

## Monitoring

Track secret access in Vault audit logs:

```bash
vault audit enable file file_path=/var/log/vault/audit.log
```

Query audit logs for Nexa access:

```bash
grep "secret/data/tenant/.*/nexa" /var/log/vault/audit.log
```
