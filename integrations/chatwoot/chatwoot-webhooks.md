# Chatwoot Webhooks (SmarterOS)

## Objetivo
Capturar eventos clave y orquestarlos vía FastAPI + n8n + Botpress.

## Eventos Clave
| Event | Uso OS |
|-------|--------|
| conversation_created | Iniciar workflow de lead / intención |
| message_created (incoming) | Clasificar intención Botpress |
| message_created (outgoing) | Auditoría / métricas |
| conversation_updated | Sincronizar estado (closed → lead won) |

## Configuración
Panel Chatwoot → Settings → Integrations → Webhooks.

Webhook URL (por tenant):
```
https://api.smarterbot.cl/events/chatwoot?tenant=<TENANT_ID>
```

Headers sugeridos (futuros):
```
X-SMOS-Tenant: <TENANT_ID>
X-SMOS-Signature: <HMAC_SHA256>
```

## Seguridad
1. Validar `tenant` contra lista en Supabase (`tenants` table).
2. Verificar firma (pendiente implementación HMAC compartido Vault).
3. Rate limit básico (FastAPI dependency) por IP / tenant.

## Payload Ejemplo (conversation_created)
```json
{
  "id": 12345,
  "event": "conversation_created",
  "account_id": 1,
  "inbox_id": 2,
  "created_at": 1732300100,
  "meta": {
    "sender": {
      "id": 987,
      "email": "user@example.com",
      "name": "User Example"
    }
  }
}
```

## Flujo Procesamiento
1. FastAPI valida tenant + normaliza JSON.
2. Encola en n8n webhook endpoint.
3. n8n ejecuta:
   - Botpress: intención
   - Odoo: crear lead si corresponde
   - Supabase: persistir evento
   - Chatwoot: responder automático (mensaje saliente)

## Retries / Resiliencia
- Si n8n responde 5xx → reintentar 3 veces con backoff.
- Registrar fallos en `webhook_failures` (Supabase) para monitoreo.

## Métricas
- Tasa de clasificaciones automáticas vs manuales.
- Tiempo medio de primera respuesta.
- Leads generados por conversación (Odoo).
