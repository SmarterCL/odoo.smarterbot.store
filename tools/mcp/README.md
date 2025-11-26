## 🔌 MCP Registry - SmarterOS

**URL**: https://mcp.smarterbot.cl  
**Actualizado**: 2025-11-19  
**Total MCPs**: 28  
**GitHub MCP**: ✅ Implementado con 18 herramientas  
**Security Posture**: ✅ Nuevo módulo de seguridad

---

## 📊 Estado Actual

| Métrica | Valor | Descripción |
|---------|-------|-------------|
| **Total MCPs** | 28 | Proveedores disponibles |
| **Instalados** | 7 | Paquetes NPM instalados |
| **Activos** | 2 | Servidores corriendo |
| **Tier 1 (Core)** | 7 | Infraestructura esencial |
| **GitHub Tools** | 18 | Herramientas disponibles |
| **Security Posture** | NEW | Monitoreo de seguridad |

---

## 🎯 MCPs Instalados con pnpm

### Core Tools
```bash
✓ @modelcontextprotocol/inspector@0.17.2
✓ mcp-remote@0.1.31
```

### MCP Servers
```bash
✓ hostinger-api-mcp@0.1.18
✓ @clerk/mcp-tools@0.3.1
✓ @upstash/context7-mcp@1.0.29
✓ @playwright/mcp@0.0.47
✓ chrome-devtools-mcp@0.10.2
✓ mcp-handler@1.0.3
✓ mcp-proxy@5.11.0
```

---

## 🛡️ Security Posture Findings - NUEVO

### Monitoreo de Seguridad para MCPs

Nueva sección dedicada para revisar y gestionar problemas de seguridad en configuraciones de aplicaciones SaaS y entornos en la nube.

#### Características

✅ **Dashboard de Hallazgos**
- 3 categorías: SaaS, Nube, Hallazgos Corregidos
- Contadores en tiempo real
- Visualización clara con iconos

✅ **Sistema de Tabs**
- Tab SaaS (integraciones SaaS)
- Tab Nube (infraestructura cloud)
- Tab Corregidos (historial)

✅ **Filtros Avanzados**
- Estado (Activos/Resueltos)
- Gravedad (Crítico/Alto/Medio/Bajo)
- Integración (GitHub/Vault/Cloudflare/etc)
- Rango de fechas
- Panel colapsable

✅ **Tabla Responsive**
- Selección múltiple
- Badges de gravedad con código de colores
- Menú contextual
- Estado vacío amigable

#### Integraciones Soportadas

**SaaS Providers**:
- ✅ GitHub - Repository settings, OAuth apps, secrets
- ✅ Vault - Policies, auth methods, secrets management
- ✅ Cloudflare - DNS, Firewall, SSL/TLS
- ✅ Hostinger - VPS, SSH keys, firewall
- ⏳ Slack, Stripe (próximamente)

**Cloud Providers**:
- ⏳ AWS, GCP, Azure (próximamente)

#### Casos de Uso

1. **Auditoría Semanal**: Revisar hallazgos críticos y altos
2. **Monitoreo GitHub**: Verificar OAuth scopes y secrets
3. **Compliance**: Preparar auditorías con reportes

#### Badges de Gravedad

- 🔴 **Crítico**: Problemas que requieren acción inmediata
- 🟠 **Alto**: Vulnerabilidades importantes
- 🟡 **Medio**: Problemas que deben resolverse pronto
- 🟢 **Bajo**: Mejoras recomendadas

Ver documentación completa: `/root/SECURITY-POSTURE-IMPLEMENTATION.md`

---

## ✨ GitHub MCP - Implementación Completa

### 18 Herramientas Disponibles

#### 📁 Repository Management (6 tools)
- `get_file_contents` - Leer archivos y directorios
- `list_commits` - Listar commits con filtros
- `get_commit` - Detalles de commit con diffs
- `list_branches` - Listar ramas
- `search_repositories` - Buscar repositorios
- `search_code` - Búsqueda de código

#### 🐛 Issues Management (3 tools)
- `list_issues` - Listar issues con filtros
- `issue_read` - Detalles de issue y comentarios
- `search_issues` - Buscar issues

#### 🔀 Pull Requests (3 tools)
- `list_pull_requests` - Listar PRs
- `pull_request_read` - Detalles de PR con diffs
- `search_pull_requests` - Buscar PRs

#### ⚙️ Workflows & CI/CD (4 tools)
- `list_workflows` - Listar workflows
- `list_workflow_runs` - Listar ejecuciones
- `get_workflow_run` - Detalles de ejecución
- `get_job_logs` - Logs de jobs (optimizado para fallos)

#### 🔍 Search & Discovery (2 tools)
- `search_users` - Buscar usuarios
- `web_search` - Búsqueda web con IA

