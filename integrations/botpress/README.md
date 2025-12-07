# Botpress Integration

Botpress provee el motor de chatbot inteligente para SmarterOS: intents, flujos y acciones orquestadas contra Odoo, Supabase y Chatwoot.

## Componentes
- Bot (Bot ID) por tenant
- Workspace (multi-bots optional)
- Webchat script embebido
- Webhooks / Events (mensajes entrantes / acciones)

## Flujo Conversacional
1. Usuario escribe en widget.
2. Botpress detecta intención.
3. Si requiere datos → consulta FastAPI (Odoo/Supabase).
4. Respuesta base + contexto (ej: estado pedido, stock producto).
5. Chatwoot recibe mensaje final (archivo de conversación unificado).

## Vault Secrets
```
secret/tenant/<TENANT_ID>/botpress/API_KEY
secret/tenant/<TENANT_ID>/botpress/BOT_ID
secret/tenant/<TENANT_ID>/botpress/WORKSPACE_ID
secret/tenant/<TENANT_ID>/botpress/URL
```

## Observabilidad
- Log intents → Supabase `botpress_intents`.
- Métricas: tasa resolución automática, fallback a agente.

## Extensiones Futuras
- Embeddings FAQ dinámicas.
- Entrenamiento incremental por tenant.
