# 🔒 Security Policy - SmarterOS

## 🎯 Security Model

SmarterOS implements a **defense-in-depth** security strategy with multiple layers:

```
┌─────────────────────────────────────┐
│  Layer 1: Authentication (Clerk)   │
├─────────────────────────────────────┤
│  Layer 2: Authorization (JWT)      │
├─────────────────────────────────────┤
│  Layer 3: Multi-tenant (RLS)       │
├─────────────────────────────────────┤
│  Layer 4: Secrets (Vault)          │
├─────────────────────────────────────┤
│  Layer 5: Transport (SSL/TLS)      │
└─────────────────────────────────────┘
```

---

## 🔐 Authentication & Authorization

### SSO (Clerk)
- OAuth 2.0 / OpenID Connect
- Multi-factor authentication (MFA)
- Session management
- JWT token verification

### API Gateway
- All requests verified via JWT
- Rate limiting per tenant
- IP whitelisting (optional)
- Request signing

---

## 🏢 Multi-Tenant Isolation

### Database Level (Supabase)
```sql
-- Row Level Security (RLS)
CREATE POLICY tenant_isolation ON users
  USING (tenant_id = current_setting('app.tenant_id'));
```

### Application Level (Odoo)
- Multi-company architecture
- Data isolation by `company_id`
- Access rights per user
- Record rules

### File Storage
- S3 buckets per tenant
- Encrypted at rest
- Access via signed URLs only

---

## 🔑 Secrets Management

### HashiCorp Vault
```
vault/
├─ database/
│  ├─ odoo_password
│  └─ postgres_password
├─ api/
│  ├─ clerk_secret
│  ├─ openai_api_key
│  └─ supabase_key
└─ integrations/
   ├─ shopify_token
   └─ n8n_webhook_secret
```

### Environment Variables
- Never commit to Git
- Stored in Vault
- Injected at runtime
- Rotated regularly

---

## 🛡️ Network Security

### Firewall Rules (UFW)
```bash
ufw default deny incoming
ufw default allow outgoing
ufw allow ssh
ufw allow http
ufw allow https
ufw enable
```

### Reverse Proxy (Caddy)
- Automatic SSL/TLS (Let's Encrypt)
- HTTP/2 & HTTP/3
- Security headers
- Rate limiting

### DDoS Protection (Cloudflare)
- Layer 7 DDoS mitigation
- WAF rules
- Bot management
- IP blocking

---

## 📝 Audit Logging

### MCP Audit Tool
All sensitive operations are logged:

```json
{
  "timestamp": "2025-11-23T12:00:00Z",
  "user_id": "user_xxx",
  "tenant_id": "12345678-9",
  "action": "user.login",
  "resource": "odoo.smarterbot.cl",
  "ip": "1.2.3.4",
  "status": "success"
}
```

### Log Retention
- 90 days minimum
- Stored in Supabase
- Encrypted at rest
- Compliance-ready (ISO 27001)

---

## 🚨 Incident Response

### Detection
1. Automated alerts (MCP monitoring)
2. Anomaly detection (unusual API usage)
3. Failed login attempts (Clerk)
4. Database queries (slow query log)

### Response Time
- **Critical:** < 1 hour
- **High:** < 4 hours
- **Medium:** < 24 hours
- **Low:** < 7 days

### Contact
**Security Team:** security@smarterbot.cl  
**PGP Key:** Available on request

---

## 🔍 Vulnerability Disclosure

### Reporting
1. Email: security@smarterbot.cl
2. Subject: `[SECURITY] Brief description`
3. Include:
   - Description
   - Steps to reproduce
   - Impact assessment
   - Suggested fix (optional)

### Response Process
1. Acknowledgment: < 24 hours
2. Investigation: < 7 days
3. Fix deployment: < 30 days
4. Public disclosure: After fix

### Bug Bounty
- Coming soon
- Rewards based on severity
- Hall of Fame for researchers

---

## 📋 Compliance

### Standards
- ✅ OWASP Top 10 (addressed)
- ✅ CWE Top 25 (mitigated)
- ✅ ISO 27001 (in progress)
- ✅ SOC 2 Type II (planned 2026)

### Data Protection
- GDPR-ready architecture
- Data residency (Chile)
- Right to erasure
- Data portability

### Chile Specific
- Ley 19.628 (Protección Datos)
- SII integration secure
- RUT validation
- Facturación electrónica (DTE)

---

## 🔄 Security Updates

### Patching Schedule
- **Critical:** Immediate
- **High:** < 7 days
- **Medium:** < 30 days
- **Low:** Next release

### Dependency Updates
```bash
# Monthly security scan
docker scan smarteros/odoo:latest
npm audit
pip-audit
```

---

## ✅ Security Checklist (Production)

```
[ ] SSL/TLS certificates valid
[ ] Firewall rules active
[ ] Secrets in Vault (not .env)
[ ] RLS policies enabled
[ ] Audit logs working
[ ] Backups encrypted
[ ] MFA enabled for admins
[ ] Rate limiting active
[ ] WAF rules configured
[ ] Security headers set
[ ] CORS properly configured
[ ] SQL injection tests passed
[ ] XSS tests passed
[ ] CSRF tokens validated
```

---

## 📞 Security Contacts

**General:** security@smarterbot.cl  
**Emergency:** +56 9 7954 0471  
**PGP:** Available on request

---

**Last Updated:** 2025-11-23  
**Version:** 1.0  
**Next Review:** 2025-12-23
