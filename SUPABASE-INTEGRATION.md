# Supabase Integration - smarterOS

**Date:** 2025-11-22 15:25 UTC  
**Status:** ✅ Authenticated and Initialized  
**Project:** smarterOS (`rjfcmmzjlguiititkmyh`)

---

## ✅ Setup Completed

### 1. CLI Installed
- **Version:** 2.58.5
- **Location:** `/usr/local/bin/supabase`

### 2. Authenticated
```bash
✅ Logged in successfully
Token: sbp_78f...df93 (stored securely)
```

### 3. Project Initialized
```bash
✅ supabase init completed
Directory: /root/smarteros-specs/supabase/
Config: config.toml created
```

### 4. Projects Available

| Name | Project ID | Region | Created |
|------|------------|--------|---------|
| **smarterOS** | rjfcmmzjlguiititkmyh | East US | 2025-10-30 |
| supabase-prod | pfixxdpeftdqfvnjarkc | East US | 2025-05-25 |
| supabase-chat | edbklvgrvjqovccwlooj | East US | 2025-05-16 |
| APP_Clerk | ifivhgncrdteemojfngg | East US | 2025-05-08 |
| supabase-pink-ball | faxtnalglncimoobhkoi | East US | 2025-10-05 |

---

## 📋 Project Details

### smarterOS Project
```
Project ID: rjfcmmzjlguiititkmyh
Region: East US (North Virginia)
URL: https://rjfcmmzjlguiititkmyh.supabase.co
Dashboard: https://supabase.com/dashboard/project/rjfcmmzjlguiititkmyh
```

### Configuration Files
```
/root/smarteros-specs/supabase/
├── config.toml          # Supabase configuration
├── .gitignore          # Git ignore rules
├── .env                # Environment variables
└── .temp/              # Temporary files
```

---

## 🔧 Available Commands

### Local Development
```bash
# Start local Supabase (requires Docker)
cd /root/smarteros-specs
supabase start

# Stop local instance
supabase stop

# Check status
supabase status
```

### Database Management
```bash
# Create migration
supabase migration new create_tenants_table

# Apply migrations
supabase db push

# Reset database
supabase db reset

# Dump database
supabase db dump > backup.sql
```

### Type Generation
```bash
# Generate TypeScript types
supabase gen types typescript --linked > types/supabase.ts
```

### Remote Operations
```bash
# Link to remote project (if needed)
supabase link --project-ref rjfcmmzjlguiititkmyh

# View remote database
supabase db remote --help

# Run SQL on remote
supabase db query "SELECT * FROM tenants;"
```

---

## 🏗️ Integration Options for smarterOS

### Option 1: Supabase for Tenant Management
```
Current Architecture:
  ├── Chatwoot (CRM) → PostgreSQL
  ├── Botpress (Bot) → PostgreSQL
  ├── n8n (Workflows) → PostgreSQL
  ├── Odoo (ERP) → PostgreSQL
  └── smarterOS API → Supabase ✨ NEW

Supabase Handles:
  • Tenant CRUD
  • User Authentication (Supabase Auth)
  • Tenant Metadata
  • File Storage (logos, uploads)
  • Realtime Updates
```

### Option 2: Hybrid Database Approach
```
PostgreSQL (self-hosted):
  • Heavy workloads (Chatwoot, Odoo, n8n)
  • Large datasets
  • Complex queries

Supabase (managed):
  • Tenant management
  • User auth & profiles
  • Configuration data
  • Realtime features
  • Storage for assets
```

### Option 3: Supabase Auth + Storage Only
```
Keep existing PostgreSQL for all data
Use Supabase for:
  • Authentication (GoTrue)
  • File storage
  • Realtime subscriptions
```

---

## 📊 Recommended Architecture

