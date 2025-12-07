# Q1 2025 Backlog: Botpress Agent Integration

## 📋 Tareas Pendientes

### ✅ Completadas

- [x] **Especificación completa:** `smarteros-specs/services/botpress-agent.yml` (782 lines)
- [x] **README roadmap:** Sección "Botpress Agent: Roadmap 2025" agregada
- [x] **Sandbox local:** `docker-compose.yml` con Botpress + Postgres + Redis + Duckling
- [x] **Documentación sandbox:** `services/botpress-sandbox/README.md` con quickstart

---

### 🔄 En Progreso (Q1 2025)

#### 1. Deploy Sandbox Local ⏳

**Objetivo:** Levantar entorno de desarrollo Botpress

**Pasos:**
```bash
cd smarteros-specs/services/botpress-sandbox
cp .env.example .env
# Editar .env con credenciales (OPENAI_API_KEY, etc.)
docker-compose up -d
```

**Validación:**
- [ ] Botpress UI accesible en http://localhost:3010
- [ ] PostgreSQL corriendo en puerto 5433
- [ ] Redis corriendo en puerto 6380
- [ ] pgvector extension habilitada: `docker exec -it botpress-postgres psql -U botpress -d botpress_dev -c "CREATE EXTENSION vector;"`

**Estimación:** 1 hora

---

#### 2. Implementar Triage Agent 🤖

**Objetivo:** Crear primer agente (router) con keywords-based routing

**Pasos:**

1. **Crear agent spec:**
```bash
cd services/botpress-sandbox
mkdir -p agents
```

Crear `agents/triage.yml`:
```yaml
name: "Triage Agent"
role: "Router"
description: "Classifies incoming messages and routes to specialist agents"

intents:
  - name: "billing"
    keywords: ["factura", "invoice", "pago", "payment", "cuanto debo", "saldo"]
  - name: "support"
    keywords: ["ayuda", "help", "soporte", "support", "problema", "issue"]
  - name: "ocr"
    keywords: ["documento", "document", "pdf", "imagen", "image"]

handoffs:
  - to: "billing"
    condition: "intent == 'billing'"
  - to: "support"
    condition: "intent == 'support'"
  - to: "ocr"
    condition: "intent == 'ocr' OR has_attachment"

fallback:
  message: "No entendí tu consulta. ¿Puedes reformular? Opciones: facturación, soporte técnico, análisis de documentos."
```

2. **Implementar custom action:**
```bash
mkdir -p actions
```

Crear `actions/classify_intent.ts`:
```typescript
import type { IntegrationContext } from '@botpress/sdk';

export default async function classifyIntent(ctx: IntegrationContext) {
  const { message, conversation } = ctx;
  const text = message.payload.text.toLowerCase();
  
  // Simple keyword matching
  const billingKeywords = ['factura', 'invoice', 'pago', 'payment', 'saldo'];
  const supportKeywords = ['ayuda', 'help', 'soporte', 'support', 'problema'];
  const ocrKeywords = ['documento', 'document', 'pdf', 'imagen'];
  
  if (billingKeywords.some(kw => text.includes(kw))) {
    return { intent: 'billing', confidence: 0.85 };
  }
  if (supportKeywords.some(kw => text.includes(kw))) {
    return { intent: 'support', confidence: 0.85 };
  }
  if (ocrKeywords.some(kw => text.includes(kw)) || message.payload.type === 'file') {
    return { intent: 'ocr', confidence: 0.90 };
  }
  
  return { intent: 'unknown', confidence: 0.0 };
}
```

3. **Deploy agent a Botpress:**
```bash
# Desde Botpress UI (http://localhost:3010)
# 1. Create new bot: "triage-agent"
# 2. Import agent definition: Upload agents/triage.yml
# 3. Configure custom actions: actions/classify_intent.ts
```

**Validación:**
- [ ] Agent responde a query: "¿Cuánto debo?" → handoff to billing
- [ ] Agent responde a query: "Tengo un problema" → handoff to support
- [ ] Agent responde a PDF attachment → handoff to ocr
- [ ] Fallback funciona: "xyz random text" → fallback message

