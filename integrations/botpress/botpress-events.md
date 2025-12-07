# Botpress Events / Webhooks

(En evaluación: Botpress Cloud webhooks → FastAPI → n8n)

## Potenciales Eventos
| Evento | Uso |
|--------|-----|
| intent_detected | Analytics / decisión routing |
| action_executed | Auditoría / métricas |
| conversation_started | Crear lead en Odoo |

## URL Propuesta
```
https://api.smarterbot.cl/events/botpress?tenant=<TENANT_ID>
```

## Seguridad
- API Key Botpress solo para llamadas salientes (verificar si Botpress firma).
- Futura firma HMAC compartida en Vault.

## Pipeline Ejemplo
1. intent_detected llega a FastAPI.
2. FastAPI normaliza → Encola en n8n.
3. n8n verifica si intención requiere acción (Odoo / Supabase).
4. n8n responde y envía mensaje final a Chatwoot (si corresponde).

## Persistencia
Tabla Supabase `botpress_events`:
```sql
CREATE TABLE botpress_events (
  id BIGSERIAL PRIMARY KEY,
  tenant TEXT NOT NULL,
  event_type TEXT NOT NULL,
  payload JSONB NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW()
);
```
