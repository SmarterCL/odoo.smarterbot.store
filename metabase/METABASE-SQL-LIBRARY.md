# 📊 METABASE SQL LIBRARY

**30+ Production-Ready SQL Queries para SmarterOS KPIs**

---

## 1. Ventas y Revenue

### Total Revenue (últimos 30 días)
```sql
SELECT 
    sum(total_amount) as total_revenue
FROM odoo_orders
WHERE order_date >= current_date - interval '30 days';
```

### Revenue por día
```sql
SELECT 
    date_trunc('day', order_date) as day,
    sum(total_amount) as revenue,
    count(*) as orders
FROM odoo_orders
WHERE order_date >= current_date - interval '30 days'
GROUP BY 1
ORDER BY 1 DESC;
```

### Revenue por tenant
```sql
SELECT 
    tenant_id,
    rut,
    sum(total_amount) as revenue,
    count(*) as orders
FROM odoo_orders
WHERE order_date >= current_date - interval '30 days'
GROUP BY 1, 2
ORDER BY 3 DESC;
```

### Top 10 productos vendidos
```sql
SELECT 
    product_name,
    sum(quantity) as qty_sold,
    sum(total_amount) as revenue
FROM odoo_order_lines
WHERE created_at >= current_date - interval '30 days'
GROUP BY 1
ORDER BY 3 DESC
LIMIT 10;
```

### Comparación mes actual vs anterior
```sql
SELECT 
    'Current Month' as period,
    sum(total_amount) as revenue
FROM odoo_orders
WHERE order_date >= date_trunc('month', current_date)

UNION ALL

SELECT 
    'Previous Month' as period,
    sum(total_amount) as revenue
FROM odoo_orders
WHERE order_date >= date_trunc('month', current_date - interval '1 month')
  AND order_date < date_trunc('month', current_date);
```

---

## 2. Soporte y CRM (Chatwoot)

### Conversaciones por día
```sql
SELECT 
    date_trunc('day', created_at) as day,
    count(*) as conversations
FROM chatwoot_conversations
WHERE created_at >= current_date - interval '30 days'
GROUP BY 1
ORDER BY 1 DESC;
```

### Tiempo promedio de respuesta
```sql
SELECT 
    avg(response_time_seconds) as avg_response_seconds,
    min(response_time_seconds) as min_response,
    max(response_time_seconds) as max_response
FROM chatwoot_messages
WHERE incoming = true
  AND created_at >= current_date - interval '7 days';
```

### Conversaciones por canal
```sql
SELECT 
    channel_type,
    count(*) as conversations,
    round(count(*) * 100.0 / sum(count(*)) over (), 2) as percentage
FROM chatwoot_conversations
WHERE created_at >= current_date - interval '30 days'
GROUP BY 1
ORDER BY 2 DESC;
```

### Agentes más activos
```sql
SELECT 
    agent_name,
    count(*) as messages_sent,
    avg(response_time_seconds) as avg_response_time
FROM chatwoot_messages
WHERE incoming = false
  AND created_at >= current_date - interval '30 days'
GROUP BY 1
ORDER BY 2 DESC
LIMIT 10;
```

### Conversaciones sin resolver
```sql
SELECT 
    count(*) as unresolved,
    avg(extract(epoch from (current_timestamp - created_at))/3600) as avg_hours_open
FROM chatwoot_conversations
WHERE status != 'resolved';
```

---

## 3. AI Performance

### Tasa de resolución AI
```sql
SELECT 
    date_trunc('day', created_at) as day,
    count(*) filter (where resolved_by_ai = true) * 100.0 / count(*) as ai_resolution_rate,
    count(*) as total_conversations
FROM conversations
WHERE created_at >= current_date - interval '30 days'
GROUP BY 1
ORDER BY 1 DESC;
```

### Handoffs AI → Humano
```sql
SELECT 
    date_trunc('hour', created_at) as hour,
    count(*) as handoffs,
    avg(confidence_before_handoff) as avg_confidence
FROM ai_handoff_events
WHERE created_at >= current_date - interval '7 days'
GROUP BY 1
ORDER BY 1 DESC;
```

### Confianza promedio LLM
```sql
SELECT 
    model_name,
    avg(confidence_score) as avg_confidence,
    count(*) as total_responses
FROM ai_responses
WHERE created_at >= current_date - interval '7 days'
GROUP BY 1
ORDER BY 2 DESC;
```

### Temas más consultados (RAG)
```sql
SELECT 
    topic,
    count(*) as queries,
    avg(confidence_score) as avg_confidence
FROM ai_rag_queries
WHERE created_at >= current_date - interval '30 days'
GROUP BY 1
ORDER BY 2 DESC
LIMIT 10;
```

---

## 4. Automatizaciones (n8n)

### Workflows más ejecutados
```sql
SELECT 
    workflow_name,
    count(*) as executions,
    count(*) filter (where status = 'success') as successful,
    count(*) filter (where status = 'error') as failed,
    avg(execution_time_ms) as avg_time_ms
FROM n8n_executions
WHERE created_at >= current_date - interval '30 days'
GROUP BY 1
ORDER BY 2 DESC;
```

