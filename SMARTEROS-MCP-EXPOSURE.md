# 🌐 SmarterOS - Public MCP Registry

**Live Registry**: http://89.116.23.167:3090  
**Future Domain**: https://mcp.smarterbot.cl  
**Date**: 2025-11-19

---

## 🎯 What is Exposed

Esta es la lista pública de todo lo que SmarterOS expone a través del MCP Registry en **mcp.smarterbot.cl**:

### 📊 Overview Dashboard

**Stats Visibles**:
- Total MCPs disponibles: **28 providers**
- MCPs instalados: **7 packages**
- MCPs activos: **3 servers**
- Tiers organizados: **5 categorías**

---

## 🔌 28 MCP Providers Documentados

### TIER 1: Core Infrastructure (7)

| Provider | Status | Description | Package |
|----------|--------|-------------|---------|
| **GitHub MCP** | 🟢 Active | Repository, issues, PR management | @modelcontextprotocol/server-github |
| **Vault MCP** | 🟡 Unhealthy | Secrets management | vault-mcp (custom) |
| **Clerk MCP** | 🟡 Pending | User authentication | @clerk/mcp-tools |
| **SmarterMCP** | 🟡 Pending | Custom SmarterOS services | @smartercl/mcp-server |
| **Docker MCP** | ⚪ Available | Container management | - |
| **Hostinger MCP** | 🟡 Pending | VPS/DNS (100+ tools) | hostinger-api-mcp |
| **Supabase MCP** | 🟡 Pending | Database, auth, storage | - |

### TIER 2: Business Logic (5)

| Provider | Status | Description |
|----------|--------|-------------|
| **Shopify MCP** | ⚪ Inactive | E-commerce management |
| **Metabase MCP** | ⚪ Inactive | Analytics and BI |
| **Odoo MCP** | ⚪ Inactive | ERP system |
| **N8N MCP** | ⚪ Inactive | Workflow automation |
| **Stripe MCP** | ⚪ Inactive | Payment processing |

### TIER 3: AI/ML (4)

| Provider | Status | Description | Package |
|----------|--------|-------------|---------|
| **OpenAI MCP** | ⚪ Inactive | GPT integration | - |
| **Anthropic MCP** | ⚪ Inactive | Claude integration | - |
| **Google AI MCP** | ⚪ Inactive | Gemini API | - |
| **Context7 MCP** | 🟡 Pending | Documentation AI | @upstash/context7-mcp |

### TIER 4: Communication (4)

| Provider | Status | Description |
|----------|--------|-------------|
| **Slack MCP** | ⚪ Inactive | Team messaging |
| **Twilio MCP** | ⚪ Inactive | SMS/Voice |
| **WhatsApp MCP** | ⚪ Inactive | WhatsApp Business |
| **Mailgun MCP** | ⚪ Inactive | Email delivery |

### TIER 5: DevOps/Infrastructure (8)

| Provider | Status | Description | Package |
|----------|--------|-------------|---------|
| **Cloudflare DNS MCP** | 🟡 Pending | DNS management | Remote MCP |
| **AWS MCP** | ⚪ Inactive | Cloud services | - |
| **Vercel MCP** | 🟡 Pending | Serverless deployment | mcp-handler |
| **Linear MCP** | ⚪ Inactive | Issue tracking | - |
| **Notion MCP** | ⚪ Inactive | Documentation | - |
| **Playwright MCP** | 🟡 Pending | Browser automation | @playwright/mcp |
| **Chrome DevTools MCP** | 🟡 Pending | Chrome debugging | chrome-devtools-mcp |
| **MCP Proxy** | 🟢 Active | SSE proxy | mcp-proxy |

---

## 🛠️ Tools & Capabilities Exposed

### Por cada MCP se expone:

1. **Metadata**:
   - Nombre y descripción
   - Tier y categoría
   - Status (active/pending/inactive)
   - NPM package (si aplica)
   - Endpoint (si aplica)
   
2. **Technical Details**:
   - Lista de tools/capabilities
   - Agents que lo usan
   - Vault path para secrets
   - Repository/documentation links

