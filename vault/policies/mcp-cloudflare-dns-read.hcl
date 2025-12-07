# Vault Policy: mcp-cloudflare-dns-read
# Purpose: Allow read access to Cloudflare DNS MCP credentials
# Agents: executor-codex (primary), director-gemini (read-only)
# Updated: 2025-11-16

# Cloudflare DNS Analytics MCP credentials
path "smarteros/mcp/cloudflare" {
  capabilities = ["read", "list"]
}

# Allow listing MCP providers
path "smarteros/mcp/" {
  capabilities = ["list"]
}

# Read-only access to zone configurations (for verification)
path "smarteros/infra/cloudflare/zones/*" {
  capabilities = ["read"]
}