### Fallos por workflow
```sql
SELECT 
    workflow_name,
    error_message,
    count(*) as occurrences
FROM n8n_executions
WHERE status = 'error'
  AND created_at >= current_date - interval '7 days'
GROUP BY 1, 2
ORDER BY 3 DESC
LIMIT 20;
```

### Ejecuciones por hora del día
```sql
SELECT 
    extract(hour from created_at) as hour,
    count(*) as executions
FROM n8n_executions
WHERE created_at >= current_date - interval '7 days'
GROUP BY 1
ORDER BY 1;
```

### Workflows más lentos
```sql
SELECT 
    workflow_name,
    avg(execution_time_ms) as avg_time_ms,
    max(execution_time_ms) as max_time_ms,
    count(*) as executions
FROM n8n_executions
WHERE created_at >= current_date - interval '30 days'
GROUP BY 1
ORDER BY 2 DESC
LIMIT 10;
```

---

## 5. Multi-Tenant Analytics

### Actividad por tenant
```sql
SELECT 
    t.tenant_id,
    t.rut,
    t.company_name,
    count(o.id) as orders,
    count(c.id) as conversations,
    count(w.id) as workflows
FROM tenants t
LEFT JOIN odoo_orders o ON t.tenant_id = o.tenant_id 
    AND o.order_date >= current_date - interval '30 days'
LEFT JOIN chatwoot_conversations c ON t.tenant_id = c.tenant_id 
    AND c.created_at >= current_date - interval '30 days'
LEFT JOIN n8n_executions w ON t.tenant_id = w.tenant_id 
    AND w.created_at >= current_date - interval '30 days'
GROUP BY 1, 2, 3
ORDER BY 4 DESC;
```

### Tenants más activos
```sql
SELECT 
    tenant_id,
    rut,
    count(*) as total_actions
FROM (
    SELECT tenant_id, rut FROM odoo_orders WHERE order_date >= current_date - interval '30 days'
    UNION ALL
    SELECT tenant_id, rut FROM chatwoot_conversations WHERE created_at >= current_date - interval '30 days'
    UNION ALL
    SELECT tenant_id, rut FROM n8n_executions WHERE created_at >= current_date - interval '30 days'
) as all_actions
GROUP BY 1, 2
ORDER BY 3 DESC
LIMIT 10;
```

### Revenue per tenant (ranking)
```sql
SELECT 
    rank() over (order by sum(total_amount) desc) as ranking,
    tenant_id,
    rut,
    sum(total_amount) as revenue,
    count(*) as orders,
    avg(total_amount) as avg_order_value
FROM odoo_orders
WHERE order_date >= current_date - interval '30 days'
GROUP BY 2, 3
ORDER BY 1;
```

---

## 6. Embudo de Conversión

### E-commerce funnel
```sql
SELECT 
    step,
    count(*) as users,
    round(count(*) * 100.0 / first_value(count(*)) over (order by step), 2) as conversion_rate
FROM (
    SELECT 1 as step, user_id FROM page_views WHERE page = 'product'
    UNION ALL
    SELECT 2 as step, user_id FROM cart_additions
    UNION ALL
    SELECT 3 as step, user_id FROM checkout_started
    UNION ALL
    SELECT 4 as step, user_id FROM orders_completed
) funnel
GROUP BY step
ORDER BY step;
```

---

## 7. KPIs Globales

### Dashboard ejecutivo (single query)
```sql
SELECT 
    (SELECT sum(total_amount) FROM odoo_orders WHERE order_date >= current_date - interval '30 days') as revenue_30d,
    (SELECT count(*) FROM odoo_orders WHERE order_date >= current_date - interval '30 days') as orders_30d,
    (SELECT count(*) FROM chatwoot_conversations WHERE created_at >= current_date - interval '30 days') as conversations_30d,
    (SELECT count(*) FROM n8n_executions WHERE created_at >= current_date - interval '30 days') as workflows_30d,
    (SELECT count(*) FROM tenants WHERE status = 'active') as active_tenants,
    (SELECT count(*) filter (where resolved_by_ai = true) * 100.0 / count(*) FROM conversations WHERE created_at >= current_date - interval '30 days') as ai_resolution_rate;
```

---

## 8. Parametrized Queries (con filtros)

### Ventas por tenant con filtro de fecha
```sql
SELECT 
    date_trunc('day', order_date) as day,
    sum(total_amount) as revenue,
    count(*) as orders
FROM odoo_orders
WHERE tenant_id = {{tenant_id}}
  AND order_date >= {{start_date}}
  AND order_date <= {{end_date}}
GROUP BY 1
ORDER BY 1 DESC;
```

### Conversaciones por agente y canal
```sql
SELECT 
    agent_name,
    channel_type,
    count(*) as conversations,
    avg(response_time_seconds) as avg_response
FROM chatwoot_conversations
WHERE agent_id = {{agent_id}}
  AND created_at >= {{start_date}}
  AND created_at <= {{end_date}}
GROUP BY 1, 2
ORDER BY 3 DESC;
```

---

## 📞 Contacto

Email: smarterbotcl@gmail.com  
WhatsApp: +56 9 7954 0471  
Web: https://smarterbot.cl

🟢 **SmarterOS — SQL Library for Enterprise KPIs**