### Características

✅ **OAuth Support** - Autenticación vía GitHub OAuth  
✅ **PAT Support** - Personal Access Tokens  
✅ **Enterprise** - GitHub Enterprise Server & Cloud  
✅ **Remote Server** - api.githubcopilot.com/mcp/  
✅ **Docker** - ghcr.io/github/github-mcp-server  
✅ **Proxy** - SSE proxy para stdio  
✅ **Toolsets** - default, read_only, ci_cd, full  

### Instalación

#### Opción 1: Remote Server (OAuth)
```json
{
  "servers": {
    "github": {
      "type": "http",
      "url": "https://api.githubcopilot.com/mcp/"
    }
  }
}
```

#### Opción 2: Docker Local (PAT)
```bash
docker run -i --rm \
  -e GITHUB_PERSONAL_ACCESS_TOKEN="ghp_xxx" \
  ghcr.io/github/github-mcp-server
```

#### Opción 3: Con Proxy SSE
```bash
# En SmarterOS
docker run -d -p 3001:3001 \
  -e STDIO_COMMAND="docker run -i --rm -e GITHUB_PERSONAL_ACCESS_TOKEN ghcr.io/github/github-mcp-server" \
  --name mcp-github-proxy \
  mcp-proxy
```

### Uso por Agentes

#### Executor Codex (Primary)
- ✅ Repository analysis
- ✅ CI/CD monitoring
- ✅ Code search
- ✅ Build log analysis

#### Director Gemini
- ✅ Project analytics
- ✅ Team activity
- ✅ Issue trends
- ✅ Repository recommendations

#### Writer Copilot
- ✅ Documentation research
- ✅ Code examples
- ✅ README generation

---

## 🏗️ Arquitectura

```
mcp.smarterbot.cl/
├── index.html          # UI principal del registry
├── app.js              # Lógica y datos de MCPs
├── package.json        # Dependencias
└── README.md           # Esta documentación
```

### Datos de MCPs

Los datos de todos los MCPs están en `app.js` como array `mcpData[]` con:

```javascript
{
  id: 'github',
  name: 'GitHub MCP',
  tier: 1,
  category: 'core',
  status: 'active',
  description: '...',
  installed: true,
  endpoint: 'http://localhost:3001',
  npmPackage: '@modelcontextprotocol/server-github',
  agents: ['gemini', 'copilot', 'codex'],
  tools: ['repos', 'issues', 'pull_requests'],
  vaultPath: 'smarteros/mcp/github',
  docs: '/specs/mcp/github.yml'
}
```

---

## 🚀 Despliegue

### Opción 1: Static Site (Caddy/Nginx)

```bash
# Copiar archivos al web root
cp -r /root/mcp-smarterbot/* /var/www/mcp.smarterbot.cl/

# Configurar Caddy
cat >> /etc/caddy/Caddyfile << 'EOF'
mcp.smarterbot.cl {
  root * /var/www/mcp.smarterbot.cl
  file_server
  encode gzip
  
  header {
    X-Frame-Options "SAMEORIGIN"
    X-Content-Type-Options "nosniff"
  }
}
EOF

caddy reload
```

### Opción 2: Vercel

```bash
cd /root/mcp-smarterbot

# Crear vercel.json
cat > vercel.json << 'EOF'
{
  "version": 2,
  "builds": [
    {
      "src": "index.html",
      "use": "@vercel/static"
    }
  ],
  "routes": [
    {
      "src": "/(.*)",
      "dest": "/$1"
    }
  ]
}
EOF

# Deploy
vercel --prod
```

### Opción 3: Docker + Nginx

```dockerfile
FROM nginx:alpine
COPY . /usr/share/nginx/html
EXPOSE 80
```

```bash
docker build -t mcp-registry .
docker run -d -p 3010:80 --name mcp-registry mcp-registry
```

---

## 📝 Mantenimiento

### Actualizar MCPs en el Registry

1. **Editar `app.js`** - Agregar/modificar objetos en `mcpData[]`
2. **Actualizar stats** - Se calculan automáticamente
3. **Reload página** - Los cambios se reflejan inmediatamente

### Agregar Nuevo MCP

```javascript
// En app.js, agregar al array mcpData:
{
  id: 'nuevo-mcp',
  name: 'Nuevo MCP',
  tier: 2,
  category: 'business',
  status: 'pending',
  description: 'Descripción del nuevo MCP',
  installed: false,
  npmPackage: 'nuevo-mcp-package',
  agents: ['gemini'],
  tools: ['tool1', 'tool2'],
  vaultPath: 'smarteros/mcp/nuevo-mcp',
  docs: '/specs/mcp/nuevo-mcp.yml'
}
```

### Instalar Nuevo MCP

