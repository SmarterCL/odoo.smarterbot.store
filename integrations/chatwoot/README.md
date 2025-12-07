# Chatwoot Integration

SmarterOS utiliza Chatwoot como CRM conversacional multi-tenant. Cada tenant posee su propio inbox y credenciales aisladas en Vault.

## Componentes Clave
- Conversaciones (Contacts + Messages)
- Inboxes (canales por tenant)
- Webhooks (event callbacks hacia FastAPI / n8n)
- API Token (scoped por tenant)

## Flujo Básico
1. Usuario inicia conversación desde widget (web/chatbot).
2. Chatwoot genera `conversation_created` webhook → FastAPI Gateway.
3. FastAPI normaliza y envía a n8n.
4. n8n consulta Botpress para intención.
5. n8n ejecuta acción (Odoo / Supabase / Email).
6. Respuesta vuelve a Chatwoot como mensaje saliente.

## Vault Secrets (por tenant)
```
secret/tenant/<TENANT_ID>/chatwoot/BASE_URL
secret/tenant/<TENANT_ID>/chatwoot/API_TOKEN
secret/tenant/<TENANT_ID>/chatwoot/ACCOUNT_ID
secret/tenant/<TENANT_ID>/chatwoot/INBOX_ID
```

## Métricas Relevantes
- Tiempo primera respuesta
- Mensajes por conversación
- Conversaciones abiertas vs cerradas
- Escalamiento a Botpress vs agentes humanos

## Integración con Otros Pilares
| Pilar     | Integración |
|-----------|------------|
| Botpress  | Intents / respuestas automáticas |
| Odoo      | Creación de lead / cliente desde conversación |
| Supabase  | Persistencia agregada / analytics |
| n8n       | Orquestación de flujos post webhook |
| FastAPI   | Gateway de eventos + normalización |

## Seguridad
- Tokens se almacenan solo en Vault (service/backends).
- Políticas separadas: `api-tenant-read.hcl`, `n8n-tenant-read.hcl`.
- Rutas entrantes verifican el header de firma (cuando se habilite HMAC).

## Próximas Extensiones
- HMAC signing en webhooks.
- Auto-tagging ML.
- Escalamiento multi-inbox.
