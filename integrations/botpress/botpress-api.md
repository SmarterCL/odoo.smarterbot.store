# Botpress API (SmarterOS)

## Autenticación
Header: `Authorization: Bearer <API_KEY>`
Base: `https://botpress.smarterbot.cl/api/v1`

## Endpoints Usados
| Acción | Método | Path | Uso |
|--------|--------|------|-----|
| Conversar | POST | /bots/{botId}/converse | Obtener respuesta a mensaje usuario |
| Obtener bot | GET | /bots/{botId} | Metadata / versión |
| Listar intents | GET | /bots/{botId}/intents | Métricas / análisis |
| Acciones custom | POST | /bots/{botId}/actions/{name} | Ejecutar acción predefinida |

## Ejemplo Converse
```bash
curl -X POST "$BOTPRESS_URL/api/v1/bots/$BOTPRESS_BOT_ID/converse" \
 -H "Authorization: Bearer $BOTPRESS_API_KEY" \
 -H "Content-Type: application/json" \
 -d '{
   "type": "text",
   "payload": {"text": "Quiero ver mi pedido #541"},
   "metadata": {"tenant": "acme", "channel": "web"}
 }'
```

## Manejo de Intents
- Botpress retorna lista de intents detectadas con scores.
- Umbral configurable por tenant (Vault param futuro: `INTENT_THRESHOLD`).

## Errores Comunes
| Código | Motivo | Mitigación |
|--------|--------|-----------|
| 401 | API Key inválida | Rotar secreto Vault |
| 404 | Bot no existe | Validar BOT_ID en bootstrap |
| 422 | Payload mal formado | Validación previa FastAPI |

## Observabilidad
- Guardar `{intent, score, tenant, timestamp}` en `botpress_intents`.
- Dashboard Metabase: top intents, fallback ratio.
