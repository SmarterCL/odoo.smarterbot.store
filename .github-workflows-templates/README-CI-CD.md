# SmarterOS — CI/CD Enterprise Pipelines

**GitHub Actions workflows nivel Shopify/Vercel/AWS**

---

## 📦 Workflows Disponibles

### 1. **ci.yml** - Continuous Integration
**Trigger:** Push, Pull Request  
**Duración:** ~5-8 min

**Jobs:**
- ✅ Lint (ESLint + Prettier)
- ✅ Test (Unit + Integration)
- ✅ Build
- ✅ Preview deployment (PRs)

**Success Criteria:**
- All tests pass
- Coverage > 80%
- No lint errors
- Build succeeds

---

### 2. **deploy.yml** - Production Deployment
**Trigger:** Push to main, Manual  
**Duración:** ~10-15 min

**Stages:**
1. **Staging** (auto)
   - Deploy to staging.smarterbot.cl
   - Run smoke tests
   - Manual approval required

2. **Production** (manual approval)
   - Deploy to app.smarterbot.cl
   - Run production smoke tests
   - Create GitHub release
   - Notify Slack + WhatsApp

**Rollback:**
```bash
# Automatic rollback if smoke tests fail
gh workflow run deploy.yml --ref previous-release
```

---

### 3. **docker-build.yml** - Container Build & Push
**Trigger:** Push, Tags  
**Duración:** ~8-12 min

**Stages:**
1. Build multi-arch (amd64 + arm64)
2. Push to GitHub Container Registry
3. Run Trivy vulnerability scan
4. Deploy to Hostinger (if main)

**Images:**
```
ghcr.io/smartercl/smarteros-portal:latest
ghcr.io/smartercl/smarteros-portal:v1.2.3
ghcr.io/smartercl/smarteros-portal:sha-abc123
```

---

### 4. **security-scan.yml** - Security Analysis
**Trigger:** Push, Weekly schedule  
**Duración:** ~15-20 min

**Scans:**
- ✅ CodeQL (SAST)
- ✅ Gitleaks (secrets)
- ✅ TruffleHog (credentials)
- ✅ npm audit (dependencies)
- ✅ Snyk (vulnerabilities)
- ✅ Trivy (container)
- ✅ Semgrep (patterns)
- ✅ License compliance

**Critical findings → Immediate alert**

---

### 5. **backup-integration.yml** - Automated Backups
**Trigger:** Every 6 hours  
**Duración:** ~5-8 min

**Backups:**
- Specifications (docs/)
- n8n workflows
- API Gateway config
- Database schema

**Storage:** AWS S3 (Standard-IA)  
**Retention:** 90 days

---

## 🔧 Setup per Repository

### Portal (Next.js + Vercel)
```bash
cd smarteros-portal
mkdir -p .github/workflows
cp ../smarteros/.github-workflows-templates/ci.yml .github/workflows/
cp ../smarteros/.github-workflows-templates/deploy.yml .github/workflows/
cp ../smarteros/.github-workflows-templates/security-scan.yml .github/workflows/
```

### API Gateway (FastAPI + Docker)
```bash
cd api
mkdir -p .github/workflows
cp ../smarteros/.github-workflows-templates/ci.yml .github/workflows/
cp ../smarteros/.github-workflows-templates/docker-build.yml .github/workflows/
cp ../smarteros/.github-workflows-templates/security-scan.yml .github/workflows/
```

### Theme (Odoo)
```bash
cd odoo-smarter-theme
mkdir -p .github/workflows
cp ../smarteros/.github-workflows-templates/ci.yml .github/workflows/
cp ../smarteros/.github-workflows-templates/docker-build.yml .github/workflows/
```

---

## 🔐 Required Secrets

### Repository Secrets
```bash
# Vercel
VERCEL_TOKEN
VERCEL_ORG_ID
VERCEL_PROJECT_ID

# Clerk
CLERK_PUBLISHABLE_KEY
CLERK_SECRET_KEY
STAGING_CLERK_PUBLISHABLE_KEY

# Supabase
SUPABASE_URL
SUPABASE_ANON_KEY
SUPABASE_SERVICE_ROLE
STAGING_SUPABASE_URL

# AWS
AWS_ACCESS_KEY_ID
AWS_SECRET_ACCESS_KEY

# Security
SNYK_TOKEN
FOSSA_API_KEY
GITLEAKS_LICENSE

# Notifications
SLACK_BOT_TOKEN
API_TOKEN

# Deployment
DEPLOY_TOKEN
GH_PAT
```

### Organization Secrets (shared)
```bash
# GitHub Container Registry (automatic)
GITHUB_TOKEN

# N8N
N8N_API_KEY

# Database
DB_HOST
DB_USER
DB_PASSWORD
DB_NAME
```

---

## 🎯 CI/CD Matrix per Repository

| Repository | ci.yml | deploy.yml | docker.yml | security.yml | backup.yml |
|------------|--------|------------|------------|--------------|------------|
| smarteros-portal | ✅ | ✅ | ❌ | ✅ | ❌ |
| smarteros-landing | ✅ | ✅ | ❌ | ✅ | ❌ |
| smarteros-marketing | ✅ | ✅ | ❌ | ✅ | ❌ |
| smarteros-crm | ✅ | ✅ | ❌ | ✅ | ❌ |
| api | ✅ | ❌ | ✅ | ✅ | ✅ |
| odoo-smarter-theme | ✅ | ❌ | ✅ | ✅ | ❌ |
| smarteros (specs) | ❌ | ❌ | ❌ | ✅ | ✅ |

---

## 📊 Monitoring & Metrics

### GitHub Actions Dashboard
```
https://github.com/SmarterCL/{repo}/actions
```

### Success Rate Target
- CI Pipeline: > 95%
- Deploy Pipeline: > 98%
- Security Scan: 100% pass rate

### Performance Targets
- CI: < 10 min
- Deploy Staging: < 5 min
- Deploy Production: < 10 min
- Security Scan: < 20 min

---

## 🚨 Alerting

### Critical Failures
- Production deploy failed
- Security vulnerability HIGH/CRITICAL
- Secrets detected in code
- Docker build failed

**Notifications:**
- Slack: #deployments
- WhatsApp: +56 9 7954 0471
- Email: dev@smarterbot.cl

---

## 🔄 Rollback Procedures

### Automatic Rollback
Triggered if:
- Smoke tests fail
- Error rate > 5%
- Latency P95 > 2s

### Manual Rollback
```bash
# Via GitHub UI
Actions → Deploy Production → Re-run previous successful

# Via CLI
gh workflow run deploy.yml \
  --ref $(git rev-parse HEAD~1) \
  --field environment=production
```

---

## 📈 Improvements Roadmap

### Q1 2026
- [ ] E2E tests in CI
- [ ] Performance testing
- [ ] Visual regression tests
- [ ] Chaos engineering

### Q2 2026
- [ ] Canary deployments
- [ ] Blue-green deployments
- [ ] Feature flags integration
- [ ] A/B testing automation

---

**Owner:** DevOps Team  
**Version:** 1.0  
**Last Updated:** 2025-11-23
