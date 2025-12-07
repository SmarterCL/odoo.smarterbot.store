# 🔌 Estado MCP Servers - SmarterOS

**Fecha**: 2025-11-19  
**Sistema**: SmarterOS Production

---

## ✅ MCPs Activos

### TIER 1: Core Infrastructure

| MCP Provider | Status | Endpoint | Notas |
|-------------|--------|----------|-------|
| **GitHub** | 🟢 Running | `localhost:3001` | Proxy activo, 20 horas uptime |
| **Vault** | 🟡 Unhealthy | `localhost:8081` | Corriendo pero unhealthy |
| **Clerk** | 🔴 No configurado | - | Requiere NPM package + secrets |
| **SmarterMCP** | 🔴 No configurado | - | Requiere NPM package + secrets |
| **Docker** | ⚪ Nativo | Docker socket | Acceso directo via socket |
| **Hostinger** | 🔴 No configurado | - | Requiere NPM package + API token |
| **Supabase** | 🔴 No configurado | - | Requiere secrets en Vault |

---

## 📦 Paquetes NPM Requeridos

Instalar globalmente:

```bash
# TIER 1 Core
npm install -g @clerk/mcp-tools
npm install -g @smartercl/mcp-server
npm install -g hostinger-api-mcp

# TIER 5 DevOps (opcional)
npm install -g mcp-remote  # Para conectar a MCPs remotos
```

---

## 🔑 Configuración de Secrets

### GitHub MCP ✅
```bash
# Ya configurado, verificar:
curl http://localhost:3001/health
```

### Clerk MCP 🔴
```yaml
Path: smarteros/mcp/clerk
Keys required:
  - clerk_publishable_key
  - clerk_secret_key
  - clerk_jwt_key
  - clerk_webhook_secret
```

**Config para MCP Client:**
```json
{
  "mcpServers": {
    "clerk": {
      "command": "npx",
      "args": ["@clerk/mcp-tools"],
      "env": {
        "CLERK_PUBLISHABLE_KEY": "pk_...",
        "CLERK_SECRET_KEY": "sk_..."
      }
    }
  }
}
```

### Hostinger API MCP 🔴
```yaml
Path: smarteros/mcp/hostinger
Keys required:
  - api_token  # From https://hpanel.hostinger.com/api-tokens
  - endpoint   # https://api.hostinger.com (default)
```

**Config para MCP Client:**
```json
{
  "mcpServers": {
    "hostinger": {
      "command": "hostinger-api-mcp",
      "env": {
        "API_TOKEN": "your_bearer_token",
        "DEBUG": "false"
      }
    }
  }
}
```

**Capabilities (100+ tools):**
- VPS Management: start, stop, reboot, backup
- SSH Keys: create, attach, list
- Firewall: activate, deactivate, list
- Domains: check availability, manage DNS
- Billing: payment methods, auto-renewal

### Cloudflare DNS MCP 🔴
```yaml
Path: smarteros/mcp/cloudflare
Remote MCP: https://dns-analytics.mcp.cloudflare.com/mcp
Keys required:
  - api_token  # With Zone:DNS:Edit permissions
  - email
  - zone_id (optional)
```

**Config para MCP Client:**
```json
{
  "mcpServers": {
    "cloudflare-dns": {
      "command": "npx",
      "args": ["mcp-remote", "https://dns-analytics.mcp.cloudflare.com/mcp"]
    }
  }
}
```

**Autenticación alternativa (API Token):**
```bash
DEV_DISABLE_OAUTH=true
DEV_CLOUDFLARE_API_TOKEN=your_token
DEV_CLOUDFLARE_EMAIL=your_email
```

### Vercel MCP 🔴
```yaml
Path: smarteros/mcp/vercel
Use case: Deploy custom MCP servers as Vercel Functions
Keys required:
  - vercel_token
  - vercel_team_id
  - vercel_project_id
```

**Template:** https://vercel.com/templates/other/model-context-protocol-mcp-with-vercel-functions

---

## 🚀 Quick Start - Configurar MCPs Esenciales

### 1. Instalar paquetes NPM
```bash
npm install -g @clerk/mcp-tools
npm install -g hostinger-api-mcp
npm install -g mcp-remote
```

### 2. Crear archivo de configuración MCP
```bash
mkdir -p ~/.config/mcp
cat > ~/.config/mcp/config.json << 'EOF'
{
  "mcpServers": {
    "github": {
      "url": "http://localhost:3001"
    },
    "hostinger": {
      "command": "hostinger-api-mcp",
      "env": {
        "API_TOKEN": "YOUR_HOSTINGER_TOKEN"
      }
    },
    "cloudflare": {
      "command": "npx",
      "args": ["mcp-remote", "https://dns-analytics.mcp.cloudflare.com/mcp"]
    }
  }
}
EOF
```

