# 📊 METABASE — DASHBOARDS OFICIALES SMARTEROS

**Enterprise-Ready KPI Dashboards para SmarterOS**

Este documento define los dashboards estándar del sistema, sus métricas, SQL, filtros y embeddables.

---

## 1. Dashboard Ejecutivo (Global)

**Propósito:**  
Vista de 360° del sistema: ventas, soporte, IA, automatizaciones, tenants activos.

### Métricas principales
- Ventas últimos 30 días
- Conversión Shopify/Odoo
- Conversaciones Chatwoot
- Respuestas IA/handoffs
- Workflows n8n ejecutados
- Tenants activos por RUT

### SQL — Ventas Totales
```sql
SELECT
    date_trunc('day', order_date) as day,
    sum(total_amount) as revenue
FROM odoo_orders
GROUP BY 1
ORDER BY 1 DESC
LIMIT 30;
```

### SQL — Conversaciones Chatwoot
```sql
SELECT
    date_trunc('day', created_at) as day,
    count(*) as conversations
FROM chatwoot_conversations
GROUP BY 1
ORDER BY 1 DESC;
```

---

## 2. Dashboard por Tenant (RUT-centric BI)

**Propósito:**  
Vista única e hiper-personalizada para cada empresa (RUT).

### Filtros
- 🧾 `tenant_id` / `rut`
- 📅 Fecha inicio/fin
- 🏷️ Tipo de métrica (ventas, soporte, IA, workflows)

### SQL — Ventas por RUT
```sql
SELECT
    tenant_id,
    rut,
    customer,
    total_amount,
    order_date
FROM odoo_orders
WHERE tenant_id = {{tenant_id}}
ORDER BY order_date DESC;
```

### SQL — Conversaciones por RUT
```sql
SELECT
    date_trunc('day', created_at) as day,
    count(*) as conversations,
    avg(response_time_seconds) as avg_response_time
FROM chatwoot_conversations
WHERE tenant_id = {{tenant_id}}
GROUP BY 1
ORDER BY 1 DESC;
```

---

## 3. Dashboard Ventas (Shopify + Odoo)

**Propósito:**  
Vista unificada de eCommerce.

### SQL — Productos más vendidos
```sql
SELECT
    product_name,
    sum(quantity) as qty,
    sum(total_amount) as revenue
FROM odoo_order_lines
GROUP BY 1
ORDER BY revenue DESC
LIMIT 10;
```

### SQL — Embudo de Conversión
```sql
SELECT
    step,
    count(*)
FROM analytics_conversion_funnel
GROUP BY step
ORDER BY step ASC;
```

### SQL — Revenue por canal
```sql
SELECT
    source_channel,
    sum(total_amount) as revenue
FROM orders
WHERE order_date >= current_date - interval '30 days'
GROUP BY 1
ORDER BY 2 DESC;
```

---

## 4. Dashboard Soporte (Chatwoot + AI)

**Propósito:**  
Medir soporte omnicanal + AI handoffs.

### SQL — Tiempo promedio de respuesta
```sql
SELECT
    avg(response_time_seconds) as avg_response
FROM chatwoot_messages
WHERE incoming = true;
```

### SQL — Handoffs AI → Humano
```sql
SELECT
    date_trunc('day', created_at) as day,
    count(*) as handoffs
FROM ai_handoff_events
GROUP BY 1
ORDER BY 1 DESC;
```

### SQL — Conversaciones por canal
```sql
SELECT
    channel_type,
    count(*) as conversations
FROM chatwoot_conversations
WHERE created_at >= current_date - interval '30 days'
GROUP BY 1
ORDER BY 2 DESC;
```

---

## 5. Dashboard Automatizaciones (n8n)

**Propósito:**  
Medir ejecución y fallos de flujos.

### SQL — Fallos por workflow
```sql
SELECT
    workflow_name,
    count(*) as failures
FROM n8n_executions
WHERE status = 'error'
GROUP BY 1
ORDER BY failures DESC;
```

### SQL — Workflows más usados
```sql
SELECT
    workflow_name,
    count(*) as executions,
    avg(execution_time_ms) as avg_time
FROM n8n_executions
WHERE created_at >= current_date - interval '30 days'
GROUP BY 1
ORDER BY 2 DESC;
```

---

## 6. Dashboard AI Performance

**Propósito:**  
Medir efectividad de agentes IA.

### SQL — Tasa de resolución AI
```sql
SELECT
    date_trunc('day', created_at) as day,
    count(*) filter (where resolved_by_ai = true) * 100.0 / count(*) as ai_resolution_rate
FROM conversations
GROUP BY 1
ORDER BY 1 DESC;
```

### SQL — Confianza promedio LLM
```sql
SELECT
    avg(confidence_score) as avg_confidence,
    count(*) as total_responses
FROM ai_responses
WHERE created_at >= current_date - interval '7 days';
```

---

## Embedding en Portal Maestro

Use este endpoint Metabase:

```bash
POST /api/embed/dashboard/{dashboard_id}
```

Ejemplo:
```bash
curl -X POST https://kpi.smarterbot.cl/api/embed/dashboard/1 \
    -H "Content-Type: application/json" \
    -H "X-Metabase-Session: YOUR_SESSION" \
    -d '{
        "params": {"tenant_id": "demo"},
        "expires": 3600
    }'
```

En Next.js:
```tsx
<iframe
  src={`https://kpi.smarterbot.cl/embed/dashboard/${token}#theme=night`}
  width="100%"
  height="900"
  frameBorder="0"
  allowTransparency
/>
```

---

## Alertas con n8n

**Webhook:**
```
https://n8n.smarterbot.store/webhook/kpi-alerts
```

**Eventos recomendados:**
- Revenue < X
- Conversaciones > X
- Workflows con errores
- Ventas por RUT caen 20%
- Tiempo respuesta > 2min

---

## 🎯 Métricas por Dashboard

| Dashboard | Métricas | Actualización |
|-----------|----------|---------------|
| Ejecutivo | 8 KPIs | Tiempo real |
| Tenant | 12 KPIs | Cada 5 min |
| Ventas | 10 KPIs | Cada 15 min |
| Soporte | 8 KPIs | Tiempo real |
| Automatizaciones | 6 KPIs | Cada hora |
| AI Performance | 5 KPIs | Cada 30 min |

---

## 📞 Contacto

Email: smarterbotcl@gmail.com  
WhatsApp: +56 9 7954 0471  
Web: https://smarterbot.cl

🟢 **SmarterOS — KPI Enterprise para PYMEs Chile**