3. **Installation**:
   - Comando pnpm install
   - Configuration examples
   - Environment variables

4. **Integration**:
   - Agent access patterns
   - Use cases
   - Example workflows

### Ejemplo: Hostinger MCP (100+ tools)

**Exposed Capabilities**:
```
VPS Management:
  - VPS_getVirtualMachinesV1
  - VPS_startVirtualMachineV1
  - VPS_stopVirtualMachineV1
  - VPS_rebootVirtualMachineV1
  - VPS_createBackupV1
  - VPS_restoreBackupV1

SSH Keys:
  - VPS_getPublicKeysV1
  - VPS_createPublicKeyV1
  - VPS_attachPublicKeyV1

Firewall:
  - VPS_listFirewallsV1
  - VPS_activateFirewallV1
  - VPS_deactivateFirewallV1

Domains:
  - domains_checkDomainAvailabilityV1
  - domains_getDomainListV1
  - domains_updateDomainNameserversV1

Billing:
  - billing_getPaymentMethodsV1
  - billing_disableAutoRenewalV1
```

---

## 🎨 Registry Features Exposed

### Search & Discovery
```javascript
// Users can search by:
- MCP name
- Description
- Tool names
- Category
- Status
```

### Filters
```javascript
// Available filters:
- All MCPs
- Tier 1 (Core)
- Tier 2 (Business)
- Tier 3 (AI/ML)
- Tier 4 (Communication)
- Tier 5 (DevOps)
- Active Only
```

### Details Modal
```javascript
// For each MCP shows:
{
  status: "active|pending|inactive",
  tier: 1-5,
  category: "core|business|ai|communication|devops",
  description: "Full description",
  endpoint: "http://...",
  npmPackage: "@org/package-name",
  repository: "https://github.com/...",
  agents: ["gemini", "codex", "copilot"],
  vaultPath: "smarteros/mcp/provider",
  tools: ["tool1", "tool2", ...],
  installCommand: "pnpm add -g ...",
  configExample: { /* JSON config */ },
  docs: "/specs/mcp/provider.yml"
}
```

---

## 🔐 Security & Privacy

### What is NOT Exposed

❌ **Never exposed**:
- API tokens/secrets
- Vault credentials
- Internal IPs (only public VPS IP)
- Database credentials
- SSH keys
- Webhook secrets
- Customer data
- Internal architecture details

### What IS Exposed

✅ **Publicly available**:
- MCP provider names
- Tool/capability names (generic)
- Package names (from public npm)
- Documentation links
- Installation commands
- Public endpoints (like Cloudflare MCP)
- Status indicators (active/inactive)
- High-level architecture (tiers)

### Security Measures

```yaml
Registry Web:
  - Static site only (no backend)
  - Read-only volume mount
  - No user input processing
  - No database connections
  - Nginx with security headers

Secrets:
  - All in Vault (not in registry)
  - Vault paths shown but not contents
  - API tokens never displayed
  - Environment vars not exposed
```

---

## 🌍 Public Endpoints

### Current Access

**Internal** (VPS network):
```
http://89.116.23.167:3090
```

**Future Public** (after DNS):
```
https://mcp.smarterbot.cl
```

### Active MCP Servers

Currently running and accessible:

1. **GitHub MCP Proxy**:
   - Port: 3001
   - Uptime: 20+ hours
   - Status: ✅ Healthy

2. **Vault MCP Server**:
   - Port: 8081
   - Status: ⚠️ Unhealthy (needs restart)

3. **MCP Registry Web**:
   - Port: 3090
   - Status: ✅ Healthy
   - Uptime: Just deployed

---

## 📦 Installed Packages Visible

The registry shows which packages are installed via pnpm:

```bash
Installed (7 packages):
├── @modelcontextprotocol/inspector@0.17.2
├── mcp-remote@0.1.31
├── hostinger-api-mcp@0.1.18
├── @clerk/mcp-tools@0.3.1
├── @upstash/context7-mcp@1.0.29
├── @playwright/mcp@0.0.47
├── chrome-devtools-mcp@0.10.2
├── mcp-handler@1.0.3
└── mcp-proxy@5.11.0
```

