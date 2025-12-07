# 📊 SmarterOS — Metabase Analytics & KPI Dashboard

**Business Intelligence platform para SmarterOS Multi-Tenant Operating System**

Metabase es el motor de analytics y dashboards del ecosistema SmarterOS, proporcionando insights en tiempo real para cada tenant (empresa con RUT chileno).

---

## 🎯 Propósito

Centralizar **KPIs, métricas y reportes** de todos los módulos de SmarterOS:

- 📈 **Ventas** (Odoo + Shopify)
- 💬 **Soporte** (Chatwoot + WhatsApp)
- 🤖 **Automatizaciones** (n8n + Botpress)
- 👥 **Usuarios y Tenants** (Supabase + Clerk)
- 📦 **Inventario** (Odoo ERP)
- 🛒 **E-commerce** (Shopify + carritos)

---

## 🚀 Acceso

**URL Producción:** [https://kpi.smarterbot.cl](https://kpi.smarterbot.cl)

**Credenciales Admin:**
- Email: `smarterbotcl@gmail.com`
- Password: Ver Vault `/secret/metabase/prod`

---

## 🏗️ Arquitectura


Portal (app.smarterbot.cl)
         │
         │ Embedded Dashboards
         ▼
    Metabase KPI
   (kpi.smarterbot.cl)
         │
         │ SQL Queries
         ▼
     Supabase DB ← RLS por Tenant
         │
         ├─ Tenants
         ├─ Users
         ├─ Orders (Odoo)
         ├─ Conversations (Chatwoot)
         └─ Workflows (n8n)


---

## 📊 Dashboards Principales

### 1. **Vista Ejecutiva**
- Total de tenants activos
- Usuarios registrados
- Ventas consolidadas (último mes)
- Tickets de soporte abiertos
- Workflows ejecutados

### 2. **Dashboard por Tenant (RUT)**
Cada empresa ve **solo sus datos**:
- Ventas del período
- Productos más vendidos
- Tickets resueltos vs pendientes
- Automatizaciones activas
- Conversaciones WhatsApp
- Tiempo promedio de respuesta

### 3. **Dashboard de Ventas**
- Revenue por tenant
- Productos top
- Clientes recurrentes
- Carritos abandonados (Shopify)
- Sync Shopify ↔ Odoo

### 4. **Dashboard de Soporte**
- Tickets por canal (WhatsApp, Email, Web)
- SLA compliance
- CSAT (satisfacción del cliente)
- Handoffs AI → Humano
- Agentes más activos

### 5. **Dashboard de Automatizaciones**
- Workflows por tenant
- Tasa de éxito/fallo
- Latencia promedio
- Errores por categoría
- OCR procesados

---

## 🔐 Seguridad Multi-Tenant

### Row-Level Security (RLS)

Todas las queries incluyen filtro automático por `tenant_id`:

```sql
SELECT *
FROM orders
WHERE tenant_id = {{current_tenant_id}}
  AND created_at >= NOW() - INTERVAL '30 days';
```

### Embedding Seguro

Los dashboards embebidos en `app.smarterbot.cl` usan **signed JWT** con:
- `tenant_id` del usuario
- `rut` de la empresa
- Fecha de expiración

```javascript
// Ejemplo de embedding
const embedUrl = await fetch('/api/metabase/embed/dashboard/5', {
  headers: { Authorization: `Bearer ${userToken}` }
})
```

---

## 🔌 Integración con API Gateway

### Endpoints Metabase en `api.smarterbot.cl`

```bash
# Obtener URL de dashboard embebido
GET /api/metabase/embed/{dashboard_id}
Authorization: Bearer {clerk_jwt}

# Crear dashboard para nuevo tenant
POST /api/metabase/dashboards
{
  "tenant_id": "76953480-3",
  "template": "tenant_overview"
}

# Ejecutar query manual
POST /api/metabase/query
{
  "tenant_id": "76953480-3",
  "sql": "SELECT COUNT(*) FROM orders WHERE status = 'completed'"
}
```

---

## 📡 Conexión a Supabase

**Database:** PostgreSQL  
**Host:** `aws-0-us-east-1.pooler.supabase.com`  
**Port:** `6543`  
**SSL:** Required

**Schemas habilitados:**
- `public` → datos de aplicación
- `auth` → usuarios Clerk/Supabase
- `storage` → archivos

**Connection string:**
```
postgresql://postgres.rjfcmmzjlguiititkmyh:***@aws-0-us-east-1.pooler.supabase.com:6543/postgres?sslmode=require
```

---

## 📢 Alertas y Notificaciones

Metabase se integra con **n8n** para enviar alertas:

### Ejemplos de Alertas

| Condición | Acción |
|-----------|--------|
| Ventas < $10K/día | Email + WhatsApp a admin |
| Tickets sin responder > 2h | Notificación Slack |
| Workflow con error rate > 10% | Ticket automático Chatwoot |
| Inventario < 5 unidades | Email a compras |

**Workflow n8n:**
```
Metabase Alert → Webhook → n8n → Clasificar → Enviar:
  - WhatsApp (cliente)
  - Email (equipo)
  - Slack (DevOps)
  - Chatwoot (ticket)
```

---

## 🛠️ Stack Técnico

- **Metabase:** v0.57+
- **Database:** PostgreSQL 16 (Supabase)
- **Deployment:** Dokploy + Docker
- **SSL:** Caddy Reverse Proxy
- **Auth:** Metabase nativo + futuro SSO con Clerk

---

## 🔄 Sincronización de Datos

Metabase sincroniza con Supabase cada:
- **1 hora:** Metadata de tablas
- **24 horas:** Fingerprinting de columnas

Para forzar sync manual:
```bash
# Via Metabase UI
Settings → Admin → Databases → SmarterDB → Sync database schema now
```

---

## 📝 Queries SQL Comunes

### Total Ventas por Tenant
```sql
SELECT 
  t.rut,
  t.company_name,
  SUM(o.amount_total) as total_sales,
  COUNT(o.id) as total_orders
FROM tenants t
LEFT JOIN orders o ON o.tenant_id = t.id
WHERE o.created_at >= NOW() - INTERVAL '30 days'
GROUP BY t.rut, t.company_name
ORDER BY total_sales DESC;
```

### Tickets por Canal
```sql
SELECT 
  channel,
  status,
  COUNT(*) as total
FROM conversations
WHERE tenant_id = {{tenant_id}}
  AND created_at >= NOW() - INTERVAL '7 days'
GROUP BY channel, status;
```

### Workflows más Usados
```sql
SELECT 
  workflow_name,
  COUNT(*) as executions,
  AVG(duration_ms) as avg_duration,
  SUM(CASE WHEN status = 'error' THEN 1 ELSE 0 END) as errors
FROM workflow_executions
WHERE tenant_id = {{tenant_id}}
  AND created_at >= NOW() - INTERVAL '30 days'
GROUP BY workflow_name
ORDER BY executions DESC
LIMIT 10;
```

---

## 🚀 Roadmap

### ✅ Fase 1 (Completado)
- Instalación y configuración
- Conexión a Supabase
- Dashboards básicos

### 🔄 Fase 2 (En progreso)
- Dashboards por tenant
- Embedding en Portal
- Alertas con n8n

### ⏳ Fase 3 (Próximo)
- SSO con Clerk
- Reportes PDF automáticos
- Predicciones con ML

### 🔮 Fase 4 (Futuro)
- Análisis de sentimiento (tickets)
- Dashboards dinámicos por industria
- Marketplace de dashboards

---

## 📞 Soporte

**Email:** smarterbotcl@gmail.com  
**WhatsApp:** +56 9 7954 0471  
**Docs:** [github.com/SmarterCL/smarteros-specs](https://github.com/SmarterCL/smarteros-specs)

---

## 🔗 Enlaces Relacionados

- [Portal SmarterOS](https://app.smarterbot.cl)
- [API Gateway](https://api.smarterbot.cl)
- [Odoo ERP](https://erp.smarterbot.cl)
- [Chatwoot CRM](https://crm.smarterbot.cl)
- [n8n Automatizaciones](https://n8n.smarterbot.store)

---

**🟢 SmarterOS — Business Intelligence para PYMEs Chile**

Datos en tiempo real, decisiones inteligentes.
