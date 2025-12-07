# Chatwoot API Reference (SmarterOS Context)

## Base
`GET/POST {CHATWOOT_BASE_URL}/api/v1/...`
Auth: `Authorization: Bearer <API_TOKEN>`

## Endpoints Usados
| Acción | Método | Path | Uso |
|--------|--------|------|-----|
| Crear conversación | POST | /accounts/{account_id}/conversations | Alta inicial de lead/chat |
| Listar mensajes | GET | /accounts/{account_id}/conversations/{id}/messages | Recuperar historial |
| Crear mensaje | POST | /accounts/{account_id}/conversations/{id}/messages | Respuesta automática n8n/Botpress |
| Crear contacto | POST | /accounts/{account_id}/contacts | Registro cliente si no existe |
| Listar contactos | GET | /accounts/{account_id}/contacts | Segmentación / analytics |

## Ejemplo Creación Conversación
```bash
curl -X POST "$CHATWOOT_BASE_URL/api/v1/accounts/$ACCOUNT_ID/conversations" \
 -H "Authorization: Bearer $API_TOKEN" \
 -H "Content-Type: application/json" \
 -d '{
  "source_id": "lead-user@example.com",
  "inbox_id": 1,
  "contact": {"name": "User Example", "email": "user@example.com"},
  "additional_attributes": {"domain": "smarterbot.cl", "tenant": "acme"}
}'
```

## Ejemplo Mensaje Saliente
```bash
curl -X POST "$CHATWOOT_BASE_URL/api/v1/accounts/$ACCOUNT_ID/conversations/$CONV_ID/messages" \
 -H "Authorization: Bearer $API_TOKEN" \
 -H "Content-Type: application/json" \
 -d '{
  "content": "Hola 👋 ¿Cómo puedo ayudarte?",
  "content_type": "text",
  "private": false,
  "message_type": "outgoing"
}'
```

## Rate Limits
- Controlar reintentos en n8n.
- Backoff exponencial para mensajes automáticos.

## Errores Comunes
| Código | Causa | Mitigación |
|--------|-------|------------|
| 401 | Token inválido | Rotar credencial Vault |
| 404 | Conversación inexistente | Validar id antes de acción |
| 429 | Rate limit | Retries con espera incremental |

## Observabilidad
- Registrar `conversation_created`, `message_created` en Supabase table `chatwoot_events`.
- Dashboards Metabase: volumen por tenant, tiempo de respuesta.
