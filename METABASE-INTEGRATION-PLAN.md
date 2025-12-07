# 🎯 METABASE INTEGRATION PLAN — SmarterOS

**Fecha:** 2025-11-23  
**Estado:** ✅ Metabase UP | 🔄 Configuración en progreso  
**URL:** https://kpi.smarterbot.cl

---

## 📋 FASE 1: Configuración Base (COMPLETADO ✅)

### 1.1 Infraestructura
- ✅ Metabase desplegado en Dokploy
- ✅ SSL configurado (kpi.smarterbot.cl)
- ✅ Base de datos PostgreSQL conectada
- ✅ Credenciales guardadas en Vault

### 1.2 Conexión Supabase
```json
{
  "engine": "postgres",
  "name": "SmarterDB",
  "details": {
    "host": "aws-0-us-east-1.pooler.supabase.com",
    "port": 6543,
    "dbname": "postgres",
    "user": "postgres.rjfcmmzjlguiititkmyh",
    "password": "RctbsgNqeUeEIO9e",
    "ssl": true,
    "ssl-mode": "require",
    "additional-options": "sslmode=require&prepareThreshold=0"
  }
}
```

### 1.3 Usuario Administrador
- Email: smarterbotcl@gmail.com
- Password: Chevrolet2025+
- Rol: Admin

---

## 📊 FASE 2: Dashboards Multi-Tenant (EN PROGRESO 🔄)

### 2.1 Dashboard: Vista General SmarterOS
**Objetivo:** Overview ejecutivo de toda la plataforma

**Métricas principales:**
- Total tenants activos
- Usuarios totales por tenant
- Conversaciones Chatwoot (últimos 30 días)
- Órdenes Odoo (últimos 30 días)
- Workflows n8n ejecutados
- Mensajes IA procesados

**Queries necesarias:**
```sql
-- Total Tenants
SELECT COUNT(*) as total_tenants FROM tenants WHERE status = 'active';

-- Usuarios por Tenant
SELECT t.company_name, COUNT(u.id) as total_users
FROM tenants t
LEFT JOIN users u ON u.tenant_id = t.id
GROUP BY t.company_name
ORDER BY total_users DESC;

-- Conversaciones por Tenant (si integrado)
SELECT tenant_id, COUNT(*) as conversations
FROM chatwoot_conversations
WHERE created_at >= NOW() - INTERVAL '30 days'
GROUP BY tenant_id;
```

### 2.2 Dashboard: Tenant Individual
**Objetivo:** Vista dedicada para cada empresa (RUT)

**Filtros:**
- Selector de Tenant (RUT)
- Rango de fechas

**Métricas por tenant:**
- Usuarios activos
- Conversaciones WhatsApp/Email
- Ventas Odoo (últimos 30/90 días)
- Productos más vendidos
- Estado de inventario
- Workflows automatizados
- Tasa de respuesta AI vs Humano
- Tiempo promedio de respuesta

**Query ejemplo:**
```sql
-- Dashboard Tenant Específico
SELECT 
  t.rut,
  t.company_name,
  COUNT(DISTINCT u.id) as usuarios,
  COUNT(DISTINCT o.id) as ordenes,
  SUM(o.amount_total) as ventas_total
FROM tenants t
LEFT JOIN users u ON u.tenant_id = t.id
LEFT JOIN orders o ON o.tenant_id = t.id
WHERE t.rut = '76953480-3'
  AND o.created_at >= NOW() - INTERVAL '30 days'
GROUP BY t.rut, t.company_name;
```

### 2.3 Dashboard: Ventas y E-commerce
**Métricas:**
- Ventas diarias/semanales/mensuales
- Productos top
- Clientes recurrentes
- Carritos abandonados (Shopify)
- Conversión Shopify → Odoo
- Revenue por tenant

### 2.4 Dashboard: Soporte y CRM
**Métricas:**
- Tickets abiertos vs cerrados
- Tiempo promedio de resolución
- Satisfacción del cliente (CSAT)
- Handoffs AI → Humano
- Volumen por canal (WhatsApp, Email, Web)

### 2.5 Dashboard: Automatizaciones
**Métricas:**
- Workflows ejecutados
- Tasa de éxito/fallo
- Workflows más usados
- Tiempo promedio de ejecución
- Errores por workflow

---

## 🔐 FASE 3: Embedding en Portal (PRÓXIMO)

### 3.1 Configuración de Embedding
**En Metabase:**
1. Habilitar embedding en Settings → Embedding
2. Generar `METABASE_SECRET_KEY`
3. Configurar dominios permitidos: `app.smarterbot.cl`

**Variables de entorno (Vercel):**
```bash
NEXT_PUBLIC_METABASE_SITE_URL=https://kpi.smarterbot.cl
METABASE_SECRET_KEY=<secret_key>
```

