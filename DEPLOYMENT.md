# 🚀 Guía de Deployment de SmarterOS

Instrucciones oficiales para desplegar SmarterOS en producción.

---

## 🧠 Arquitectura del Deployment

```
Vercel (Frontend)
├─ Landing
├─ Portal Maestro
├─ CRM Frontend
└─ Marketing Center

VPS (Backend)
├─ Odoo ERP
├─ PostgreSQL
├─ API Gateway
├─ Chatwoot
├─ Botpress
├─ n8n
└─ Metabase
```

---

## 1️⃣ Preparar Credenciales

### Clerk
Obtener en [dashboard.clerk.com](https://dashboard.clerk.com):

```env
CLERK_PUBLISHABLE_KEY=
CLERK_SECRET_KEY=
```

### Supabase

```env
SUPABASE_URL=
SUPABASE_SERVICE_ROLE=
```

### OpenAI API Key

```env
OPENAI_API_KEY=
```

Colocarlas en los `.env` siguientes:
- `/smarteros-portal/.env`
- `/smarteros-crm/.env`
- `/smarteros-marketing/.env`
- `/api-gateway/.env`

---

## 2️⃣ Deploy Frontend (Vercel)

```bash
cd smarteros-landing
vercel --prod

cd smarteros-portal
vercel --prod

cd smarteros-crm
vercel --prod

cd smarteros-marketing
vercel --prod
```

---

## 3️⃣ Configurar DNS (Cloudflare)

| Subdominio | Apunta a |
|------------|----------|
| `smarterbot.cl` | Vercel |
| `app.smarterbot.cl` | Vercel |
| `crm.smarterbot.cl` | Vercel |
| `mkt.smarterbot.cl` | Vercel |

---

## 4️⃣ Backend en VPS

### Odoo
```bash
cd /root/odoo-smarter
docker compose up -d --build
```

### API Gateway
```bash
cd /root/api-gateway-clerk
docker compose up -d
```

### Chatwoot / Botpress / n8n / KPI
```bash
docker compose up -d
```

---

## 5️⃣ Test SSO E2E

1. Ir a `https://app.smarterbot.cl/login`
2. Crear cuenta vía Clerk
3. Desde portal → abrir ERP
4. Verificar login
5. Abrir CRM
6. Verificar sesión
7. Abrir Marketing / KPI

**Todo debe funcionar con el mismo usuario.**

---

## 6️⃣ Datos Demo

- Tenant DEMO
- Productos Shopify/Odoo
- Agentes AI (ventas, soporte, OCR)
- 3 workflows n8n
- KPI básico Metabase

---

## 7️⃣ Checklist de Producción

- ✅ SSL
- ✅ SSO
- ✅ DNS
- ✅ Backups
- ✅ Logs
- ✅ Audit (Vault/MCP)
- ✅ Primer tenant activo

**Sistema listo para clientes.** 🚀
