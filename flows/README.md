# E2E Flows: Contratos Multi-Tenant

Este directorio contiene las especificaciones completas de los flujos end-to-end (E2E) de SmarterOS, diseñados como **contratos entre servicios** listos para implementar.

## 📋 Flujos Disponibles

### 1. **Venta Asistida con Shopify** (`e2e-shopify-sales.yml`)
**Patrón:** Chatwoot → n8n → Botpress → MCP (Shopify) → n8n → Chatwoot

**Caso de uso:**
```
Cliente: "¿Tienen zapatillas talla 42?"
Sistema: "Claro, te busco zapatillas en talla 42...
          1) Zapatilla Running Azul — 39990 CLP
             Link: https://...
          ¿Quieres que te prepare el carrito de compra?"
```

**Características:**
- ✅ Búsqueda de productos en Shopify
- ✅ Respuesta con links directos de compra
- ✅ Latencia objetivo: < 5s
- ✅ Success rate: > 95%

---

### 2. **Soporte con Imagen (OCR + RAG)** (`e2e-ocr-support.yml`)
**Patrón:** Chatwoot → n8n (OCR) → Botpress (RAG) → MCP (Odoo) → n8n → Chatwoot

**Caso de uso:**
```
Cliente: [Envía foto de factura]
Sistema: "Tu compra tiene garantía de 90 días hasta el 13 de enero.
          Puedes hacer devolución gratuita hasta el 14 de noviembre.
          ¿Qué problema tiene el producto?"
```

**Características:**
- ✅ OCR con Google Cloud Vision
- ✅ Extracción de entidades (factura, producto, fecha)
- ✅ RAG sobre documentos de garantía
- ✅ Consulta a Odoo para verificar compra
- ✅ Latencia objetivo: < 8s
- ✅ Success rate: > 92%

---

### 3. **FAQ Rápida (Solo Botpress KB)** (`e2e-faq-quick.yml`)
**Patrón:** Chatwoot → n8n → Botpress (KB directo) → n8n → Chatwoot

**Caso de uso:**
```
Cliente: "¿Cuál es el horario de atención?"
Sistema: "Nuestro horario es:
          • Lunes a Viernes: 9:00 a 18:00
          • Sábados: 10:00 a 14:00
          ¿En qué más puedo ayudarte?"
```

**Características:**
- ✅ Respuesta directa desde KB (sin MCP)
- ✅ Latencia objetivo: < 2s
- ✅ Success rate: > 98%
- ✅ Categorías: Horarios, Ubicación, Pago, Envíos, Devoluciones, Contacto

---

## 🏗️ Arquitectura Multi-Tenant

Todos los flujos implementan **aislamiento por workspace** (Botpress workspace per tenant):

### Headers Standard
```yaml
X-SMOS-Tenant-ID: "TENANT_RUT_12345678"
X-SMOS-Conversation-ID: "12345"
X-SMOS-Channel: "whatsapp | webwidget | email"
X-Chatwoot-Signature: "<HMAC_SHA256>"
X-SMOS-User-Role: "end_user | agent | system"
```

### Vault Paths (Por Tenant)
```
secret/tenant/<TENANT_ID>/
├── chatwoot/
│   ├── api_token
│   └── hmac_secret
├── botpress/
│   ├── api_key
│   ├── workspace_id
│   ├── bot_id_sales
│   ├── bot_id_support
│   └── bot_id_faq
├── shopify/
│   ├── admin_token
│   └── store_domain
├── odoo/
│   ├── api_key
│   └── instance_url
└── ocr/
    └── api_key
```

---

## 🔄 Contratos entre Servicios

### n8n → Botpress (Request)
```json
{
  "tenant_id": "TENANT_DEMO",
  "channel": "whatsapp",
  "conversation_id": 12345,
  "contact": {
    "id": 9988,
    "name": "Juan Pérez",
    "phone": "+56979540471",
    "email": null
  },
  "message": {
    "id": 555,
    "type": "text",
    "content": "¿Tienen zapatillas talla 42?",
    "attachments": []
  },
  "context": {
    "language": "es-CL",
    "shopify_connected": true,
    "shopify_store_domain": "tienda-demo.myshopify.com"
  }
}
```

### Botpress → n8n (Response)
```json
{
  "intent": "product_query",
  "confidence": 0.94,
  "route": "shopify_sales",
  "entities": {
    "category": "zapatillas",
    "size": "42"
  },
  "actions": [
    {
      "type": "CALL_MCP",
      "tool": "shopify_search_products",
      "params": {
        "query": "zapatillas talla 42",
        "limit": 5
      }
    }
  ],
  "reply_suggestion": "Claro, te busco zapatillas en talla 42..."
}
```

---

## 📊 Métricas y SLOs

