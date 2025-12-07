# ⚙️ Instalación de SmarterOS

Guía oficial para instalar SmarterOS en un VPS Hostinger o cualquier servidor Linux con Docker.

---

## 🔧 Requisitos

### Hardware mínimo
- 2 vCPU
- 4 GB RAM
- 60 GB SSD
- IPv4 dedicado

### Software
- Ubuntu 22.04 o 24.04
- Docker 25+
- Docker Compose v2.20+
- Git
- Caddy o Traefik
- Dominio configurado en Cloudflare

---

## 📦 Instalación Rápida (VPS)

```bash
# 1. Actualizar sistema
apt update && apt upgrade -y

# 2. Instalar dependencias
apt install -y git curl unzip ufw

# 3. Instalar Docker
curl -fsSL https://get.docker.com | sh

# 4. Instalar Docker Compose
curl -SL https://github.com/docker/compose/releases/latest/download/docker-compose-linux-x86_64 -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

# 5. Clonar repos SmarterOS
cd /root
git clone https://github.com/SmarterCL/smarteros-specs smarteros

# 6. Estructura base
mkdir -p /root/smarteros/{erp,crm,portal,marketing,api,n8n,botpress,metabase}
```

---

## 🧩 Servicios Esenciales

Cada servicio se inicia con su propio `docker-compose.yml`:

| Servicio | Ubicación |
|----------|-----------|
| Odoo ERP | `/root/odoo-smarter` |
| API Gateway | `/root/api-gateway-clerk` |
| CRM (Chatwoot) | `/root/chatwoot` |
| Automatizaciones (n8n) | `/root/n8n` |
| Bot IA (Botpress) | `/root/botpress` |
| KPI (Metabase) | `/root/metabase` |

Iniciar cada servicio:

```bash
cd /root/odoo-smarter
docker compose up -d
```

---

## 🔐 Configuración SSO (Clerk)

```bash
export CLERK_PUBLISHABLE_KEY="pk_live_..."
export CLERK_SECRET_KEY="sk_live_..."
```

---

## 🛡️ Firewall Recomendado

```bash
ufw allow ssh
ufw allow http
ufw allow https
ufw enable
```

---

## 🚨 Verificación Final

```bash
docker ps
curl https://api.smarterbot.cl/health
curl https://odoo.smarterbot.cl/web/login
```

**Sistema listo.** ✅

---

## 📚 Siguiente Paso

Ver [DEPLOYMENT.md](./DEPLOYMENT.md) para desplegar en producción.
