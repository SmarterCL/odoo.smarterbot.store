# TENANT-SETUP.md - Crear Tenant en 60 Minutos

## 🎯 Objetivo
Crear un tenant completo (ej: Sweet Maite) en 1 hora.

## ⏱️ Timeline

### Min 0-10: Información básica
```bash
RUT: 12345678-9
Nombre: Sweet Maite
Dominio: sweetmaite.smarterbot.cl
Shopify: sweetmaite.myshopify.com
WhatsApp: +56 9 XXXX XXXX
```

### Min 10-20: Estructura de carpetas
```bash
cd ~/dev/2025/tenants
mkdir sweet-maite
cd sweet-maite
cp ../template/* .
```

Archivos creados:
- `.env.shopify` (token único)
- `.env.supabase` (RLS por tenant_id)
- `config.yml` (configuración tenant)

### Min 20-30: Shopify Store
1. Crear tienda en Shopify
2. Instalar app MCPready
3. Configurar productos base
4. Conectar dominio

### Min 30-40: N8N Workflows
1. Duplicar workflows template
2. Ajustar tenant_id en cada nodo
3. Configurar webhooks Shopify
4. Activar workflows

### Min 40-50: Odoo + Facturación
1. Crear empresa en Odoo
2. Configurar RUT + datos fiscales
3. Conectar con Shopify vía N8N
4. Testear facturación

### Min 50-60: WhatsApp + Bot
1. Configurar número en Chatwoot
2. Conectar con Botpress
3. Configurar respuestas automáticas
4. Test completo

## ✅ Checklist Final
- [ ] Shopify storefront funcional
- [ ] Productos sincronizados en Odoo
- [ ] WhatsApp responde automáticamente
- [ ] Tracking de pedidos operativo
- [ ] Dashboard Metabase con KPIs
- [ ] Cliente puede hacer pedido end-to-end

## 🚀 Post-Setup
- Capacitar al cliente (30 min)
- Entregar credenciales
- Activar soporte vía WhatsApp
- Programar revisión semanal
