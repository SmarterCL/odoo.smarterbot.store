# Vault MCP Server Deployment - SmarterOS

## ✅ DEPLOYMENT COMPLETED

Date: 2025-11-18
Status: **Container Running & Operational**

---

## 📋 What Was Deployed

### Service: Vault MCP Server
- **Repository**: https://github.com/hashicorp/vault-mcp-server
- **Container Name**: `smarteros-vault-mcp`
- **Image**: `vault-mcp-server:latest` (built from source)
- **Purpose**: Model Context Protocol server for HashiCorp Vault integration

### Exposed Endpoints
- **Internal**: `http://smarteros-vault-mcp:8080/mcp`
- **External** (pending DNS):
  - `https://mcp.smarterbot.cl/mcp`
  - `https://mcp.smarterbot.store/mcp`
- **Local Test**: `http://localhost:8081/mcp`

---

## 🔧 Configuration

### Environment Variables
```bash
VAULT_ADDR=http://89.116.23.167:8200
VAULT_TOKEN=${VAULT_TOKEN}  # Set via env
TRANSPORT_MODE=http
TRANSPORT_PORT=8080
MCP_ENDPOINT=/mcp
MCP_CORS_MODE=strict
MCP_ALLOWED_ORIGINS=https://mcp.smarterbot.cl,https://mcp.smarterbot.store,https://n8n.smarterbot.cl
MCP_RATE_LIMIT_GLOBAL=50:100
```

### Network
- **Network**: `smarter-net` (shared with all SmarterOS services)
- **Port Mapping**: `8081:8080` (external:internal)

### Caddy Configuration
```caddy
# Vault MCP Server - Model Context Protocol for Vault
mcp.smarterbot.cl, mcp.smarterbot.store {
    reverse_proxy smarteros-vault-mcp:8080
    encode gzip
    
    header {
        X-Frame-Options "DENY"
        X-Content-Type-Options "nosniff"
        Referrer-Policy "strict-origin-when-cross-origin"
    }
    
    log {
        output file /var/log/caddy/mcp.log
    }
}
```

---

## 🛠️ Available MCP Tools

### Mount Management
- `vault.create_mount` - Create KV/PKI mounts
- `vault.list_mounts` - List all mounts
- `vault.delete_mount` - Delete a mount

### Key-Value Operations
- `vault.write_secret` - Write secrets
- `vault.read_secret` - Read secrets
- `vault.list_secrets` - List secrets under path
- `vault.delete_secret` - Delete secret or key

### PKI Certificate Management
- `vault.enable_pki` - Enable PKI engine
- `vault.create_pki_issuer` - Create issuer
- `vault.list_pki_issuers` - List issuers
- `vault.create_pki_role` - Create certificate role
- `vault.issue_pki_certificate` - Issue new certificate

---

## 🔗 Integration Points

### 1. n8n Workflows
**HTTP Request Node Configuration:**
```json
{
  "url": "http://smarteros-vault-mcp:8080/mcp",
  "method": "POST",
  "headers": {
    "Content-Type": "application/json",
    "X-Vault-Token": "{{$env.VAULT_TOKEN}}"
  }
}
```

### 2. Nexa Runtime (AI Agent)
AI agents can use MCP tools to:
- Read tenant-specific secrets from Vault
- Write configuration dynamically
- Manage PKI certificates for multi-tenant SSL

### 3. VS Code MCP Extension
**File**: `.vscode/mcp.json`
```json
{
  "servers": {
    "vault-mcp-server": {
      "url": "http://localhost:8081/mcp?VAULT_ADDR=http://127.0.0.1:8200",
      "headers": {
        "X-Vault-Token": "${input:vault_token}"
      }
    }
  }
}
```

### 4. Claude Desktop / MCP Clients
Point to: `http://localhost:8081/mcp`

---

## 📊 Current Status

### Container Health
```bash
docker ps | grep vault-mcp
```
**Result**: ✅ Container running (status: healthy)

### Logs
```bash
docker logs smarteros-vault-mcp
```
**Latest Output:**
```
time="2025-11-18T21:31:19Z" level=info msg="Global rate limit set to 50.000000 rps with burst 100"
time="2025-11-18T21:31:19Z" level=info msg="CORS Mode: strict"
time="2025-11-18T21:31:19Z" level=info msg="Allowed Origins: https://mcp.smarterbot.cl, https://mcp.smarterbot.store, https://n8n.smarterbot.cl"
time="2025-11-18T21:31:19Z" level=info msg="Starting StreamableHTTP server on 0.0.0.0:8080/mcp"
```

