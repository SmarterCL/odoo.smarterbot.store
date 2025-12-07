# 🎯 Tenant DEMO - Setup Completo
**Fecha:** 2025-11-19 15:15 UTC  
**Status:** En progreso

---

## ✅ COMPLETADO

### 1. Estructura Tenant
```yaml
ID: tenant_demo_001
RUT: 00000000-0
Nombre: Demo SmarterOS
Slug: demo
Domain: demo.smarterbot.cl
Plan: professional
```

### 2. Servicios Activos
- ✅ **Odoo** - https://odoo.smarterbot.cl (28h uptime)
- ✅ **Chatwoot** - https://chatwoot.smarterbot.cl (23h uptime)
- ✅ **n8n** - Activo (28h uptime, health OK)
- ✅ **Metabase** - https://kpi.smarterbot.store (21h uptime)

### 3. Archivos Creados
- ✅ `tenants/demo.yml` - Configuración completa tenant
- ✅ `tenants/registry.yml` - Registry actualizado (1 tenant activo)
- ✅ `workflows/tenants/demo/README.md` - Documentación workflows
- ✅ `workflows/base/shopify-order-webhook.json` - Template base

### 4. Workflow Template: Shopify → Odoo → Chatwoot
**Flow:** Orden Shopify → Parse → Sale Order Odoo → Notificación Chatwoot

**Nodos:**
1. Webhook Shopify (trigger)
2. Parse Order Data (transform)
3. Create Sale Order Odoo (POST /api/v1/sale.order)
4. Notify Chatwoot (POST /api/v1/conversations)

---

## 🔴 PENDIENTE (Siguiente fase)

### 5. Shopify Store
- [ ] Crear cuenta Shopify: `demo-smarter.myshopify.com`
- [ ] Instalar app custom o usar API
- [ ] Configurar webhooks → n8n
- [ ] Productos demo (mínimo 3)
- [ ] Configurar checkout

### 6. Credenciales Vault
**Path:** `secret/tenant/tenant_demo_001/`

Requeridas:
```bash
shopify/admin_token
shopify/store_domain
odoo/api_key
odoo/database
chatwoot/api_token
chatwoot/account_id
n8n/webhook_token
```

### 7. n8n Workflow Deploy
- [ ] Importar `shopify-order-webhook.json` a n8n
- [ ] Configurar env vars:
  - `TENANT_ID=tenant_demo_001`
  - `TENANT_RUT=00000000-0`
- [ ] Activar webhook
- [ ] URL webhook: `https://n8n.smarterbot.cl/webhook/shopify/order-created`

### 8. Test End-to-End
**Escenario:**
1. Cliente crea orden en Shopify
2. Webhook dispara n8n
3. Sale order se crea en Odoo
4. Conversación se abre en Chatwoot
5. Verificar en Metabase KPI

**Validaciones:**
- [ ] Latencia < 5s
- [ ] Orden sincronizada en Odoo
- [ ] Mensaje en Chatwoot con datos correctos
- [ ] Log en Metabase

### 9. Landing Page (mkt.smarterbot.store)
- [ ] Deploy landing minimalista
- [ ] Sección: "Automatiza tu tienda con SmarterOS"
- [ ] Form captura: email → n8n → Chatwoot
- [ ] CTA: "Prueba 14 días gratis"

### 10. KPI Dashboard (Metabase)
**Dashboard:** "Tenant Demo - Overview"

Widgets:
- [ ] Ventas hoy (Shopify)
- [ ] Órdenes pendientes (Odoo)
- [ ] Conversaciones activas (Chatwoot)
- [ ] Workflows ejecutados (n8n)
- [ ] Latencia promedio

---

## 🎯 META FINAL

**Sistema funcional completo:**
```
Cliente compra en Shopify
  ↓
n8n procesa webhook
  ↓
Sale order en Odoo
  ↓
Notificación Chatwoot
  ↓
KPI en Metabase
  ↓
✅ Comercio 100% automático
```

**Timeline estimado:**
- Shopify setup: 30 min
- Vault config: 15 min
- n8n deploy: 20 min
- Test E2E: 15 min
- Landing: 1h
- Dashboard: 30 min

**Total:** ~3 horas para tenant DEMO operativo.

---

## 📊 Servicios Health Check

```bash
# Verificar todos los servicios
docker ps --filter name=smarter --format "{{.Names}}: {{.Status}}"

# Health checks
curl https://n8n.smarterbot.cl/health
curl https://odoo.smarterbot.cl/web/health
curl https://chatwoot.smarterbot.cl/api/health
curl https://kpi.smarterbot.store/api/health
```

---

## 🚀 Next Actions

**Inmediato:**
1. Crear cuenta Shopify trial
2. Configurar credenciales Vault
3. Importar workflow a n8n
4. Test primera venta

**Corto plazo:**
1. Landing mkt.smarterbot.store
2. Dashboard Metabase personalizado
3. Documentar flujo completo
4. Preparar demo para cliente real

---

**Creado por:** SmarterOS Team  
**Versión:** 0.3.1-integration  
**Commit:** d3f8ad1