**Estimación:** 4 horas

---

#### 3. Integrar Chatwoot Webhook 🔗

**Objetivo:** Conectar Chatwoot → Botpress para procesar mensajes

**Pasos:**

1. **Obtener credenciales de Vault:**
```bash
# Asumiendo Vault accesible
vault kv get secret/chatwoot/hmac
# Copiar webhook_secret
```

2. **Crear endpoint en Botpress:**

Crear `actions/handle_chatwoot_webhook.ts`:
```typescript
import type { IntegrationContext } from '@botpress/sdk';
import crypto from 'crypto';

export default async function handleChatwootWebhook(ctx: IntegrationContext) {
  const { request } = ctx;
  
  // Validar HMAC
  const signature = request.headers['x-chatwoot-hmac-sha256'];
  const payload = JSON.stringify(request.body);
  const expectedSignature = crypto
    .createHmac('sha256', process.env.CHATWOOT_HMAC_SECRET!)
    .update(payload)
    .digest('hex');
  
  if (signature !== expectedSignature) {
    throw new Error('Invalid HMAC signature');
  }
  
  const { event, message_created } = request.body;
  
  if (event === 'message_created' && message_created.message_type === 'incoming') {
    const { content, conversation_id, sender } = message_created;
    
    // Crear conversación en Botpress
    const conversation = await ctx.client.getOrCreateConversation({
      channel: 'chatwoot',
      tags: {
        chatwoot_conversation_id: conversation_id.toString(),
        tenant_id: sender.custom_attributes?.tenant_id || 'unknown'
      }
    });
    
    // Enviar mensaje al triage agent
    await ctx.client.createMessage({
      conversationId: conversation.id,
      userId: sender.id.toString(),
      type: 'text',
      payload: { text: content }
    });
  }
  
  return { status: 'ok' };
}
```

3. **Configurar webhook en Chatwoot:**
```bash
# Desde Chatwoot UI
# Settings → Integrations → Webhooks
# URL: http://host.docker.internal:3010/api/v1/webhooks/chatwoot
# Events: message_created
# Secret: (pegar webhook_secret de Vault)
```

**Validación:**
- [ ] Enviar mensaje WhatsApp → Chatwoot inbox
- [ ] Verificar webhook dispara en Botpress: `docker-compose logs -f botpress | grep chatwoot`
- [ ] Verificar conversación creada en Botpress
- [ ] Verificar triage agent responde

**Estimación:** 3 horas

---

#### 4. Test End-to-End 🧪

**Objetivo:** Validar flujo completo WhatsApp → Chatwoot → Botpress → n8n → response

**Escenario 1: Query de facturación**
```
Usuario (WhatsApp): "¿Cuánto debo?"
  → Chatwoot inbox
  → Webhook POST http://localhost:3010/api/v1/webhooks/chatwoot
  → Botpress triage agent: classify_intent() → intent="billing"
  → Handoff to billing agent
  → Billing agent: execute_workflow() → n8n webhook
  → n8n workflow: query Odoo invoices via MCP
  → MCP: GET /api/odoo/invoices (X-SMOS-Identity + HMAC)
  → Odoo: return invoices (amount_due)
  → n8n: return {"amount_due": "XXX.XX", "invoice_id": "INV-2025-001"}
  → Botpress billing agent: response
  → Chatwoot: POST /api/v1/accounts/{account_id}/conversations/{id}/messages
  → WhatsApp: "Tienes un saldo pendiente de XXX.XX (Factura INV-2025-001)"
```

**Validación:**
- [ ] Latency < 5s (end-to-end)
- [ ] Response correcta (monto + factura)
- [ ] Logs en n8n muestran ejecución
- [ ] Audit log en Redpanda: `smarteros.audit.botpress`

