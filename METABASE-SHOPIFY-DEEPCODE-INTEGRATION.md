# 🚀 Metabase + Shopify + DeepCode - Complete Integration
Date: 2025-11-18T20:30:45.123Z

## ✅ Archivos Generados

### 1. Metabase Dashboards (3 dashboards)

📄 `/root/specs/metabase/nexa-runtime-overview.json`
   - Total Requests (24h)
   - Requests by Tenant (Heatmap)
   - Average Latency by Model
   - Token Consumption (Daily)
   - Error Map (Top 10)
   - Requests by Endpoint
   - Success Rate (%)

📄 `/root/specs/metabase/shopify-smart-prompts.json`
   - Active Prompts by Store
   - Prompts Execution Rate
   - Token Usage by Store
   - Average Response Time
   - Last Prompt Updates

📄 `/root/specs/metabase/tenant-health-monitor.json`
   - Last Activity
   - Total Requests (All Time)
   - Error Rate (24h)
   - Request Timeline (7 days)
   - Model Usage Distribution
   - Average Latency Trend
   - Token Consumption Stats
   - Active Shopify Stores

### 2. Shopify Workflow

📄 `/root/specs/workflows/shopify/dynamic-prompt-engine.json`
   - Webhook trigger para eventos Shopify
   - Lookup de prompts en Supabase
   - Build de request con contexto
   - Call a Nexa Runtime con X-Tenant-Id
   - Logging a Supabase
   - Response a Shopify

### 3. DeepCode Integration

📄 `/root/specs/integrations/deepcode-smarteros.md`
   - Architecture completa
   - Environment variables
   - Project structure
   - Nexa Client implementation
   - Chat Interface component
   - Clerk authentication
   - Shopify hooks
   - Analytics dashboard
   - API routes
   - Deployment guide

## 🎯 Cómo Implementar

### Paso 1: Importar Dashboards Metabase

```bash
# 1. Accede a Metabase: https://kpi.smarterbot.cl
# 2. Admin → Settings → Import
# 3. Importa cada dashboard JSON:

curl -X POST https://kpi.smarterbot.cl/api/card/import \
  -H "X-Metabase-Session: <session>" \
  -F "file=@/root/specs/metabase/nexa-runtime-overview.json"

curl -X POST https://kpi.smarterbot.cl/api/card/import \
  -H "X-Metabase-Session: <session>" \
  -F "file=@/root/specs/metabase/shopify-smart-prompts.json"

curl -X POST https://kpi.smarterbot.cl/api/card/import \
  -H "X-Metabase-Session: <session>" \
  -F "file=@/root/specs/metabase/tenant-health-monitor.json"
```

**O manualmente:**
1. Copia el contenido del JSON
2. Metabase → New → Dashboard
3. Add Question → Native Query
4. Pega las queries de cada card

### Paso 2: Importar Workflow Shopify en n8n

```bash
# 1. Accede a n8n: https://n8n.smarterbot.cl
# 2. Workflows → Import from File
# 3. Selecciona: /root/specs/workflows/shopify/dynamic-prompt-engine.json
```

**Configuración adicional:**
1. Configura credencial Supabase (PostgreSQL)
2. Verifica la URL de Nexa Runtime: `https://ai.smarterbot.store`
3. Activa el workflow
4. Copia la webhook URL para configurar en Shopify

### Paso 3: Configurar Webhooks en Shopify

Para cada tienda (ejemplo: fulldaygo.myshopify.com):

```bash
# Shopify Admin → Settings → Notifications → Webhooks

POST https://n8n.smarterbot.cl/webhook/shopify-ai-chat

Events to subscribe:
- orders/create
- customers/create
- carts/update
- products/create
```

### Paso 4: Setup DeepCode en mkt.smarterbot.cl

```bash
# 1. Clone proyecto DeepCode
git clone <deepcode-repo> mkt.smarterbot.cl
cd mkt.smarterbot.cl

# 2. Instala dependencias
npm install

# 3. Configura .env.local
cp .env.example .env.local

# Edita .env.local con:
NEXT_PUBLIC_NEXA_API_URL=https://ai.smarterbot.store/v1
NEXT_PUBLIC_SUPABASE_URL=<supabase_url>
NEXT_PUBLIC_SUPABASE_ANON_KEY=<anon_key>
NEXT_PUBLIC_CLERK_PUBLISHABLE_KEY=<clerk_key>
CLERK_SECRET_KEY=<clerk_secret>

# 4. Copia los archivos de integración
cp /root/specs/integrations/deepcode-smarteros.md ./docs/
# Implementa los componentes según la guía

# 5. Build & deploy
npm run build
vercel --prod
```

## 📊 SQL Schema Updates

Asegúrate de que las tablas en Supabase estén creadas:

```sql
-- Ya deberías tener esta tabla
SELECT * FROM ai_runtime_logs LIMIT 1;

-- Si no existe, créala:
CREATE TABLE IF NOT EXISTS ai_runtime_logs (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  tenant_id TEXT NOT NULL,
  model TEXT NOT NULL,
  endpoint TEXT NOT NULL,
  prompt_tokens INT,
  completion_tokens INT,
  total_tokens INT,
  response_time_ms INT,
  status_code INT,
  error_message TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_ai_logs_tenant ON ai_runtime_logs(tenant_id);
CREATE INDEX IF NOT EXISTS idx_ai_logs_created ON ai_runtime_logs(created_at DESC);

-- Tabla de prompts Shopify
SELECT * FROM shopify_tenant_prompts LIMIT 1;

-- Si no existe:
CREATE TABLE IF NOT EXISTS shopify_tenant_prompts (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  tenant_id TEXT NOT NULL,
  shop_domain TEXT NOT NULL,
  system_prompt TEXT NOT NULL,
  model_config JSONB DEFAULT '{}',
  active BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(tenant_id, shop_domain)
);

CREATE INDEX IF NOT EXISTS idx_shopify_prompts_tenant ON shopify_tenant_prompts(tenant_id);
CREATE INDEX IF NOT EXISTS idx_shopify_prompts_shop ON shopify_tenant_prompts(shop_domain);
```

## 🔗 Architecture Flow

```
┌─────────────────────────────────────────────────────────────┐
│                     USER JOURNEY                            │
└─────────────────────────────────────────────────────────────┘
                          │
                          ▼
┌─────────────────────────────────────────────────────────────┐
│  mkt.smarterbot.cl (DeepCode)                               │
│  - Landing pages                                            │
│  - Dashboard analytics (Metabase embedded iframes)          │
│  - Prompt editor (writes to shopify_tenant_prompts)         │
│  - Chat interface (calls Nexa Runtime)                      │
└─────────────────────────────────────────────────────────────┘
                          │
          ┌───────────────┼───────────────┐
          ▼               ▼               ▼
┌──────────────┐  ┌──────────────┐  ┌──────────────┐
│   Shopify    │  │    Nexa      │  │   Supabase   │
│   Webhook    │  │   Runtime    │  │   (Config)   │
│              │  │              │  │              │
│  → n8n       │  │  /v1/chat/   │  │  Logs        │
│  → Lookup    │  │  completions │  │  Prompts     │
│  → Nexa      │  │              │  │  Metrics     │
└──────────────┘  └──────────────┘  └──────────────┘
                          │
                          ▼
                  ┌──────────────┐
                  │   Metabase   │
                  │  kpi.smarter │
                  │  bot.cl      │
                  │              │
                  │  3 Dashboards│
                  └──────────────┘
```

## ✅ Testing Checklist

### Metabase
- [ ] Dashboard "Nexa Runtime Overview" muestra datos
- [ ] Dashboard "Shopify Smart Prompts" lista tiendas
- [ ] Dashboard "Tenant Health Monitor" funciona con tenant_id=demo
- [ ] Queries ejecutan sin errores
- [ ] RLS funciona (cada tenant ve solo sus datos)

### n8n Shopify Workflow
- [ ] Webhook URL copiada a Shopify
- [ ] Test con evento Shopify funciona
- [ ] Lookup de prompt en Supabase exitoso
- [ ] Call a Nexa Runtime responde correctamente
- [ ] Logs se guardan en ai_runtime_logs

### DeepCode Integration
- [ ] .env.local configurado
- [ ] Nexa client conecta a ai.smarterbot.store
- [ ] Chat interface funciona
- [ ] Clerk authentication OK
- [ ] Prompt editor actualiza Supabase
- [ ] Analytics dashboard muestra métricas
- [ ] Deployed a mkt.smarterbot.cl

## 🔥 Quick Commands

```bash
# Test Nexa Runtime
curl https://ai.smarterbot.store/health

# Test n8n webhook
curl -X POST https://n8n.smarterbot.cl/webhook/shopify-ai-chat \
  -H "Content-Type: application/json" \
  -d '{"shop_domain":"fulldaygo.myshopify.com","event":"test"}'

# Test Metabase query
psql -h <supabase_host> -U postgres -d <db> \
  -c "SELECT COUNT(*) FROM ai_runtime_logs WHERE created_at > NOW() - INTERVAL '24 hours'"

# Deploy DeepCode
cd mkt.smarterbot.cl
npm run build
vercel --prod
```

## 📚 Documentation Links

- **Metabase Dashboards:** `/root/specs/metabase/`
- **n8n Workflows:** `/root/specs/workflows/shopify/`
- **DeepCode Guide:** `/root/specs/integrations/deepcode-smarteros.md`
- **Deployment Checklist:** `/root/DEPLOYMENT-CHECKLIST.md`
- **Production Enhancements:** `/root/PRODUCTION-ENHANCEMENTS.md`

---

**Status:** ✅ Ready for implementation
**Version:** 1.0.0
**Last Updated:** 2025-11-18T20:30:45.123Z

## 🎉 Next Steps

1. Import Metabase dashboards
2. Import n8n workflow
3. Configure Shopify webhooks
4. Setup DeepCode project
5. Test end-to-end flow

**Todo listo para deployment!** 🚀