### Vault Connection
✅ Vault server accessible at `http://localhost:8200`
✅ MCP server successfully connecting to Vault

---

## ⚠️ DNS Configuration Required

The following DNS records need to be added in Hostinger:

### smarterbot.cl domain
```
Type: A
Name: mcp
Value: 89.116.23.167
TTL: Automatic
```

### smarterbot.store domain
```
Type: A
Name: mcp
Value: 89.116.23.167
TTL: Automatic
```

**Current Issue**: DNS records don't exist yet, causing:
```
DNS problem: NXDOMAIN looking up A for mcp.smarterbot.cl
```

Once DNS is added, Caddy will automatically obtain SSL certificates via Let's Encrypt.

---

## 🧪 Testing

### 1. Health Check (Local)
```bash
curl http://localhost:8081/mcp
```

### 2. List Vault Mounts (requires VAULT_TOKEN)
```bash
curl -X POST http://localhost:8081/mcp \
  -H "Content-Type: application/json" \
  -H "X-Vault-Token: YOUR_TOKEN" \
  -d '{
    "jsonrpc": "2.0",
    "method": "tools/call",
    "params": {
      "name": "vault.list_mounts"
    },
    "id": 1
  }'
```

### 3. Read a Secret
```bash
curl -X POST http://localhost:8081/mcp \
  -H "Content-Type: application/json" \
  -H "X-Vault-Token: YOUR_TOKEN" \
  -d '{
    "jsonrpc": "2.0",
    "method": "tools/call",
    "params": {
      "name": "vault.read_secret",
      "arguments": {
        "mount": "secret",
        "path": "tenant/demo/config"
      }
    },
    "id": 1
  }'
```

---

## 📦 Files Created

1. **Docker Compose**: `/root/docker-compose-vault-mcp.yml`
2. **Service Spec**: `/root/specs/services/vault-mcp-server.yml`
3. **Caddyfile**: Updated with MCP routing
4. **Documentation**: This file

---

## 🚀 Next Steps

### Immediate
1. ✅ Container deployed and running
2. ⏳ Add DNS records for mcp.smarterbot.cl and mcp.smarterbot.store
3. ⏳ Wait for SSL certificate provisioning (automatic after DNS)
4. ⏳ Test external access via https://mcp.smarterbot.store/mcp

### Integration
1. Create n8n workflow that uses MCP tools
2. Configure VS Code MCP extension for team
3. Document tenant-specific Vault paths
4. Add monitoring/alerting for MCP operations

### Security
1. Review and restrict Vault token permissions
2. Configure audit logging in Vault
3. Set up Vault lease rotation
4. Document security best practices for MCP usage

---

## 📚 Documentation

- **Vault MCP Server**: https://github.com/hashicorp/vault-mcp-server
- **Model Context Protocol**: https://modelcontextprotocol.io/
- **SmarterOS Spec**: `/root/specs/services/vault-mcp-server.yml`
- **Vault Documentation**: https://developer.hashicorp.com/vault/docs

---

## 🔐 Security Notes

⚠️ **Important Security Considerations:**

1. **Local Use Only**: MCP server is designed for internal/local use
2. **Trusted Clients**: Only use with trusted MCP clients and LLMs
3. **Secret Exposure**: MCP may expose Vault secrets to LLM - use carefully
4. **CORS Restrictions**: Always configure MCP_ALLOWED_ORIGINS properly
5. **Token Permissions**: Use least-privilege Vault tokens
6. **TLS**: Currently running without TLS (behind Caddy proxy)

---

## 📞 Support

For issues or questions:
1. Check container logs: `docker logs smarteros-vault-mcp`
2. Verify Vault connection: `curl http://localhost:8200/v1/sys/health`
3. Review MCP server logs for detailed errors
4. Consult official documentation: https://github.com/hashicorp/vault-mcp-server

---

**Deployment Status**: ✅ OPERATIONAL (Pending DNS Configuration)
**Last Updated**: 2025-11-18 21:31 UTC
