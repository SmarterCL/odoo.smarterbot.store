# Vault Policy: MCP Clerk Read Access
# Allows MCP tools to read Clerk authentication credentials
# Used by: director-gemini, writer-copilot, executor-codex

# Clerk MCP credentials (API keys, webhook secrets)
path "smarteros/mcp/clerk" {
  capabilities = ["read", "list"]
}

# List all MCP providers (discovery)
path "smarteros/mcp/" {
  capabilities = ["list"]
}

# Read infrastructure config for multi-tenant setup
path "smarteros/infra/*/config" {
  capabilities = ["read"]
}
