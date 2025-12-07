# 🏢 Multi-Tenant Model - SmarterOS

## 🎯 Overview

SmarterOS uses **RUT (Rol Único Tributario)** as the primary tenant identifier, enabling true multi-tenancy for Chilean businesses.

---

## 🔑 Tenant Structure

### Tenant ID Format

```
RUT: 12345678-9
  ↓
Normalized: 123456789
  ↓
Tenant ID (UUID): gen_uuid_from_rut('123456789')
  ↓
tenant_id: 550e8400-e29b-41d4-a716-446655440000
```

---

## 📊 Database Schema

### Core Tables (Supabase)

```sql
-- Tenants Table
CREATE TABLE tenants (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  rut VARCHAR(12) UNIQUE NOT NULL,
  business_name VARCHAR(255) NOT NULL,
  plan VARCHAR(50) DEFAULT 'free',
  status VARCHAR(20) DEFAULT 'active',
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Users Table
CREATE TABLE users (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id UUID REFERENCES tenants(id) ON DELETE CASCADE,
  clerk_user_id VARCHAR(255) UNIQUE NOT NULL,
  email VARCHAR(255) NOT NULL,
  role VARCHAR(50) DEFAULT 'user',
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Row Level Security
ALTER TABLE users ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users see own tenant only"
ON users
FOR ALL
USING (tenant_id = current_setting('app.tenant_id')::uuid);
```

---

## 🔐 Isolation Layers

### 1. Database Level (RLS)

```sql
-- Set tenant context
SELECT set_config('app.tenant_id', '550e8400-...', false);

-- All queries auto-filtered
SELECT * FROM leads;
-- Becomes:
SELECT * FROM leads WHERE tenant_id = '550e8400-...';
```

### 2. Application Level (Odoo)

```python
# Odoo multi-company
from odoo import models, fields

class ResPartner(models.Model):
    _inherit = 'res.partner'
    
    company_id = fields.Many2one('res.company', required=True)
    
    @api.model
    def _search(self, args, **kwargs):
        # Auto-filter by company
        company = self.env.company
        args += [('company_id', '=', company.id)]
        return super()._search(args, **kwargs)
```

### 3. File Storage

```
S3 Bucket Structure:
smarteros-files/
├─ tenant-550e8400/
│  ├─ invoices/
│  ├─ products/
│  └─ uploads/
├─ tenant-660f9511/
│  ├─ invoices/
│  └─ ...
```

---

## 🎭 Tenant Lifecycle

### 1. Registration

```javascript
// Portal signup
POST /api/tenants/register
{
  "rut": "12345678-9",
  "business_name": "Mi Empresa SPA",
  "email": "admin@miempresa.cl",
  "plan": "starter"
}

// Response
{
  "tenant_id": "550e8400-...",
  "status": "provisioning",
  "onboarding_url": "https://app.smarterbot.cl/onboard"
}
```

### 2. Provisioning

```
1. Create tenant record in Supabase
2. Create Odoo company
3. Setup n8n workspace
4. Create Chatwoot inbox
5. Initialize Botpress agent
6. Configure Metabase filters
7. Send welcome email
8. Status → active
```

### 3. Deactivation

```javascript
// Soft delete
UPDATE tenants 
SET status = 'inactive', 
    deactivated_at = NOW()
WHERE id = '550e8400-...';

// Data retention: 30 days
// Full delete after 30 days
```

---

## 🔄 Tenant Switching (Admin)

### API Gateway

```python
# Switch tenant context
from fastapi import Header

async def get_current_tenant(
    x_tenant_id: str = Header(None)
) -> str:
    if not x_tenant_id:
        # Get from JWT
        tenant_id = jwt_payload.get('tenant_id')
    else:
        # Admin override
        tenant_id = x_tenant_id
    
    return tenant_id
```

### Frontend

```typescript
// Admin panel
const switchTenant = async (tenantId: string) => {
  localStorage.setItem('admin_tenant_override', tenantId)
  await router.push('/dashboard')
  router.reload()
}
```

---

## 📊 Tenant Metrics

### Per-Tenant Usage

```sql
-- Monthly usage
SELECT 
  t.rut,
  t.business_name,
  COUNT(DISTINCT u.id) as users,
  COUNT(DISTINCT l.id) as leads,
  COUNT(DISTINCT o.id) as orders
FROM tenants t
LEFT JOIN users u ON u.tenant_id = t.id
LEFT JOIN leads l ON l.tenant_id = t.id
LEFT JOIN orders o ON o.tenant_id = t.id
WHERE t.created_at >= NOW() - INTERVAL '30 days'
GROUP BY t.id;
```

### Billing

```sql
-- Calculate monthly cost
SELECT 
  t.id,
  t.plan,
  CASE t.plan
    WHEN 'free' THEN 0
    WHEN 'starter' THEN 29
    WHEN 'business' THEN 99
    WHEN 'enterprise' THEN 299
  END as base_cost,
  -- Add-ons
  (SELECT COUNT(*) FROM tenant_addons WHERE tenant_id = t.id AND addon = 'ecommerce') * 49 as ecommerce_cost
FROM tenants t
WHERE t.status = 'active';
```

---

## 🔒 Security Considerations

### 1. Tenant Verification

```python
# Every API call
def verify_tenant_access(user_id: str, tenant_id: str) -> bool:
    user = db.query(User).filter(User.clerk_id == user_id).first()
    return user.tenant_id == tenant_id
```

### 2. Cross-Tenant Prevention

```sql
-- Audit trigger
CREATE OR REPLACE FUNCTION check_tenant_access()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.tenant_id != current_setting('app.tenant_id')::uuid THEN
    RAISE EXCEPTION 'Cross-tenant access attempt detected';
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER enforce_tenant_isolation
  BEFORE INSERT OR UPDATE ON leads
  FOR EACH ROW
  EXECUTE FUNCTION check_tenant_access();
```

---

## 🧪 Testing Multi-Tenancy

### Test Suite

```python
import pytest

def test_tenant_isolation():
    # Create 2 tenants
    tenant_a = create_tenant(rut='11111111-1')
    tenant_b = create_tenant(rut='22222222-2')
    
    # Create lead for tenant A
    lead = create_lead(tenant_id=tenant_a.id, email='test@a.com')
    
    # Try to access from tenant B
    set_tenant_context(tenant_b.id)
    result = get_lead(lead.id)
    
    assert result is None  # Should not see tenant A's data
```

---

## 📈 Scaling Considerations

### Sharding Strategy (Future)

```
Tenants 0-10,000    → DB Shard 1
Tenants 10,001-20,000 → DB Shard 2
Tenants 20,001+      → DB Shard 3
```

### Resource Limits

```yaml
# Per-tenant limits
limits:
  users: 100
  api_calls_per_minute: 1000
  storage_gb: 10
  workflows: 50
```

---

## 🎯 Best Practices

1. **Always set tenant context** before queries
2. **Never trust client-provided tenant_id**
3. **Use RLS policies** for all tenant-aware tables
4. **Audit cross-tenant attempts**
5. **Test isolation** in CI/CD
6. **Monitor per-tenant metrics**
7. **Backup per tenant** (optional)

---

**Version:** 1.0  
**Last Updated:** 2025-11-23  
**Owner:** SmarterCL Engineering