```bash
export PNPM_HOME="/root/.local/share/pnpm"
export PATH="$PNPM_HOME:$PATH"

pnpm add -g <npm-package-name>
```

---

## 🎨 Features del Registry

### Búsqueda
- **Texto completo**: Busca en nombres, descripciones y tools
- **Real-time**: Resultados instantáneos

### Filtros
- **All**: Todos los MCPs
- **Tier 1-5**: Filtrar por tier
- **Active Only**: Solo MCPs activos

### Detalles de MCP
- **Click en card**: Abre modal con información completa
- **Incluye**: Config examples, installation, tools list

### Stats Dashboard
- **Total MCPs**: Contador total
- **Active**: MCPs corriendo
- **Installed**: Paquetes NPM instalados
- **Tier 1**: MCPs core

---

## 📚 Documentación de Specs

Cada MCP tiene su archivo de spec en `/root/specs/mcp/`:

```
/root/specs/mcp/
├── index.yml              # Índice maestro de 28 MCPs
├── clerk.yml              # Spec de Clerk MCP
├── hostinger.yml          # Spec de Hostinger MCP
├── cloudflare-dns.yml     # Spec de Cloudflare MCP
├── vercel.yml             # Spec de Vercel MCP
└── ...                    # Otros specs
```

### Formato de Spec

```yaml
provider: "nombre"
category: "core|business|ai|communication|devops"
tier: 1-5
status: "active|pending|inactive"

mcp_server:
  name: "nombre-mcp"
  repository: "https://github.com/..."
  npm_package: "nombre-package"
  version: "latest"

auth:
  method: "bearer-token|oauth|api-key"
  vault_path: "smarteros/mcp/nombre"
  secrets:
    - name: "api_token"
      required: true

capabilities:
  - tool_name: "Descripción"

agent_usage:
  executor-codex:
    primary: true
    use_cases:
      - "Caso de uso 1"
```

---

## 🔗 Integración con Agentes

### Director Gemini
- **Access**: 18 MCPs
- **Primary**: Business logic, AI/ML, Communication
- **Use cases**: Analytics, optimizations, recommendations

### Writer Copilot
- **Access**: 6 MCPs
- **Primary**: Documentation, content
- **Use cases**: Docs generation, context gathering

### Executor Codex
- **Access**: 12 MCPs
- **Primary**: Infrastructure, DevOps
- **Use cases**: Deployments, VPS management, automation

---

## 🔐 Seguridad

### Vault Integration
- **Path**: `smarteros/mcp/<provider>`
- **Policies**: Individual per provider
- **Rotation**: Automatic 90 days

### API Tokens
- **Storage**: Vault only (never in git)
- **Access**: Least privilege per agent
- **Audit**: All reads/writes logged

---

## 📊 Monitoring

### Health Checks
```bash
# GitHub MCP
curl http://localhost:3001/health

# Vault MCP
curl http://localhost:8081/health
```

### Logs
```bash
# Docker containers
docker logs mcp-github-proxy
docker logs smarteros-vault-mcp

# NPM global packages
pnpm list -g --depth=0
```

---

## 🛠️ Troubleshooting

### MCP no se muestra en registry
1. Verificar que está en `mcpData[]` en `app.js`
2. Verificar sintaxis del objeto
3. Reload página (Ctrl+F5)

### MCP instalado pero no funciona
1. Verificar con `pnpm list -g <package>`
2. Verificar PATH incluye `$PNPM_HOME`
3. Verificar secrets en Vault

### Sitio no carga
1. Verificar archivos en web root
2. Verificar config de Caddy/Nginx
3. Verificar logs: `journalctl -u caddy -f`

---

## 🔄 Roadmap

### Fase 1 (Completado)
- ✅ Instalación de pnpm
- ✅ Instalación de MCPs core
- ✅ Creación de registry web
- ✅ Documentación en specs

### Fase 2 (Esta semana)
- [ ] Deploy a mcp.smarterbot.cl
- [ ] Configurar secrets en Vault
- [ ] Activar Hostinger MCP
- [ ] Activar Cloudflare MCP

### Fase 3 (Próximas 2 semanas)
- [ ] Activar Clerk MCP
- [ ] Activar Supabase MCP
- [ ] API para registry (REST)
- [ ] Auto-discovery de MCPs instalados

### Fase 4 (Este mes)
- [ ] Dashboard de monitoreo
- [ ] Health checks automáticos
- [ ] Alertas Slack
- [ ] Metrics con Metabase

---

## 📞 Soporte

**Documentación**: `/root/specs/mcp/`  
**Issues**: GitHub Issues en smarteros-specs  
**Slack**: #mcp-support (cuando se active Slack MCP)

---

**Mantenido por**: SmarterOS Team  
**Licencia**: Privado - SmarterOS  
**Versión**: 1.0.0
