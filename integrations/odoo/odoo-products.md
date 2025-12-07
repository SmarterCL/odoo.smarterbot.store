# Odoo Productos (product.template)

## Campos Relevantes
| Campo | Uso |
|-------|-----|
| name | Nombre público |
| list_price | Precio venta |
| standard_price | Costo |
| type | Tipo (consu, service, product) |
| uom_id | Unidad de medida |
| qty_available | Stock |
| barcode | Identificador externo |

## Sincronización a Supabase
Tabla `products_cache` en Supabase para queries rápidas frontend.

```sql
CREATE TABLE products_cache (
  id BIGSERIAL PRIMARY KEY,
  tenant TEXT NOT NULL,
  odoo_id INTEGER NOT NULL,
  name TEXT NOT NULL,
  price NUMERIC(12,2) NOT NULL,
  stock NUMERIC(12,2),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);
```

## Flujo Actualización
1. n8n job (cada 15m) → listar productos modificados.
2. Upsert en `products_cache`.
3. Invalidate simple cache en FastAPI.

## Estándares
- Nunca exponer `standard_price` al público.
- Validar `type` para excluir servicios donde aplique.

## Métricas
- Desfase medio stock (Odoo vs cache).
- Tiempo de refresh.
