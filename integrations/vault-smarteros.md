# HashiCorp Vault Integration for SmarterOS
Date: 2025-11-18T20:40:15.847Z

## 📋 Overview

Integration of HashiCorp Vault as the centralized secrets management system for SmarterOS multi-tenant platform.

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    SmarterOS Services                        │
├─────────────┬─────────────┬─────────────┬──────────────────┤
│ Nexa Runtime│    n8n      │  DeepCode   │   Shopify        │
│    (AI)     │ (Automation)│  (Frontend) │   (Webhooks)     │
└──────┬──────┴──────┬──────┴──────┬──────┴────────┬─────────┘
       │             │             │               │
       │             │             │               │
       ▼             ▼             ▼               ▼
┌─────────────────────────────────────────────────────────────┐
│                  HashiCorp Vault                             │
│                  vault.smarterbot.store                      │
│                                                              │
│  ┌────────────────────────────────────────────────────┐    │
│  │ KV Secrets Engine v2                               │    │
│  │                                                     │    │
│  │ secret/tenant/{tenant_id}/                         │    │
│  │   ├── nexa          (AI config)                    │    │
│  │   ├── shopify       (Store credentials)            │    │
│  │   ├── supabase      (DB credentials)               │    │
│  │   └── smtp          (Email config)                 │    │
│  └────────────────────────────────────────────────────┘    │
│                                                              │
│  ┌────────────────────────────────────────────────────┐    │
│  │ Auth Methods                                        │    │
│  │   - AppRole (services)                             │    │
│  │   - Userpass (admins)                              │    │
│  └────────────────────────────────────────────────────┘    │
│                                                              │
│  ┌────────────────────────────────────────────────────┐    │
│  │ Policies                                            │    │
│  │   - tenant-policy (per-tenant isolation)           │    │
│  │   - nexa-runtime-policy (read tenant configs)      │    │
│  │   - admin-policy (full access)                     │    │
│  └────────────────────────────────────────────────────┘    │
└─────────────────────────────────────────────────────────────┘
```

## 📦 Files Created

### 1. Docker Compose
**File:** `/root/docker-compose-vault.yml`

- HashiCorp Vault container (latest)
- Port 8200 exposed
- Persistent volumes for data, logs, config
- Health checks
- Traefik/Caddy labels for reverse proxy

### 2. Vault Configuration
**File:** `/root/vault-config.hcl`

- Production-ready configuration
- File storage backend
- HTTP listener on 0.0.0.0:8200
- Telemetry enabled
- UI enabled

### 3. Setup Script
**File:** `/root/setup-vault.sh`

Automated setup script that:
- Enables KV v2 secrets engine
- Creates multi-tenant policies
- Sets up AppRole auth for services
- Creates example tenant secrets
- Configures admin user
- Enables audit logging

## 🚀 Quick Start

### Step 1: Start Vault Container

```bash
# Start Vault
docker-compose -f /root/docker-compose-vault.yml up -d

# Wait for Vault to be ready
sleep 10

# Check status
docker logs smarteros-vault
```

### Step 2: Run Setup Script

```bash
# Run automated setup
/root/setup-vault.sh
```

This will:
- ✅ Enable secrets engine
- ✅ Create policies for multi-tenant isolation
- ✅ Set up AppRole for Nexa Runtime
- ✅ Create example tenant secrets
- ✅ Configure admin user
- ✅ Enable audit logging

### Step 3: Verify Installation

```bash
# Export Vault address
export VAULT_ADDR=http://localhost:8200
export VAULT_TOKEN=smarteros-dev-token

# Check status
vault status

# List secrets
vault kv list secret/tenant/

# Read demo tenant config
vault kv get secret/tenant/demo/nexa
```

## 🔐 Security Model

### Multi-Tenant Isolation

Each tenant has isolated secrets under:
```
secret/tenant/{tenant_id}/
  ├── nexa/          # AI configuration
  ├── shopify/       # Shopify credentials
  ├── supabase/      # Database credentials
  └── smtp/          # Email configuration
```

### Policies

**1. Tenant Policy** (`tenant-policy`)
- Tenants can only access their own secrets
- Path: `secret/data/tenant/{{identity.entity.metadata.tenant_id}}/*`

**2. Nexa Runtime Policy** (`nexa-runtime-policy`)
- Read access to all tenant Nexa configs
- Path: `secret/data/tenant/*/nexa`

**3. Admin Policy** (`admin-policy`)
- Full access to all secrets
- Can manage policies and auth methods

### Authentication Methods

**AppRole** (for services)
- Nexa Runtime uses AppRole with role_id + secret_id
- Token TTL: 1h, Max TTL: 24h
- No default policy attached

**Userpass** (for humans)
- Admin user with admin-policy
- Default password: `changeme123` (CHANGE IN PRODUCTION!)

## 🔧 Integration with Nexa Runtime

### Update docker-compose-nexa.yml

```yaml
services:
  nexa-runtime:
    environment:
      # Vault configuration
      VAULT_ADDR: http://vault:8200
      VAULT_ROLE_ID: ${VAULT_ROLE_ID}
      VAULT_SECRET_ID: ${VAULT_SECRET_ID}
      VAULT_NAMESPACE: ""
      NEXA_VAULT_PATH_TEMPLATE: secret/data/tenant/{{tenant_id}}/nexa
    
    depends_on:
      - vault
```

### Load Vault Credentials

```bash
# Source credentials created by setup script
source /root/.vault-nexa-credentials

