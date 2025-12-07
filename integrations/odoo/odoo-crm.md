# Odoo CRM (res.partner)

## Objetivo
Centralizar leads y clientes generados desde Chatwoot, Botpress y formularios.

## Campos Clave
| Campo | Uso |
|-------|-----|
| name | Nombre del contacto |
| email | Correo |
| phone | Teléfono |
| company_type | 'person' / 'company' |
| is_company | Boolean |
| category_id | Tags / segmentación |
| function | Cargo |

## Lead vs Cliente
- Crear primero `res.partner` como contacto.
- Extender con módulo CRM (si se habilita) para pipeline.

## Creación Automática (n8n)
Workflow: Chatwoot event → Botpress intención "lead" → Crear partner → Responder.

## Ejemplo Create
```json
{"jsonrpc":"2.0","method":"call","params":{"service":"object","method":"execute_kw","args":["db","uid","pwd","res.partner","create",[{"name":"Lead Test","email":"lead@test.com","phone":"+56 9 1234 5678"}]]},"id":99}
```

## Validaciones
- Unicidad por email (buscar antes de crear).
- Normalizar número telefónico (E.164).

## Métricas
- Leads por tenant / día.
- Conversión a clientes (flag interno futuro).