**Escenario 2: Soporte técnico**
```
Usuario (WhatsApp): "No puedo acceder al panel"
  → Chatwoot → Botpress triage → handoff to support agent
  → Support agent: execute_workflow() → n8n (send email to ops@smarterbot.cl)
  → n8n: send email via SMTP
  → Botpress: response "Ticket creado. Te contactaremos pronto."
  → Chatwoot → WhatsApp
```

**Validación:**
- [ ] Email recibido en ops@smarterbot.cl
- [ ] Response en WhatsApp < 3s
- [ ] Ticket ID generado en Odoo Help Desk

**Escenario 3: OCR con attachment**
```
Usuario (WhatsApp): [envía PDF factura]
  → Chatwoot (attachment URL)
  → Botpress triage: has_attachment → handoff to ocr agent
  → OCR agent: download PDF → extract text (no RAG todavía, usar n8n workflow legacy)
  → OCR agent: execute_workflow() → n8n OCR workflow
  → n8n: Vision API → extract invoice data
  → n8n: LLM intent classification
  → n8n: MCP update Odoo invoice
  → Botpress: response "Factura procesada: XXX.XX, vencimiento 2025-02-15"
  → Chatwoot → WhatsApp
```

**Validación:**
- [ ] PDF descargado correctamente
- [ ] OCR extraction accuracy > 90%
- [ ] Invoice creada en Odoo
- [ ] Latency < 10s (OCR es lento)

**Estimación total test:** 4 horas

---

### 📊 Métricas de Éxito Q1

| Métrica | Target | Status |
|---------|--------|--------|
| Latencia end-to-end | < 5s | ⏳ Pendiente |
| Accuracy clasificación | > 85% | ⏳ Pendiente |
| Eficiencia de recursos | Alta | ⏳ Pendiente |
| Uptime sandbox | > 95% | ⏳ Pendiente |
| Tests passing | 3/3 escenarios | ⏳ Pendiente |

---

## 🚧 Bloqueadores

1. **Credenciales de producción:** OPENAI_API_KEY, CHATWOOT_API_TOKEN, VAULT_TOKEN
   - **Resolución:** Usar credenciales de desarrollo (free tier OpenAI, Chatwoot demo)

2. **n8n no accesible desde Docker:** `host.docker.internal` puede no funcionar en Linux
   - **Resolución:** Usar IP local (`ip addr show`) o desplegar n8n también en sandbox

3. **pgvector no instalado:** Postgres base no incluye extension
   - **Resolución:** Crear custom Dockerfile con `apt-get install postgresql-16-pgvector`

---

## 📅 Timeline Q1 2025

| Semana | Tareas | Owner |
|--------|--------|-------|
| **Semana 1** (6-12 Enero) | Deploy sandbox + triage agent | DevOps + AI Team |
| **Semana 2** (13-19 Enero) | Integración Chatwoot webhook | Backend Team |
| **Semana 3** (20-26 Enero) | Test end-to-end 3 escenarios | QA + Founder |
| **Semana 4** (27 Enero - 2 Feb) | Ajustes + documentación | AI Team |

**Deadline:** 2 Febrero 2025 ✅

---

## 🔗 Referencias

- **Especificación:** [`services/botpress-agent.yml`](services/botpress-agent.yml)
- **Sandbox:** [`services/botpress-sandbox/`](services/botpress-sandbox/)
- **Roadmap:** [`README.md#botpress-agent-roadmap-2025`](README.md#-botpress-agent-roadmap-2025)
- **Botpress ADK Docs:** https://botpress.com/docs/agents/adk
- **Chatwoot Webhooks:** https://www.chatwoot.com/docs/product/channels/api/webhooks

---

## 🆘 Support

**Issues o preguntas:**
- GitHub: [SmarterCL/smarteros-specs/issues](https://github.com/SmarterCL/smarteros-specs/issues)
- Email: smarterbotcl@gmail.com
- WhatsApp: Fundador

**Next Steps (Q2 2025):** RAG Migration → migrar OCR workflow a Botpress knowledge base