Not installed (21 providers):
- Still pending installation or configuration
- Listed as "Not installed" in registry
- Installation commands provided

---

## 🎯 Agent Information Exposed

### Three Main Agents

**Director Gemini**:
- Access: 18 MCPs
- Primary use: Business logic, AI/ML, Communication
- Use cases: Analytics, optimizations, recommendations

**Writer Copilot**:
- Access: 6 MCPs
- Primary use: Documentation, content
- Use cases: Docs generation, context gathering

**Executor Codex**:
- Access: 12 MCPs
- Primary use: Infrastructure, DevOps
- Use cases: Deployments, VPS management, automation

### Agent-MCP Mapping

```javascript
// Example from registry data:
{
  id: 'github',
  agents: ['gemini', 'copilot', 'codex'],
  // All three agents can access GitHub MCP
}

{
  id: 'hostinger',
  agents: ['codex', 'gemini'],
  // Only Codex and Gemini access Hostinger
}
```

---

## 📚 Documentation Structure Exposed

### Specs Location
```
/root/specs/mcp/
├── index.yml              # Master index
├── hostinger.yml          # Hostinger spec
├── cloudflare-dns.yml     # Cloudflare spec
├── clerk.yml              # Clerk spec
├── vercel.yml             # Vercel spec
└── ... (24 more specs)
```

### Each Spec Contains
```yaml
provider: "name"
category: "core|business|..."
tier: 1-5
status: "active|pending|inactive"

mcp_server:
  name: "package-name"
  repository: "github-url"
  npm_package: "npm-package"

capabilities:
  - tool_name: "description"
  - ...

agent_usage:
  executor-codex:
    primary: true
    use_cases:
      - "Use case 1"
      - "Use case 2"
```

---

## 🔄 Live Updates

### What Updates Automatically

✅ **Auto-updated**:
- Stats dashboard (total, active, installed)
- Search results
- Filter results
- MCP status badges

### What Needs Manual Update

🔧 **Manual update required**:
- Adding new MCPs (edit app.js)
- Changing MCP status
- Updating descriptions
- Modifying tool lists

---

## 📊 Metrics Exposed

### Dashboard Stats

```javascript
{
  totalMCPs: 28,           // Total providers documented
  activeMCPs: 3,           // Currently running servers
  installedMCPs: 7,        // Installed npm packages
  tier1MCPs: 7             // Core infrastructure count
}
```

### Per-Tier Breakdown

```javascript
{
  tier1: { total: 7, installed: 3, active: 2 },
  tier2: { total: 5, installed: 0, active: 0 },
  tier3: { total: 4, installed: 1, active: 0 },
  tier4: { total: 4, installed: 0, active: 0 },
  tier5: { total: 8, installed: 3, active: 1 }
}
```

---

## 🚀 Next Steps (Public)

After DNS configuration, the following will be public:

1. **MCP Registry**: https://mcp.smarterbot.cl
   - Full listing of 28 providers
   - Search and filter capabilities
   - Installation guides
   - Configuration examples

2. **Active MCPs** (for authorized users):
   - GitHub MCP: For repo/issue management
   - Hostinger MCP: For VPS operations
   - Cloudflare MCP: For DNS automation
   - Clerk MCP: For auth operations

3. **Documentation**:
   - Public specs repository
   - Individual MCP guides
   - Integration examples
   - Best practices

---

## 📞 Public Contact

**Registry URL**: https://mcp.smarterbot.cl (coming soon)  
**GitHub**: smarteros-specs repository  
**Support**: Issues in GitHub repo

---

## ✅ Summary

**What's Public on mcp.smarterbot.cl**:
- ✅ 28 MCP provider listings
- ✅ Tool/capability descriptions
- ✅ Installation commands
- ✅ Configuration examples
- ✅ Integration patterns
- ✅ Status indicators
- ✅ Documentation links

**What's Private**:
- ❌ API tokens/secrets
- ❌ Vault credentials
- ❌ Customer data
- ❌ Internal IPs
- ❌ Production configs

---

**Created**: 2025-11-19  
**Status**: ✅ Deployed on port 3090  
**Next**: Configure DNS for public access
