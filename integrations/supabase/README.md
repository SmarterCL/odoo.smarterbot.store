# Supabase Integration

Supabase actúa como capa de datos rápida (cache, eventos, analytics) y soporte multi-tenant complementando Odoo.

## Tablas Principales
- `contacts` (formularios / leads iniciales)
- `products_cache` (snapshot productos Odoo)
- `analytics_events` (tracking frontend)
- `botpress_intents`, `chatwoot_events`, `botpress_events` (observabilidad)
- `tenants` (registro tenants OS)

## Vault Secrets
```
secret/tenant/<TENANT_ID>/supabase/URL
secret/tenant/<TENANT_ID>/supabase/SERVICE_ROLE
```

## RLS (Row Level Security)
Activar RLS y aplicar políticas por `tenant` para vistas públicas futuras.

## Sincronización
- n8n jobs periódicos actualizan `products_cache`.
- FastAPI inserta eventos en tiempo real.

## Métricas
- Latencia inserción contactos.
- Diferencia stock (Odoo vs cache).
- Tasa de intents automáticas vs manuales.
