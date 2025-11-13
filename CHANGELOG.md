# Changelog

All notable changes to SmarterOS will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Planned for v0.2.0
- Tenant creation automation via `smos create tenant`
- Shopify multi-store integration
- Botpress bot templates
- Odoo multi-company setup
- DNS automation via Cloudflare MCP
- Automated SSL certificate management

## [0.1.0] - 2025-01-15 - "Genesis Release"

### Added
- **Infrastructure**
  - Complete monorepo structure (`front/`, `back/`, `infra/`, `tenants/`, `system/`)
  - 16,618 directories organized by role and microservice
  - VPS configuration on Hostinger (Ubuntu 24.04, 2 CPU, 8GB RAM)
  - Docker + Dokploy orchestration
  - Traefik reverse proxy with automatic SSL
  - Cloudflare DNS + CDN integration

- **Spec Repository**
  - `index.yml` - Complete OS specification
  - `smos-version.yml` - Version control and roadmap
  - `smos-runtime-mode.env` - Runtime configuration (development/staging/production)
  - `decision-tree.yml` - 12 architectural decisions documented (ADRs)
  - `tenants/registry.yml` - Multi-tenant tracking system
  - `tenants/template.yml` - Complete tenant provisioning template
  - `services/registry.yml` - Catalog of 15+ microservices
  - `infra/infrastructure.yml` - Complete infrastructure specification

- **Codex Integration**
  - `codex.toml` with 6 agents and 7 MCPs configured
  - Agent scripts for deployment, tenants, backups, DNS, workflows, bots
  - VS Code integration (settings.json + keybindings.json)
  - 15+ keyboard shortcuts for common operations
  - Daemon configuration for local development

- **CLI Tools**
  - `smos` - Main CLI for system management
    - `deploy` - Deploy services
    - `create tenant` - Tenant provisioning
    - `backup`/`restore` - Data management
    - `rollback` - Version rollback
    - `status` - System health check
    - `logs` - Log viewing
    - `sync` - Workflow/spec synchronization
    - `update` - Component updates
    - `test` - Token validation
  - `smos-test` - API token validation tool
    - Validates Cloudflare, Hostinger, Shopify, Supabase tokens
    - Colorized output with detailed error messages
    - Individual and batch testing

- **Frontend Applications**
  - `app.smarterbot.cl` - Main web app (Next.js 15, Clerk auth, Supabase)
  - Connected to Vercel with auto-deploy on push to main
  - Environment templates for all services

- **Backend Services**
  - N8N (1.62.0) - Workflow automation
  - Odoo (17.0) - ERP multi-company
  - Chatwoot (3.13.0) - Customer support
  - Botpress (12.26.0) - Conversational AI
  - PostgreSQL (16) - Primary database
  - Redis (7.2) - Cache layer
  - Metabase - Analytics and observability

- **Automation**
  - N8N backup workflow (daily at 2 AM, 7-day retention)
  - Automated backup of PostgreSQL, Docker volumes, N8N data
  - Health checks every 5 minutes
  - Auto-cleanup of old backups

- **MCP Servers**
  - GitHub MCP (built-in)
  - Context7 MCP (built-in)
  - Cloudflare MCP (DNS, CDN, Workers)
  - Hostinger MCP (VPS management)
  - Shopify MCP (E-commerce multi-tenant)
  - Supabase MCP (Database operations)
  - Docker MCP (Container management)

- **Documentation**
  - `ARCHITECTURE.md` - Complete technical architecture (400+ lines)
  - `TOKEN-VALIDATION-GUIDE.md` - API token setup and validation
  - `SPEC-REPO-ACTIVATED.md` - Spec repository guide
  - `CODEX-ACTIVATION-COMPLETE.md` - Codex Agents guide
  - `SETUP-COMPLETE.md` - Initial setup documentation
  - `ACTIVATION-GUIDE.md` - Environment activation guide
  - `GIT-VERCEL-STATUS.md` - Git and Vercel integration

- **Git Configuration**
  - `.gitignore` with proper exclusions for secrets
  - Environment templates (`.env.*.template`)
  - Branch structure (main for production)

### Changed
- Migrated from nested repository structure to organized monorepo
- Centralized all environment variables in `system/env/`
- Standardized naming conventions across all services

### Security
- Proper `.gitignore` for secrets and tokens
- Environment variable templates without sensitive data
- SSH key-only authentication for VPS
- Firewall rules configured (ports 22, 80, 443)
- SSL certificates via Let's Encrypt
- Row Level Security (RLS) in Supabase for multi-tenant isolation

### Infrastructure
- **VPS**: Hostinger (89.116.23.167, srv814944.hstgr.cloud)
- **DNS**: Cloudflare (smarterbot.cl zone)
- **Frontend**: Vercel (app.smarterbot.cl)
- **Database**: Supabase (PostgreSQL 16)
- **Auth**: Clerk
- **Containers**: Docker + Dokploy
- **Reverse Proxy**: Traefik 2.11
- **Backup**: Daily at 2 AM, 7-day retention, stored in `/backups/`

### Developer Experience
- VS Code workspace with custom keybindings
- Codex daemon for AI-powered development
- SMOS CLI for one-command operations
- Automated testing and validation
- Comprehensive documentation

### Known Issues
- Codex daemon health check not responding (expected - using MCP server mode instead)
- Backend repositories not yet initialized (n8n, supabase, mcp)
- Additional frontend projects not initialized (dash, mkt, store, docs)
- API tokens need manual configuration in `.env.*` files

### Breaking Changes
None - this is the initial release.

### Migration Notes
Not applicable - initial release.

---

## Version History

### Naming Convention
Each version has a codename:
- **v0.1.0** - Genesis (Beginning)
- **v0.2.0** - Foundation (Stable base)
- **v0.3.0** - Scale (Growth)
- **v1.0.0** - Production (Ready for prime time)

### Release Schedule
- Minor versions: Monthly
- Patch versions: As needed
- Major version: When production-ready

### Upgrade Path
```bash
# Check current version
smos --version

# Rollback to previous version
smos rollback v0.1.0

# Deploy specific version
smos deploy --version v0.2.0
```

---

## Links
- [Repository](https://github.com/SmarterCL/smarteros-specs)
- [Documentation](https://docs.smarterbot.cl)
- [Issues](https://github.com/SmarterCL/smarteros-specs/issues)
