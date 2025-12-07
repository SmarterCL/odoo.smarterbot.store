# Policy: mcp-vercel-read
# Description: Read-only access to Vercel MCP credentials
# Updated: 2025-11-17

# Vercel MCP credentials (API token, team, project)
path "smarteros/mcp/vercel" {
  capabilities = ["read", "list"]
}

# List MCP providers
path "smarteros/mcp" {
  capabilities = ["list"]
}

# Read infrastructure config (optional)
path "smarteros/infra/config" {
  capabilities = ["read"]
}
