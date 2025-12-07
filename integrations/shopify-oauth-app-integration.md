# Shopify OAuth Integration - app.smarterbot.cl
# Date: 2025-11-19T15:28:00Z
# Purpose: User-facing Shopify connection flow

## 🎯 Overview

User authenticates via Clerk (RUT validated) → connects their Shopify store → credentials stored in Vault → MCP activates per tenant.

---

## 🔐 Authentication Flow

### Prerequisites
1. User logged in via Clerk
2. RUT validated and stored in user metadata
3. Tenant created in registry (`tenants/registry.yml`)

### Step-by-Step Flow

#### 1. User Access Settings Page
**URL:** `https://app.smarterbot.cl/settings/integrations`

**UI Component:**
```tsx
// app/settings/integrations/page.tsx
import { useUser } from '@clerk/nextjs'

export default function IntegrationsPage() {
  const { user } = useUser()
  const tenantId = user?.publicMetadata?.tenant_id
  const rut = user?.publicMetadata?.rut

  return (
    <div>
      <h1>Integraciones</h1>
      
      <IntegrationCard
        name="Shopify"
        description="Conecta tu tienda Shopify"
        icon={<ShopifyIcon />}
        status={shopifyStatus}
        onConnect={handleShopifyConnect}
        onDisconnect={handleShopifyDisconnect}
      />
    </div>
  )
}
```

#### 2. User Clicks "Connect Shopify"

**Action:** Trigger OAuth flow

```tsx
// components/ShopifyConnectButton.tsx
async function handleShopifyConnect() {
  // Step 1: Get tenant info from Clerk
  const tenantId = user?.publicMetadata?.tenant_id
  const rut = user?.publicMetadata?.rut
  
  if (!tenantId || !rut) {
    toast.error("RUT no validado. Completa tu perfil primero.")
    return
  }

  // Step 2: Generate state token (CSRF protection)
  const state = await generateStateToken(tenantId, sessionId)
  
  // Step 3: Ask user for Shopify store domain
  const storeDomain = prompt("Ingresa tu dominio Shopify (ej: mi-tienda.myshopify.com)")
  
  if (!storeDomain) return
  
  // Step 4: Build OAuth URL
  const oauthUrl = buildShopifyOAuthUrl({
    shop: storeDomain,
    clientId: process.env.NEXT_PUBLIC_SHOPIFY_CLIENT_ID,
    redirectUri: `${process.env.NEXT_PUBLIC_APP_URL}/api/auth/shopify/callback`,
    scopes: "read_products,write_products,read_orders,write_orders,read_inventory",
    state: state
  })
  
  // Step 5: Redirect to Shopify
  window.location.href = oauthUrl
}
```

**OAuth URL Example:**
```
https://mi-tienda.myshopify.com/admin/oauth/authorize
  ?client_id=abc123xyz
  &scope=read_products,write_products,read_orders
  &redirect_uri=https://app.smarterbot.cl/api/auth/shopify/callback
  &state=tenant_demo_001:session_abc123
```

#### 3. User Authorizes in Shopify

User sees Shopify permission screen:
- ✅ Read products
- ✅ Write products
- ✅ Read orders
- ✅ Write orders
- ✅ Read inventory

User clicks **"Install app"**

#### 4. Shopify Redirects to Callback

**Endpoint:** `POST /api/auth/shopify/callback`

```typescript
// app/api/auth/shopify/callback/route.ts
import { NextRequest, NextResponse } from 'next/server'
import { auth } from '@clerk/nextjs'

export async function GET(req: NextRequest) {
  const { userId } = auth()
  if (!userId) {
    return NextResponse.redirect('/sign-in')
  }

  // Step 1: Parse callback params
  const searchParams = req.nextUrl.searchParams
  const code = searchParams.get('code')
  const shop = searchParams.get('shop')
  const state = searchParams.get('state')
  
  if (!code || !shop || !state) {
    return NextResponse.json({ error: 'Missing parameters' }, { status: 400 })
  }

  // Step 2: Validate state (CSRF protection)
  const [tenantId, sessionId] = state.split(':')
  const isValidState = await validateStateToken(state, userId)
  
  if (!isValidState) {
    return NextResponse.json({ error: 'Invalid state token' }, { status: 403 })
  }

  // Step 3: Exchange code for access_token
  const tokenResponse = await fetch(
    `https://${shop}/admin/oauth/access_token`,
    {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        client_id: process.env.SHOPIFY_CLIENT_ID,
        client_secret: process.env.SHOPIFY_CLIENT_SECRET,
        code: code
      })
    }
  )

  const { access_token, scope } = await tokenResponse.json()

  // Step 4: Store credentials in Vault
  await storeShopifyCredentials({
    tenantId: tenantId,
    storeDomain: shop,
    accessToken: access_token,
    scopes: scope,
    connectedAt: new Date().toISOString()
  })

  // Step 5: Update tenant registry
  await updateTenantRegistry(tenantId, {
    'services.shopify.enabled': true,
    'services.shopify.store_url': shop,
    'services.shopify.connected_at': new Date().toISOString()
  })

  // Step 6: Activate Shopify MCP for tenant
  await activateShopifyMCP(tenantId)

  // Step 7: Redirect back to settings
  return NextResponse.redirect('/settings/integrations?success=shopify')
}
```

#### 5. Store Credentials in Vault

**Function:** `storeShopifyCredentials()`

```typescript
// lib/vault.ts
import VaultClient from '@smarteros/vault-client'

