# Vault Policy: mcp-smartermcp-read
# Purpose: Allow read access to SmarterMCP credentials
# Used by: All agents (director-gemini, executor-codex, writer-copilot)

# SmarterMCP credentials
path "smarteros/mcp/smartermcp" {
  capabilities = ["read", "list"]
}

# List all MCP providers
path "smarteros/mcp/" {
  capabilities = ["list"]
}

# Read service configurations
path "smarteros/services/*" {
  capabilities = ["read"]
}

# Read infrastructure configs
path "smarteros/infra/*" {
  capabilities = ["read"]
}