### 3.2 Embedding por Tenant
**Flujo:**
1. Usuario entra a `app.smarterbot.cl/dashboard`
2. Backend genera signed JWT con `tenant_id`
3. Frontend renderiza iframe de Metabase con token
4. Metabase filtra automáticamente por tenant

**Implementación en API Gateway:**
```python
# /api/metabase/embed
from metabase import generate_embed_url

@router.get("/metabase/embed/{dashboard_id}")
async def get_embed_url(
    dashboard_id: int,
    user: User = Depends(get_current_user)
):
    params = {
        "tenant_id": user.tenant_id,
        "rut": user.tenant.rut
    }
    
    url = generate_embed_url(
        dashboard_id=dashboard_id,
        params=params,
        secret_key=settings.METABASE_SECRET_KEY
    )
    
    return {"embed_url": url}
```

### 3.3 Componente React
```typescript
// components/MetabaseDashboard.tsx
import { useEffect, useState } from 'react'

export default function MetabaseDashboard({ dashboardId }) {
  const [embedUrl, setEmbedUrl] = useState('')
  
  useEffect(() => {
    fetch(`/api/metabase/embed/${dashboardId}`)
      .then(res => res.json())
      .then(data => setEmbedUrl(data.embed_url))
  }, [dashboardId])
  
  return (
    <iframe
      src={embedUrl}
      frameBorder="0"
      width="100%"
      height="600"
      allowTransparency
    />
  )
}
```

---

## 📢 FASE 4: Alertas y Notificaciones

### 4.1 Alertas en Metabase
**Configuraciones:**
- Ventas diarias < objetivo → Email + WhatsApp
- Tickets sin responder > 2h → Slack/Email
- Workflows con > 10% error rate → Alerta inmediata
- Inventario bajo → Notificación Odoo + Email

### 4.2 Integración con n8n
**Workflow n8n:**
```
Metabase Alert → Webhook n8n → Clasificar → Enviar:
  - WhatsApp (cliente)
  - Email (admin)
  - Slack (equipo)
  - Chatwoot (ticket)
```

---

## 🗂️ FASE 5: Colecciones y Permisos

### 5.1 Estructura de Colecciones
```
📁 SmarterOS (Root)
├── 📊 Dashboards Generales
│   ├── Vista Ejecutiva
│   ├── Ventas Consolidadas
│   └── Soporte General
├── 🏢 Tenants
│   ├── 📁 76953480-3 (Ferretería Juanito)
│   ├── 📁 77123456-K (Distribuidora XYZ)
│   └── ...
└── 🔧 Admin
    ├── Performance
    └── Logs
```

### 5.2 Permisos
**Roles en Metabase:**
- **Admin:** Acceso total
- **Tenant Owner:** Solo su colección
- **Tenant User:** Solo dashboards de su tenant (read-only)

**Implementación RLS:**
```sql
-- Row Level Security en todas las queries
WHERE tenant_id = {{current_tenant_id}}
```

---

## 🚀 ROADMAP

### Inmediato (Esta semana)
- ✅ Conectar Supabase a Metabase
- 🔄 Crear Dashboard "Vista General"
- 🔄 Crear Dashboard "Tenant Individual"
- ⏳ Configurar embedding

### Corto plazo (2 semanas)
- Dashboard Ventas
- Dashboard Soporte
- Dashboard Automatizaciones
- Alertas básicas

### Mediano plazo (1 mes)
- Embedding completo en Portal
- Permisos por tenant
- Alertas avanzadas con n8n
- Reportes PDF automáticos

### Largo plazo (3 meses)
- Predicciones con ML
- Análisis de sentimiento en tickets
- Dashboards dinámicos por industria
- Marketplace de dashboards

---

## 📝 CREDENCIALES (Guardadas en Vault)

**Path:** `/secret/metabase/prod`

```json
{
  "url": "https://kpi.smarterbot.cl",
  "admin_email": "smarterbotcl@gmail.com",
  "admin_password": "Chevrolet2025+",
  "db_connection": {
    "host": "aws-0-us-east-1.pooler.supabase.com",
    "port": 6543,
    "database": "postgres",
    "user": "postgres.rjfcmmzjlguiititkmyh",
    "password": "RctbsgNqeUeEIO9e"
  },
  "secret_key": "<to_be_generated>"
}
```

---

## 🔗 RECURSOS

- Metabase API: https://www.metabase.com/docs/latest/api
- Embedding Guide: https://www.metabase.com/docs/latest/embedding/introduction
- Supabase + Metabase: https://supabase.com/docs/guides/database/metabase

---

**✅ PRÓXIMOS PASOS:**
1. Crear primer dashboard en Metabase UI
2. Configurar embedding token
3. Integrar en `app.smarterbot.cl`
4. Documentar queries SQL por tenant
5. Setup alertas con n8n

---

**Contacto:** smarterbotcl@gmail.com  
**Docs:** https://github.com/SmarterCL/smarteros-specs