| Flujo | Latencia P95 | Success Rate | Error Rate |
|-------|--------------|--------------|------------|
| Shopify Sales | < 5s | > 95% | < 5% |
| OCR Support | < 8s | > 92% | < 8% |
| FAQ Quick | < 2s | > 98% | < 2% |

### Alertas Configuradas
- ❌ **Latency P95 > SLO:** Slack + Email a ops@smarterbot.cl
- ❌ **Error rate > 5%:** PagerDuty incident + WhatsApp a founder
- ❌ **Service down:** PagerDuty + Slack + Email

---

## 🚀 Deployment

### Pre-requisitos
1. **Vault configurado** con secrets por tenant
2. **n8n workflows** importados desde `n8n-workflows/`
3. **Botpress agents** desplegados con KB cargados
4. **MCP server** running en `https://mcp.smarterbot.cl`
5. **Chatwoot** configurado con webhooks a n8n

### Pasos
```bash
# 1. Cargar secrets en Vault
vault kv put secret/tenant/TENANT_DEMO/chatwoot/api_token value="..."
vault kv put secret/tenant/TENANT_DEMO/botpress/api_key value="..."
# ... (ver vault_paths en cada yml)

# 2. Importar workflows n8n
n8n import:workflow --input=n8n-workflows/chatwoot-events-router.json
n8n import:workflow --input=n8n-workflows/chatwoot-ocr-router.json
n8n import:workflow --input=n8n-workflows/chatwoot-faq-router.json

# 3. Activar workflows
n8n workflow:activate <workflow_id>

# 4. Configurar webhooks en Chatwoot
# Settings → Integrations → Webhooks
# URL: https://n8n.smarterbot.cl/webhook/chatwoot-events
# Events: message_created
# HMAC: (from Vault secret/tenant/<TENANT_ID>/chatwoot/hmac_secret)
```

---

## 🧪 Testing

Cada flujo incluye `test_scenarios` con casos de prueba:

### Ejemplo: Happy Path (Shopify Sales)
```yaml
test_scenarios:
  - scenario: "Happy path: product found"
    input: "¿Tienen zapatillas talla 42?"
    expected_intent: "product_query"
    expected_route: "shopify_sales"
    expected_products: "> 0"
    expected_latency: "< 5s"
```

### Ejecutar tests
```bash
# Con n8n CLI
n8n execute --id=<workflow_id> --test-data=test-scenarios.json

# O manualmente
curl -X POST https://n8n.smarterbot.cl/webhook/chatwoot-events \
  -H 'Content-Type: application/json' \
  -H 'X-Chatwoot-Signature: <HMAC>' \
  -d @test-payload.json
```

---

## 🔧 Troubleshooting

### 1. HMAC validation failed
```bash
# Verificar secret en Vault
vault kv get secret/tenant/TENANT_DEMO/chatwoot/hmac_secret

# Regenerar signature
echo -n '<payload>' | openssl dgst -sha256 -hmac '<secret>'
```

### 2. Botpress unavailable
```bash
# Health check
curl https://botpress.smarterbot.cl/api/v1/health

# Logs
kubectl logs -n smarteros botpress-<pod>
```

### 3. MCP timeout
```bash
# Check MCP logs
kubectl logs -n smarteros mcp-server-<pod>

# Test MCP tool directly
curl -X POST https://mcp.smarterbot.cl/api/tools/shopify_search_products \
  -H 'Authorization: Bearer <token>' \
  -d '{"query": "zapatillas", "limit": 5}'
```

---

## 📚 Documentación Relacionada

- [ARCHITECTURE.md](../ARCHITECTURE.md) - Arquitectura general de SmarterOS
- [SERVICES.md](../SERVICES.md) - Catálogo de servicios
- [Botpress Agent Spec](../services/botpress-agent.yml) - Configuración de agentes
- [MCP Tools](../services/mcp-tools.yml) - Herramientas MCP disponibles

---

## 🗓️ Roadmap

### Q1 2025
- ✅ Specs completas de 3 flujos E2E
- ⏳ Deploy sandbox workflows (n8n + Botpress)
- ⏳ Test con 3 tenants

### Q2 2025
- ⏳ Multi-agent handoffs (sales → support → billing)
- ⏳ Context preservation across agents
- ⏳ Cart generation + checkout links

### Q3 2025
- ⏳ Advanced analytics (conversion rate tracking)
- ⏳ A/B testing on response variations
- ⏳ Multi-language support (EN + ES)

### Q4 2025
- ⏳ Dedicated Botpress per tenant (enterprise tier)
- ⏳ Custom LLM fine-tuning per tenant
- ⏳ SLA 99.9% monitoring

---

## 📞 Contacto

- **Email:** smarterbotcl@gmail.com
- **GitHub:** https://github.com/SmarterCL
- **Docs:** https://docs.smarterbot.cl

---

_Última actualización: 2025-11-17_
