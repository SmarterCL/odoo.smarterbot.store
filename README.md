# SmarterOS - Specifications Repository

![Version](https://img.shields.io/badge/version-0.1.0-blue.svg)
![Status](https://img.shields.io/badge/status-development-yellow.svg)
![License](https://img.shields.io/badge/license-Proprietary-red.svg)

**SmarterOS** is a multi-tenant business automation operating system. This repository contains the complete specifications, architecture decisions, and configuration for the entire ecosystem.

## 🎯 What is SmarterOS?

SmarterOS is like **Terraform + Kubernetes + Ansible** but for your **entire business stack**:

- **Infrastructure as Code** → `infra/infrastructure.yml`
- **Services as Code** → `services/registry.yml`
- **Tenants as Code** → `tenants/registry.yml`
- **Decisions as Code** → `decision-tree.yml`
- **Everything as Code** → `smarteros-specs/`

A single command regenerates your entire world:

```bash
smos deploy all
```

## 📦 What's Inside

```
smarteros-specs/
├── index.yml                   # Entry point to the OS
├── smos-version.yml            # Version control (v0.1.0 "Genesis")
├── smos-runtime-mode.env       # Runtime configuration
├── decision-tree.yml           # 12+ architectural decisions documented
├── tenants/
│   ├── registry.yml           # Registry of all tenants
│   └── template.yml           # Template for creating tenants
├── services/
│   └── registry.yml           # Catalog of 15+ microservices
├── infra/
│   └── infrastructure.yml     # Complete VPS, DNS, Docker specs
└── mcp/                       # MCP configurations (coming soon)
```

## 🏗️ Architecture

### Frontend Services
- **app.smarterbot.cl** - Main web application (Next.js 15)
- **dash.smarterbot.cl** - Multi-tenant dashboard (planned)
- **mkt.smarterbot.cl** - Marketing site (planned)
- **store.smarterbot.cl** - Skills marketplace (planned)
- **docs.smarterbot.cl** - Documentation portal (planned)

### Backend Services
- **N8N** - Workflow automation
- **Supabase** - PostgreSQL + Realtime + Storage
- **Odoo** - ERP multi-company
- **Chatwoot** - Customer support
- **Botpress** - Conversational AI

### Infrastructure
- **Hostinger VPS** - Ubuntu 24.04 (2 CPU, 8GB RAM, 100GB disk)
- **Dokploy** - Container orchestration
- **Traefik** - Reverse proxy + SSL
- **Cloudflare** - DNS + CDN
- **Vercel** - Frontend hosting

## 🚀 Getting Started

### Prerequisites

- Node.js 20+
- Docker 24+
- Git 2.40+
- Codex CLI
- SMOS CLI

### Installation

1. **Clone this repository:**

```bash
git clone git@github.com:SmarterCL/smarteros-specs.git
cd smarteros-specs
```

2. **Configure environment:**

```bash
# Copy environment templates
cp system/env/local/.env.example system/env/local/.env.cloudflare
# Edit with your real tokens
nano system/env/local/.env.cloudflare
```

3. **Validate configuration:**

```bash
smos test all
```

4. **Deploy:**

```bash
smos deploy all
```

## 🧪 CLI Commands

### Deployment
```bash
smos deploy all              # Deploy entire system
smos deploy frontend         # Deploy only frontends (Vercel)
smos deploy backend          # Deploy only backend (VPS)
```

### Tenant Management
```bash
smos create tenant 12345678-9 "Acme Corp" acme.smarterbot.cl
smos tenant list
smos tenant status <tenant_id>
```

### Backup & Restore
```bash
smos backup all              # Full backup
smos backups                 # List available backups
smos restore 20250115-020000 # Restore from backup
```

### Rollback
```bash
smos rollback v0.2.0         # Rollback to previous version
```

### System Status
```bash
smos status                  # System health check
smos logs n8n 100            # View logs
smos logs -f traefik         # Follow logs
```

### Token Validation
```bash
smos test all                # Validate all API tokens
smos test cloudflare         # Test Cloudflare token
smos test hostinger          # Test Hostinger token
smos test shopify            # Test Shopify token
smos test supabase           # Test Supabase token
```

### Sync & Update
```bash
smos sync workflows          # Sync N8N workflows to Git
smos sync specs              # Commit and push specs
smos update codex            # Update Codex CLI
smos update cli              # Update SMOS CLI
```

## 🔐 Security

### Environment Variables

**NEVER commit these files:**
- `system/env/*/.env.*` (except `.env.*.template`)
- Any file containing real API tokens
- SSH keys
- Secrets

**Proper `.gitignore` included.**

### Token Management

See [TOKEN-VALIDATION-GUIDE.md](../TOKEN-VALIDATION-GUIDE.md) for:
- How to obtain each token
- Required permissions
- Validation procedures
- Troubleshooting

## 📖 Documentation

- **[ARCHITECTURE.md](infra/specs/ARCHITECTURE.md)** - Complete technical architecture
- **[decision-tree.yml](decision-tree.yml)** - Architectural decisions (ADRs)
- **[smos-version.yml](smos-version.yml)** - Version history and roadmap
- **[CHANGELOG.md](CHANGELOG.md)** - Version changelog

## 🗺️ Roadmap

### v0.1.0 "Genesis" (Current)
- ✅ Initial OS structure
- ✅ Monorepo setup
- ✅ Codex Agents activation
- ✅ MCP infrastructure
- ✅ N8N backup workflow
- ✅ Vercel auto-deploy
- ✅ SMOS CLI

### v0.2.0 "Foundation" (Target: 2025-02-01)
- Tenant creation automation
- Shopify multi-store integration
- Botpress bot templates
- Odoo multi-company setup
- DNS automation via Cloudflare MCP

### v0.3.0 "Scale" (Target: 2025-03-01)
- Marketplace (store.smarterbot.cl)
- Multi-region support
- Advanced monitoring (Metabase)
- Skills marketplace
- Tenant self-service portal

### v1.0.0 "Production" (Target: 2025-06-01)
- Production-ready security hardening
- SLA monitoring
- Disaster recovery
- High availability
- Performance optimization

## 🤝 Contributing

This is a private repository for SmarterCL internal use.

### Branching Strategy

- `main` - Production-ready releases
- `develop` - Development branch
- `feature/*` - Feature branches
- `hotfix/*` - Urgent fixes

### Commit Convention

```
feat(scope): add new feature
fix(scope): fix bug
docs(scope): update documentation
chore(scope): maintenance task
refactor(scope): code refactoring
test(scope): add tests
```

Examples:
```bash
git commit -m "feat(tenants): add automated provisioning"
git commit -m "fix(dns): correct Cloudflare zone ID"
git commit -m "docs(readme): update installation steps"
```

## 📊 System Requirements

### Development
- macOS or Linux
- 8GB RAM minimum
- 20GB disk space

### Production (VPS)
- Ubuntu 24.04 LTS
- 2 CPU cores
- 8GB RAM
- 100GB disk
- 1TB bandwidth/month

## 💰 Cost Estimation

**Fixed Monthly Costs:**
- VPS (Hostinger): $20
- Domain: $15
- Total Fixed: **$35/month**

**Variable Costs per Tenant:**
- Shopify store: $39/month minimum
- Total per tenant: **$39/month**

**Scaling:**
- 10 tenants: $425/month
- 50 tenants: $1,985/month
- 100 tenants: $3,935/month

## 📞 Support

- **Documentation**: [docs.smarterbot.cl](https://docs.smarterbot.cl)
- **Issues**: GitHub Issues (internal)
- **Email**: dev@smarterbot.cl

## 📄 License

Proprietary - © 2025 SmarterCL. All rights reserved.

---

**Built with ❤️ by SmarterCL Team**

**Powered by:** Next.js, Supabase, N8N, Odoo, Chatwoot, Botpress, Cloudflare, Vercel, Hostinger
