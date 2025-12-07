# Comparación Dominios: Configurados vs Specs
Fecha: 2025-11-18T18:54:25.770Z

## ✅ Dominios Activos y Configurados

| Dominio | Estado Actual | En Specs | Backend | Notas |
|---------|---------------|----------|---------|-------|
| kpi.smarterbot.cl | ✅ Activo | ❌ No | Metabase:3000 | Nuevo, no en registry |
| portainer.smarterbot.cl | ✅ Activo | ✅ Sí | Portainer:9000 | Coincide |
| dokploy.smarterbot.cl | ✅ Activo | ✅ Sí | Dokploy:3000 | Coincide |
| dokploy.smarterbot.store | ✅ Activo | ❌ No | Dokploy:3000 | Alias nuevo |
| n8n.smarterbot.cl | ✅ Activo | ✅ Sí | N8N:5678 | Coincide |
| odoo.smarterbot.cl | ✅ Activo | ✅ Sí | Odoo:8069 | Coincide |
| chatwoot.smarterbot.cl | ✅ Activo | ✅ Sí | Chatwoot:3000 | Coincide |
| chat.smarterbot.cl | ✅ Activo | ❌ No | Botpress:3000 | Specs usa botpress.smarterbot.cl |
| ai.smarterbot.store | ✅ Activo | ❌ No | Nexa:8000 | Nuevo |

## 📋 Dominios en Specs NO Configurados

| Dominio | Estado | Acción Requerida |
|---------|--------|------------------|
| app.smarterbot.cl | Externo (Vercel) | ✅ OK - Frontend en Vercel |
| dash.smarterbot.cl | No deployado | Planificado |
| mkt.smarterbot.cl | No deployado | Planificado |
| store.smarterbot.cl | No deployado | Planificado |
| docs.smarterbot.cl | No deployado | Planificado |
| botpress.smarterbot.cl | ❌ Falta | Debería apuntar a smarter-botpress:3000 |
| metabase.smarterbot.cl | ❌ Falta | Usar kpi.smarterbot.cl como alias |
| api.smarterbot.cl | Error 1033 | Backend no definido |
| api.chatwoot.smarterbot.cl | No configurado | Proxy a Chatwoot API |
| mcp.smarterbot.cl | No configurado | MCP Server no deployado |
| mainkey.smarterbot.cl | No configurado | Vault no deployado |
| kafka.smarterbot.cl | No configurado | Kafka no deployado |
| redpanda.smarterbot.cl | No configurado | Redpanda no deployado |
| status.smarterbot.cl | No configurado | Health check dashboard |
| call.smarterbot.cl | No configurado | Planificado |
| fulldaygo.smarterbot.cl | No configurado | Planificado |
| ai.smarterbot.cl | Error 1033 | Conflicto con ai.smarterbot.store |

## 🔧 Discrepancias y Correcciones

### 1. Botpress
- **Actual:** `chat.smarterbot.cl` → Botpress
- **Specs:** `botpress.smarterbot.cl`
- **Acción:** Agregar `botpress.smarterbot.cl` como alias

### 2. Metabase
- **Actual:** `kpi.smarterbot.cl` → Metabase
- **Specs:** Referencias a `metabase.smarterbot.cl` y `ai.smarteros.cl` (error)
- **Acción:** Agregar `metabase.smarterbot.cl` como alias

### 3. AI Services
- **Actual:** `ai.smarterbot.store` → Nexa
- **Specs:** No menciona ai.smarterbot.store
- **Problema:** `ai.smarterbot.cl` en Cloudflare con error
- **Acción:** Decidir si consolidar en ai.smarterbot.store

### 4. Servicios Faltantes
Definidos en specs pero NO deployados:
- MCP Server (mcp.smarterbot.cl)
- Vault (mainkey.smarterbot.cl)
- Kafka/Redpanda (kafka/redpanda.smarterbot.cl)
- API Gateway (api.smarterbot.cl)

## 📝 Actualización Recomendada para Registry

```yaml
# Agregar a services/registry.yml:

  - id: "kpi"
    name: "KPI Dashboard (Metabase)"
    type: "infrastructure"
    status: "active"
    url: "https://kpi.smarterbot.cl"
    aliases:
      - "https://metabase.smarterbot.cl"
    tech_stack:
      platform: "Metabase"
      version: "latest"
    deployment:
      platform: "Docker (VPS)"
      container_name: "smarteros-metabase"
      ports: ["3000:3000"]

  - id: "nexa"
    name: "Nexa AI Server"
    type: "backend"
    status: "active"
    url: "https://ai.smarterbot.store"
    tech_stack:
      platform: "Nexa SDK"
      runtime: "Python"
    deployment:
      platform: "Docker (VPS)"
      container_name: "nexa-server"
      ports: ["8000:8000"]

# Actualizar Botpress:
  - id: "botpress"
    url: "https://chat.smarterbot.cl"  # Actualizar desde botpress.smarterbot.cl
    aliases:
      - "https://botpress.smarterbot.cl"

# Actualizar Dokploy:
  - id: "dokploy"
    url: "https://dokploy.smarterbot.cl"
    aliases:
      - "https://dokploy.smarterbot.store"
```

## 🚀 Infraestructura Actual

**Reverse Proxy:** Caddy 2 Alpine
**SSL:** Let's Encrypt (automático)
**HTTP/3:** Habilitado
**Puertos:** 80, 443, 443/udp

**Estado:** Traefik → Caddy migración completada ✅