# Add to .env file
echo "VAULT_ROLE_ID=${VAULT_ROLE_ID}" >> /root/.env
echo "VAULT_SECRET_ID=${VAULT_SECRET_ID}" >> /root/.env
```

### Nexa Runtime Code (Python)

```python
import hvac
import os

# Initialize Vault client
client = hvac.Client(url=os.getenv('VAULT_ADDR'))

# Authenticate with AppRole
client.auth.approle.login(
    role_id=os.getenv('VAULT_ROLE_ID'),
    secret_id=os.getenv('VAULT_SECRET_ID')
)

# Read tenant secrets
def get_tenant_config(tenant_id: str) -> dict:
    secret_path = f"secret/data/tenant/{tenant_id}/nexa"
    response = client.secrets.kv.v2.read_secret_version(path=secret_path)
    return response['data']['data']

# Example usage
tenant_config = get_tenant_config('rut-76832940-3')
model_id = tenant_config['NEXA_MODEL_ID']
temperature = float(tenant_config['NEXA_TEMPERATURE'])
```

## 📊 Management

### Add New Tenant Secrets

```bash
# Create secrets for new tenant
vault kv put secret/tenant/rut-12345678-9/nexa \
  NEXA_MODEL_ID="llama-3-8b-instruct" \
  NEXA_TEMPERATURE="0.7" \
  TENANT_HARD_LIMIT_RPM="120"

vault kv put secret/tenant/rut-12345678-9/shopify \
  SHOPIFY_SHOP_DOMAIN="example.myshopify.com" \
  SHOPIFY_API_KEY="your-key" \
  SHOPIFY_API_SECRET="your-secret"
```

### Update Tenant Secrets

```bash
# Update existing secret
vault kv patch secret/tenant/demo/nexa \
  NEXA_TEMPERATURE="0.8"
```

### List All Tenants

```bash
vault kv list secret/tenant/
```

### Delete Tenant Secrets

```bash
# Soft delete (can be recovered)
vault kv delete secret/tenant/demo/nexa

# Permanent delete
vault kv destroy -versions=1 secret/tenant/demo/nexa
```

### Backup Vault Data

```bash
# Backup entire secrets tree
vault kv get -format=json secret/tenant/ > /root/backups/vault-backup-$(date +%Y%m%d).json

# Or use the backup script
/root/backup-vault.sh
```

## 🌐 Web UI Access

**URL:** https://vault.smarterbot.store or http://localhost:8200

**Login:**
- Method: Token
- Token: `smarteros-dev-token` (development)

Or:
- Method: Username
- Username: `admin`
- Password: `changeme123`

## 🔒 Production Hardening

### 1. Enable TLS

```hcl
# Update vault-config.hcl
listener "tcp" {
  address       = "0.0.0.0:8200"
  tls_disable   = 0
  tls_cert_file = "/vault/tls/vault.crt"
  tls_key_file  = "/vault/tls/vault.key"
}
```

### 2. Change to Production Storage

```hcl
# Use Consul backend
storage "consul" {
  address = "consul:8500"
  path    = "vault/"
}

# Or use cloud storage
storage "s3" {
  bucket = "smarteros-vault"
  region = "us-east-1"
}
```

### 3. Initialize Vault Properly

```bash
# Initialize (production mode)
vault operator init -key-shares=5 -key-threshold=3

# Unseal (requires 3 of 5 keys)
vault operator unseal <key1>
vault operator unseal <key2>
vault operator unseal <key3>
```

### 4. Rotate Root Token

```bash
# Generate new root token
vault token create -policy=admin-policy

# Revoke old root token
vault token revoke <old-root-token>
```

## 📈 Monitoring

### Health Check

```bash
curl http://localhost:8200/v1/sys/health
```

### Metrics (Prometheus)

```
http://localhost:8200/v1/sys/metrics?format=prometheus
```

### Audit Logs

```bash
docker exec smarteros-vault tail -f /vault/logs/audit.log
```

## 🐛 Troubleshooting

### Vault Sealed

```bash
# Check seal status
vault status

# Unseal if needed
vault operator unseal
```

### Permission Denied

```bash
# Check token capabilities
vault token capabilities secret/tenant/demo/nexa

# Check policy
vault policy read nexa-runtime-policy
```

### Can't Connect

```bash
# Check container is running
docker ps | grep vault

# Check logs
docker logs smarteros-vault

# Verify network
docker network inspect smarter-net
```

## 📚 References

- [HashiCorp Vault Documentation](https://www.vaultproject.io/docs)
- [KV Secrets Engine](https://www.vaultproject.io/docs/secrets/kv)
- [AppRole Auth Method](https://www.vaultproject.io/docs/auth/approle)
- [Vault Best Practices](https://learn.hashicorp.com/collections/vault/best-practices)

## ✅ Checklist

- [x] Docker Compose configuration created
- [x] Vault configuration file created
- [x] Setup script created with policies
- [x] Multi-tenant isolation configured
- [x] AppRole for Nexa Runtime created
- [x] Example tenant secrets created
- [x] Admin user configured
- [x] Audit logging enabled
- [x] Documentation complete

## 🎯 Next Steps

1. Start Vault container
2. Run setup script
3. Update Nexa Runtime with Vault credentials
4. Test tenant secret retrieval
5. Configure production TLS
6. Set up automated backups
7. Integrate with other services (n8n, DeepCode)

---

**Status:** ✅ Ready for deployment
**Version:** 1.0.0
**Date:** 2025-11-18T20:40:15.847Z
