# Odoo JSON-RPC Integration

SmarterOS se conecta a Odoo vía JSON-RPC para operaciones ERP multi-tenant.

## Endpoint Base
```
https://odoo.smarterbot.cl/jsonrpc
```

## Autenticación
1. Login: `call` al método `authenticate` (db, username, password).
2. Obtención de `uid` y uso en llamadas posteriores.

## Ejemplo Python
```python
import json, requests
url = "https://odoo.smarterbot.cl/jsonrpc"
payload = {
  "jsonrpc": "2.0",
  "method": "call",
  "params": {
    "service": "common",
    "method": "authenticate",
    "args": ["db_tenant", "user@example.com", "pass", {}]
  },
  "id": 1
}
r = requests.post(url, json=payload)
uid = r.json()["result"]
```

## Operaciones Clave
| Modelo | Uso |
|--------|-----|
| `res.partner` | Clientes / leads CRM |
| `sale.order` | Pedidos / ventas |
| `product.template` | Catálogo productos |
| `account.move` | Facturas |

## Patrón create/read/update
```json
{"jsonrpc":"2.0","method":"call","params":{"service":"object","method":"execute_kw","args":["db","uid","password","res.partner","create",[{"name":"Nuevo Lead","email":"lead@example.com"}]]},"id":2}
```

## Vault Secrets
```
secret/tenant/<TENANT_ID>/odoo/URL
secret/tenant/<TENANT_ID>/odoo/DB
secret/tenant/<TENANT_ID>/odoo/USER
secret/tenant/<TENANT_ID>/odoo/PASSWORD
```

## Buenas Prácticas
- Reutilizar sesión (pool httpx) en FastAPI.
- Mapear errores Odoo → códigos HTTP claros.
- Validar inputs antes de crear registros.

## Métricas
- Latencia promedio por modelo.
- Errores por endpoint.
- Volumen de operaciones por tenant.