const vault = new VaultClient({
  endpoint: 'https://mainkey.smarterbot.cl',
  token: process.env.VAULT_TOKEN
})

export async function storeShopifyCredentials(data: {
  tenantId: string
  storeDomain: string
  accessToken: string
  scopes: string
  connectedAt: string
}) {
  const path = `secret/tenant/${data.tenantId}/shopify`
  
  await vault.write(path, {
    store_domain: data.storeDomain,
    access_token: data.accessToken,
    scopes: data.scopes,
    connected_at: data.connectedAt,
    status: 'active'
  })
  
  console.log(`✅ Shopify credentials stored for tenant ${data.tenantId}`)
}
```

**Vault Path Structure:**
```
secret/
  tenant/
    tenant_demo_001/
      shopify/
        store_domain: "mi-tienda.myshopify.com"
        access_token: "shpat_xxxxxxxxxxxxx"
        scopes: "read_products,write_products,read_orders"
        connected_at: "2025-11-19T15:30:00Z"
        status: "active"
```

#### 6. Activate Shopify MCP

**Function:** `activateShopifyMCP()`

```typescript
// lib/mcp.ts
export async function activateShopifyMCP(tenantId: string) {
  // Update MCP registry
  await fetch('https://mcp.smarterbot.cl/api/mcp/shopify/activate', {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'Authorization': `Bearer ${process.env.MCP_API_KEY}`
    },
    body: JSON.stringify({
      tenant_id: tenantId,
      status: 'active',
      activated_at: new Date().toISOString()
    })
  })
  
  console.log(`✅ Shopify MCP activated for tenant ${tenantId}`)
}
```

---

## 🎨 UI Components

### Integration Card (Settings Page)

**Component:** `components/IntegrationCard.tsx`

```tsx
interface IntegrationCardProps {
  name: string
  description: string
  icon: React.ReactNode
  status: 'active' | 'inactive' | 'error'
  onConnect: () => void
  onDisconnect: () => void
}

export function IntegrationCard({
  name,
  description,
  icon,
  status,
  onConnect,
  onDisconnect
}: IntegrationCardProps) {
  return (
    <div className="border rounded-lg p-6">
      <div className="flex items-center justify-between">
        <div className="flex items-center gap-4">
          <div className="w-12 h-12">{icon}</div>
          <div>
            <h3 className="font-semibold text-lg">{name}</h3>
            <p className="text-sm text-gray-600">{description}</p>
          </div>
        </div>
        
        <div className="flex items-center gap-3">
          <StatusBadge status={status} />
          
          {status === 'inactive' ? (
            <Button onClick={onConnect}>
              Conectar
            </Button>
          ) : (
            <Button variant="outline" onClick={onDisconnect}>
              Desconectar
            </Button>
          )}
        </div>
      </div>
      
      {status === 'active' && (
        <div className="mt-4 pt-4 border-t">
          <ShopifySettings />
        </div>
      )}
    </div>
  )
}
```

### Shopify Settings Panel

```tsx
function ShopifySettings() {
  const { data: shopifyConfig } = useShopifyConfig()
  
  return (
    <div className="space-y-3">
      <div>
        <label className="text-sm text-gray-600">Tienda</label>
        <p className="font-mono text-sm">{shopifyConfig?.store_domain}</p>
      </div>
      
      <div>
        <label className="text-sm text-gray-600">Conectado el</label>
        <p className="text-sm">
          {new Date(shopifyConfig?.connected_at).toLocaleDateString('es-CL')}
        </p>
      </div>
      
      <div className="flex items-center justify-between">
        <div>
          <label className="text-sm text-gray-600">Webhooks</label>
          <p className="text-xs text-gray-500">
            Recibir eventos de órdenes y productos
          </p>
        </div>
        <Switch
          checked={shopifyConfig?.webhooks_enabled}
          onCheckedChange={handleWebhooksToggle}
        />
      </div>
      
      <Button
        variant="outline"
        size="sm"
        onClick={handleSyncProducts}
        className="w-full"
      >
        Sincronizar productos ahora
      </Button>
    </div>
  )
}
```

---

## 🔒 Security Considerations

### 1. State Token Generation (CSRF Protection)

```typescript
// lib/auth.ts
import { randomBytes } from 'crypto'
import { redis } from '@/lib/redis'