### Tenant Management Schema
```sql
-- Create tenants table
CREATE TABLE tenants (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name TEXT NOT NULL,
  slug TEXT UNIQUE NOT NULL,
  domain TEXT UNIQUE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  owner_id UUID REFERENCES auth.users(id),
  metadata JSONB DEFAULT '{}',
  status TEXT DEFAULT 'active' CHECK (status IN ('active', 'suspended', 'deleted'))
);

-- Create tenant_services table
CREATE TABLE tenant_services (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  tenant_id UUID REFERENCES tenants(id) ON DELETE CASCADE,
  service_name TEXT NOT NULL, -- 'chatwoot', 'botpress', 'n8n', 'odoo'
  service_id TEXT, -- External service ID
  config JSONB DEFAULT '{}',
  enabled BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Row Level Security
ALTER TABLE tenants ENABLE ROW LEVEL SECURITY;
ALTER TABLE tenant_services ENABLE ROW LEVEL SECURITY;

-- Policies
CREATE POLICY "Users can view their own tenants"
  ON tenants FOR SELECT
  USING (auth.uid() = owner_id);

CREATE POLICY "Users can create tenants"
  ON tenants FOR INSERT
  WITH CHECK (auth.uid() = owner_id);
```

### Edge Functions for Service Provisioning
```typescript
// supabase/functions/provision-tenant/index.ts
import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'

serve(async (req) => {
  const { tenantId, services } = await req.json()
  
  // Provision services
  const results = {
    chatwoot: await provisionChatwoot(tenantId),
    botpress: await provisionBotpress(tenantId),
    n8n: await provisionN8N(tenantId),
    odoo: await provisionOdoo(tenantId)
  }
  
  return new Response(JSON.stringify(results), {
    headers: { 'Content-Type': 'application/json' }
  })
})
```

---

## 🔐 Security Configuration

### Environment Variables
```bash
# Add to /vault/secrets/smarteros.env
SUPABASE_URL=https://rjfcmmzjlguiititkmyh.supabase.co
SUPABASE_ANON_KEY=<get from dashboard>
SUPABASE_SERVICE_ROLE_KEY=<get from dashboard>
```

### Row Level Security (RLS)
```sql
-- Enable RLS on all tables
ALTER TABLE tenants ENABLE ROW LEVEL SECURITY;

-- Policy: Users can only see their tenants
CREATE POLICY tenant_isolation_policy ON tenants
  FOR ALL
  USING (auth.uid() = owner_id);
```

---

## 🚀 Next Steps

### Immediate
1. [ ] Get API keys from Supabase dashboard
2. [ ] Create tenants schema in Supabase
3. [ ] Set up Row Level Security policies
4. [ ] Configure storage buckets

### Short-term
1. [ ] Create Edge Functions for provisioning
2. [ ] Integrate Supabase Auth with Clerk
3. [ ] Build admin dashboard
4. [ ] Set up realtime subscriptions

### Long-term
1. [ ] Migrate tenant data to Supabase
2. [ ] Implement backup strategy
3. [ ] Set up monitoring
4. [ ] Performance optimization

---

## 📚 Resources

### Dashboard URLs
- **Main Dashboard:** https://supabase.com/dashboard/project/rjfcmmzjlguiititkmyh
- **Database:** https://supabase.com/dashboard/project/rjfcmmzjlguiititkmyh/editor
- **Auth:** https://supabase.com/dashboard/project/rjfcmmzjlguiititkmyh/auth/users
- **Storage:** https://supabase.com/dashboard/project/rjfcmmzjlguiititkmyh/storage/buckets
- **Functions:** https://supabase.com/dashboard/project/rjfcmmzjlguiititkmyh/functions

### Documentation
- **CLI Reference:** https://supabase.com/docs/reference/cli/introduction
- **Database:** https://supabase.com/docs/guides/database
- **Auth:** https://supabase.com/docs/guides/auth
- **Storage:** https://supabase.com/docs/guides/storage
- **Edge Functions:** https://supabase.com/docs/guides/functions

---

## ✅ Status Summary

```
✅ CLI Installed: 2.58.5
✅ Authenticated: Token active
✅ Project Selected: smarterOS (rjfcmmzjlguiititkmyh)
✅ Initialized: /root/smarteros-specs/supabase/
✅ Configuration: Ready

⏳ Next: Get API keys and create schema
⏳ Integration: Define architecture
⏳ Migration: Plan data migration
```

---

**Updated:** 2025-11-22 15:25 UTC  
**Status:** ✅ Ready for Development  
**Project:** smarterOS - Supabase Integration
