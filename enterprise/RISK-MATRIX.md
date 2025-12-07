# SMARTEROS — ENTERPRISE RISK MATRIX

---

## Risk Assessment Matrix

| ID | Risk | Probability | Impact | Score | Mitigation |
|----|------|-------------|--------|-------|------------|
| R01 | Data breach | Low | Critical | HIGH | Vault + RLS + Encryption |
| R02 | Service outage | Medium | High | HIGH | DRP + Redundancy |
| R03 | Ransomware | Low | Critical | HIGH | Backups + Monitoring |
| R04 | API DDoS | Medium | Medium | MEDIUM | Cloudflare + Rate limits |
| R05 | Database corruption | Low | Critical | HIGH | Daily backups + Replication |
| R06 | Tenant data leak | Low | Critical | HIGH | RLS + Audit logs |
| R07 | SSL expiration | Low | High | MEDIUM | Auto-renewal + Monitoring |
| R08 | DNS hijacking | Very Low | Critical | MEDIUM | DNSSEC + 2FA |
| R09 | Insider threat | Very Low | Critical | MEDIUM | Access control + Audit |
| R10 | Third-party failure | Medium | Medium | MEDIUM | Multi-provider strategy |
| R11 | Compliance violation | Low | High | MEDIUM | Regular audits |
| R12 | Data residency | Low | Medium | LOW | Chile-only hosting |
| R13 | Key person risk | Medium | High | HIGH | Documentation + Cross-training |
| R14 | Budget overrun | Medium | Medium | MEDIUM | Cost monitoring |
| R15 | Performance degradation | Medium | Medium | MEDIUM | Observability + Auto-scaling |

---

## Risk Scoring

**Probability:**
- Very Low: < 5%
- Low: 5-20%
- Medium: 20-50%
- High: > 50%

**Impact:**
- Low: < $1K loss
- Medium: $1K-$10K loss
- High: $10K-$100K loss
- Critical: > $100K loss or reputation damage

**Score = Probability × Impact**

---

## Top 5 Risks (Action Required)

### 1. Data Breach (R01)
**Controls:**
- ✅ Vault secrets management
- ✅ RLS on all tables
- ✅ Encryption at rest
- ⏳ Penetration testing (Q1 2026)

### 2. Service Outage (R02)
**Controls:**
- ✅ DRP documented
- ✅ Backups automated
- ⏳ Multi-region (Q2 2026)

### 3. Ransomware (R03)
**Controls:**
- ✅ Offline backups
- ✅ WAF enabled
- ⏳ EDR solution (Q1 2026)

### 4. Database Corruption (R05)
**Controls:**
- ✅ Hourly backups
- ⏳ Read replica (Q1 2026)

### 5. Tenant Data Leak (R06)
**Controls:**
- ✅ RLS policies
- ✅ Audit logs
- ⏳ Data masking (Q2 2026)

---

**Owner:** CTO + Security Officer  
**Review:** Quarterly