export async function generateStateToken(
  tenantId: string,
  sessionId: string
): Promise<string> {
  const nonce = randomBytes(16).toString('hex')
  const state = `${tenantId}:${sessionId}:${nonce}`
  
  // Store in Redis with 10min TTL
  await redis.setex(
    `oauth_state:${state}`,
    600, // 10 minutes
    JSON.stringify({ tenantId, sessionId, createdAt: Date.now() })
  )
  
  return state
}

export async function validateStateToken(
  state: string,
  userId: string
): Promise<boolean> {
  const data = await redis.get(`oauth_state:${state}`)
  
  if (!data) return false
  
  const { tenantId, sessionId, createdAt } = JSON.parse(data)
  
  // Validate expiration (10 min)
  if (Date.now() - createdAt > 600000) return false
  
  // Validate tenant ownership
  const userTenant = await getTenantIdFromUser(userId)
  if (userTenant !== tenantId) return false
  
  // Delete state token (one-time use)
  await redis.del(`oauth_state:${state}`)
  
  return true
}
```

### 2. Access Token Encryption

Vault handles encryption at rest. Additional app-level encryption not needed.

### 3. RUT Validation

```typescript
// lib/rut-validator.ts
export function validateRUT(rut: string): boolean {
  // Remove dots and dash
  const cleanRut = rut.replace(/\./g, '').replace(/-/g, '')
  
  // Extract number and verification digit
  const rutNumber = cleanRut.slice(0, -1)
  const verifier = cleanRut.slice(-1).toUpperCase()
  
  // Calculate expected verifier
  let sum = 0
  let multiplier = 2
  
  for (let i = rutNumber.length - 1; i >= 0; i--) {
    sum += parseInt(rutNumber[i]) * multiplier
    multiplier = multiplier === 7 ? 2 : multiplier + 1
  }
  
  const expectedVerifier = 11 - (sum % 11)
  const verifierChar = expectedVerifier === 11 ? '0' : expectedVerifier === 10 ? 'K' : expectedVerifier.toString()
  
  return verifier === verifierChar
}
```

---

## 📊 Database Schema (Supabase)

### Table: `tenant_integrations`

```sql
CREATE TABLE tenant_integrations (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  tenant_id TEXT NOT NULL REFERENCES tenants(id),
  integration_name TEXT NOT NULL, -- 'shopify', 'odoo', etc
  status TEXT NOT NULL DEFAULT 'inactive', -- 'active', 'inactive', 'error'
  config JSONB NOT NULL DEFAULT '{}',
  connected_at TIMESTAMPTZ,
  disconnected_at TIMESTAMPTZ,
  last_sync_at TIMESTAMPTZ,
  error_message TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  
  UNIQUE(tenant_id, integration_name)
);

-- Index for fast lookups
CREATE INDEX idx_tenant_integrations_tenant_id ON tenant_integrations(tenant_id);
CREATE INDEX idx_tenant_integrations_status ON tenant_integrations(status);
```

### Example Row:

```json
{
  "id": "uuid-123",
  "tenant_id": "tenant_demo_001",
  "integration_name": "shopify",
  "status": "active",
  "config": {
    "store_domain": "mi-tienda.myshopify.com",
    "webhooks_enabled": true,
    "last_product_sync": "2025-11-19T15:30:00Z"
  },
  "connected_at": "2025-11-19T15:25:00Z",
  "last_sync_at": "2025-11-19T15:30:00Z",
  "created_at": "2025-11-19T15:25:00Z"
}
```

---

## 🚀 API Endpoints

### 1. Get Integration Status
```
GET /api/integrations/shopify
Authorization: Bearer <clerk_token>
```

Response:
```json
{
  "status": "active",
  "store_domain": "mi-tienda.myshopify.com",
  "connected_at": "2025-11-19T15:25:00Z",
  "webhooks_enabled": true,
  "last_sync_at": "2025-11-19T15:30:00Z"
}
```

### 2. Disconnect Shopify
```
DELETE /api/integrations/shopify
Authorization: Bearer <clerk_token>
```

Action:
- Revoke OAuth token in Shopify
- Delete credentials from Vault
- Update tenant registry
- Deactivate Shopify MCP

---

## ✅ Testing Checklist

- [ ] User can access `/settings/integrations`
- [ ] "Connect Shopify" button visible for inactive status
- [ ] OAuth flow redirects to Shopify correctly
- [ ] State token validates properly (CSRF protection)
- [ ] Access token exchange succeeds
- [ ] Credentials stored in Vault successfully
- [ ] Tenant registry updated
- [ ] Shopify MCP activated
- [ ] Settings panel shows store info
- [ ] "Disconnect" button works
- [ ] Webhooks toggle works
- [ ] "Sync products" triggers sync

---

**Created:** 2025-11-19T15:28:00Z  
**Status:** Spec ready for implementation  
**Next:** Implement OAuth callback endpoint in app.smarterbot.cl