### 3. Verificar conexión con MCP Inspector
```bash
npx @modelcontextprotocol/inspector@latest
```

---

## 📊 Resumen de 28 MCP Providers

| Tier | Providers | Configurados | Porcentaje |
|------|-----------|--------------|------------|
| **TIER 1** (Core) | 7 | 1 | 14% |
| **TIER 2** (Business) | 5 | 0 | 0% |
| **TIER 3** (AI/ML) | 4 | 0 | 0% |
| **TIER 4** (Communication) | 4 | 0 | 0% |
| **TIER 5** (DevOps) | 8 | 0 | 0% |
| **TOTAL** | **28** | **1** | **4%** |

---

## 🎯 Prioridades de Configuración

### Inmediato (Esta semana)
1. ✅ **GitHub MCP** - Ya está corriendo
2. 🔧 **Hostinger MCP** - Para gestión VPS/DNS
3. 🔧 **Cloudflare MCP** - Para gestión DNS
4. 🔧 **Vault MCP** - Arreglar health status

### Corto Plazo (Próximas 2 semanas)
5. **Clerk MCP** - Auth management para fulldaygo
6. **Supabase MCP** - Database queries
7. **Docker MCP** - Container management

### Mediano Plazo (Este mes)
8. **Shopify MCP** - E-commerce operations
9. **Slack MCP** - Notifications
10. **N8N MCP** - Workflow automation

---

## 🔧 Scripts de Instalación

### Instalar Hostinger MCP
```bash
#!/bin/bash
npm install -g hostinger-api-mcp

# Verificar instalación
which hostinger-api-mcp

# Crear config
cat > ~/.hostinger-mcp.env << EOF
API_TOKEN=your_token_here
DEBUG=false
EOF

echo "✓ Hostinger MCP installed"
```

### Instalar Cloudflare MCP (Remote)
```bash
#!/bin/bash
npm install -g mcp-remote

# Test connection
npx @modelcontextprotocol/inspector@latest \
  --url https://dns-analytics.mcp.cloudflare.com/mcp

echo "✓ Cloudflare MCP configured"
```

---

## 📚 Documentación de Referencia

- **MCP Index**: `/root/specs/mcp/index.yml`
- **MCP Structure**: `/root/specs/MCP-STRUCTURE.md`
- **Vault Policies**: `/root/specs/vault/policies/`
- **Hostinger Spec**: `/root/specs/mcp/hostinger.yml`
- **Cloudflare Spec**: `/root/specs/mcp/cloudflare-dns.yml`
- **Vercel Spec**: `/root/specs/mcp/vercel.yml`

---

## 🐛 Troubleshooting

### Vault MCP Unhealthy
```bash
# Check logs
docker logs smarteros-vault-mcp --tail 50

# Restart container
docker restart smarteros-vault-mcp

# Verify health
curl http://localhost:8081/health
```

### GitHub MCP Connection Issues
```bash
# Check if running
docker ps | grep mcp-github

# Test endpoint
curl http://localhost:3001/health

# View logs
docker logs mcp-github-proxy --tail 50
```

### NPM Package Not Found
```bash
# Update NPM
npm install -g npm@latest

# Clear cache
npm cache clean --force

# Reinstall package
npm install -g <package-name>
```

---

## 🔄 Próximos Pasos

1. **Instalar paquetes NPM esenciales** (5 min)
   ```bash
   npm install -g hostinger-api-mcp @clerk/mcp-tools mcp-remote
   ```

2. **Obtener API tokens** (15 min)
   - Hostinger: https://hpanel.hostinger.com/api-tokens
   - Cloudflare: Dashboard → API Tokens → Create Token

3. **Configurar MCP client** (10 min)
   - Crear `~/.config/mcp/config.json`
   - Agregar tokens desde Vault o .env files

4. **Probar conexiones** (10 min)
   ```bash
   npx @modelcontextprotocol/inspector@latest
   ```

5. **Configurar Vault policies** (20 min)
   - Aplicar policies desde `/root/specs/vault/policies/`
   - Reiniciar Vault MCP server

---

**Total MCPs Disponibles**: 28  
**MCPs Configurados**: 1 (GitHub)  
**MCPs a Configurar**: 27  
**Prioridad**: Hostinger, Cloudflare, Clerk, Supabase

---

*Generado por GitHub Copilot CLI*  
*Basado en specs/mcp/index.yml*
