# SmarterOS VPS Deployment Guide

## 🎯 Orden de Despliegue

```
1. Redpanda (Event Streaming)    ← Base del sistema
2. Vault (Secrets Management)    ← Seguridad
3. Observability (Monitoring)    ← Visibilidad
4. Demo Environment              ← Ventas
5. MCP Server (Auto-generated)   ← Inteligencia
```

## 📋 Pre-requisitos

### Servidor VPS
- **IP**: smarterbot.cl (Hostinger)
- **OS**: Ubuntu 22.04 LTS
- **RAM**: 8GB mínimo (16GB recomendado)
- **Storage**: 100GB SSD
- **Docker**: 24.0+
- **Docker Compose**: 2.20+

### DNS Configurado (Cloudflare)
- `vault.smarterbot.cl` → VPS IP
- `kafka.smarterbot.cl` → VPS IP
- `redpanda.smarterbot.cl` → VPS IP
- `schema.smarterbot.cl` → VPS IP
- `sentry.smarterbot.cl` → VPS IP
- `grafana.smarterbot.cl` → VPS IP
- `otel.smarterbot.cl` → VPS IP
- `demo.smarterbot.cl` → VPS IP

### Traefik Configurado
- Let's Encrypt certificados automáticos
- Network: `smarteros_network` creado
- Middleware: rate limiting, basic auth

---

## 🚀 Fase 1: Redpanda (Event Streaming)

### 1.1 Desplegar Redpanda Cluster

```bash
# SSH al VPS
ssh root@smarterbot.cl

# Clonar repos (si no existen)
cd /opt
git clone https://github.com/SmarterCL/SmarterOS.git
cd SmarterOS
git submodule update --init --recursive

# Ir a dkcompose
cd dkcompose

# Levantar Redpanda
docker-compose -f redpanda.yml up -d

# Verificar logs
docker logs -f smarter-redpanda

# Esperar mensaje: "✅ Broker is healthy"
```

### 1.2 Inicializar Topics

```bash
# El init container crea automáticamente los topics
docker logs -f smarter-redpanda-init

# Deberías ver:
# ✅ Created: smarteros.events
# ✅ Created: shopify.webhooks
# ... (20 topics)
```

### 1.3 Verificar Redpanda

```bash
# Listar topics
docker exec smarter-redpanda rpk topic list

# Cluster info
docker exec smarter-redpanda rpk cluster info

# Health check
docker exec smarter-redpanda rpk cluster health

# Acceder Console (navegador)
open https://redpanda.smarterbot.cl
# Login: admin / smarteros (cambiar en producción)
```

### 1.4 Test de Producción/Consumo

```bash
# Producir mensaje de prueba
docker exec smarter-redpanda rpk topic produce smarteros.events

# Escribir (presionar Enter):
{"event": "test", "timestamp": "2025-01-01T00:00:00Z"}

# Ctrl+C para salir

# Consumir
docker exec smarter-redpanda rpk topic consume smarteros.events

# Deberías ver el mensaje que enviaste
# Ctrl+C para salir
```

---

## 🔐 Fase 2: Vault (Secrets Management)

### 2.1 Desplegar Vault

```bash
cd /opt/SmarterOS/dkcompose

# Levantar Vault
docker-compose -f vault.yml up -d

# Verificar logs
docker logs -f smarter-vault
```

### 2.2 Inicializar Vault

```bash
# Ejecutar script de inicialización
docker exec smarter-vault /vault-init.sh

# ⚠️ MUY IMPORTANTE: GUARDAR ESTE OUTPUT
# Se mostrarán 5 Unseal Keys y 1 Root Token
# Ejemplo:
# Unseal Key 1: xxxxx
# Unseal Key 2: xxxxx
# Unseal Key 3: xxxxx
# Unseal Key 4: xxxxx
# Unseal Key 5: xxxxx
# Initial Root Token: xxxxx

# COPIAR Y GUARDAR EN:
# - LastPass/Bitwarden
# - O archivo local seguro: /root/.vault-keys.txt (con chmod 600)
```

### 2.3 Unseal Vault

```bash
# Vault arranca "sealed", necesita 3 de 5 keys

# Key 1
docker exec -it smarter-vault vault operator unseal
# Pegar Unseal Key 1

# Key 2
docker exec -it smarter-vault vault operator unseal
# Pegar Unseal Key 2

# Key 3
docker exec -it smarter-vault vault operator unseal
# Pegar Unseal Key 3

# Verificar status
docker exec smarter-vault vault status
# Debería mostrar: Sealed: false
```

### 2.4 Habilitar Transit Engine

```bash
# Login con Root Token
docker exec -it smarter-vault vault login
# Pegar Root Token

# Habilitar Transit
docker exec smarter-vault vault secrets enable transit

# Crear encryption key
docker exec smarter-vault vault write -f transit/keys/smarteros-secrets

# Verificar
docker exec smarter-vault vault list transit/keys
```

### 2.5 Crear Políticas para MCP

```bash
# Copiar política al contenedor
docker cp /opt/SmarterOS/smarteros-specs/vault/policies/mcp-transit-encryption.hcl \
  smarter-vault:/tmp/mcp-policy.hcl

# Aplicar política
docker exec smarter-vault vault policy write mcp-transit-encryption \
  /tmp/mcp-policy.hcl

# Crear token para MCP server
docker exec smarter-vault vault token create \
  -policy=mcp-transit-encryption \
  -period=24h \
  -display-name="smarteros-mcp-server"

# ⚠️ GUARDAR ESTE TOKEN
# Lo necesitarás para el MCP server
```

### 2.6 Guardar Credenciales en Vault

```bash
# Ejemplo: Guardar Shopify API key
docker exec -it smarter-vault vault login  # usar Root Token

# Encriptar secret
docker exec smarter-vault vault write transit/encrypt/smarteros-secrets \
  plaintext=$(echo -n "shpat_XXXXXXX" | base64)

# Output: ciphertext: vault:v1:XXXXXXX

# Guardar en KV
docker exec smarter-vault vault kv put smarteros/shopify/api-key \
  encrypted="vault:v1:XXXXXXX"
```

---

## 📊 Fase 3: Observability Stack

### 3.1 Preparar Variables de Entorno

```bash
# Generar Sentry secret key
export SENTRY_SECRET_KEY=$(openssl rand -hex 32)

# Generar Grafana password
export GRAFANA_PASSWORD=$(openssl rand -base64 16)

# Guardar en archivo .env
cat > /opt/SmarterOS/dkcompose/.env.observability <<EOF
SENTRY_SECRET_KEY=${SENTRY_SECRET_KEY}
GRAFANA_PASSWORD=${GRAFANA_PASSWORD}
SENTRY_DSN=  # Se obtiene después de crear proyecto en Sentry
EOF

# ⚠️ GUARDAR ESTAS CREDENCIALES
echo "Sentry Secret: ${SENTRY_SECRET_KEY}" >> /root/.smarteros-secrets.txt
echo "Grafana Pass: ${GRAFANA_PASSWORD}" >> /root/.smarteros-secrets.txt
chmod 600 /root/.smarteros-secrets.txt
```

### 3.2 Desplegar Observability

```bash
cd /opt/SmarterOS/dkcompose

# Levantar stack
docker-compose -f observability.yml --env-file .env.observability up -d

# Verificar servicios
docker-compose -f observability.yml ps

# Logs
docker logs -f sentry
docker logs -f otel-collector
docker logs -f grafana
```

### 3.3 Configurar Sentry

```bash
# Acceder a Sentry
open https://sentry.smarterbot.cl

# First-time setup:
# 1. Crear superuser:
docker exec -it sentry sentry createuser \
  --email admin@smarterbot.cl \
  --password $(openssl rand -base64 16) \
  --superuser

# 2. Crear organización: "SmarterCL"
# 3. Crear proyecto: "SmarterOS"
# 4. Copiar DSN (Project Settings → Client Keys)
# 5. Actualizar .env.observability con SENTRY_DSN
# 6. Reiniciar stack:
docker-compose -f observability.yml --env-file .env.observability restart
```

### 3.4 Configurar Grafana

```bash
# Acceder a Grafana
open https://grafana.smarterbot.cl

# Login: admin / ${GRAFANA_PASSWORD}

# Los datasources ya están configurados vía grafana-datasources.yaml:
# - ClickHouse (traces, metrics, logs)
# - Prometheus (métricas de contenedores)

# Importar dashboards:
# 1. + → Import Dashboard
# 2. Buscar "ClickHouse" / "MCP Telemetry" / "Redpanda"
# 3. Seleccionar datasource: ClickHouse
```

---

## 🎪 Fase 4: Demo Environment

### 4.1 Desplegar Demo

```bash
cd /opt/SmarterOS/dkcompose

# Levantar demo
docker-compose -f demo.yml up -d

# Verificar seeding
docker logs -f demo-seeder

# Debería mostrar:
# ✅ Inserted 15 products
# ✅ Inserted 10 orders
# ✅ Inserted 20 conversations
```

### 4.2 Verificar Base de Datos

```bash
# Conectar a demo-postgres
docker exec -it demo-postgres psql -U demo_user -d demo_db

# Verificar datos
SELECT COUNT(*) FROM products;  -- Debería ser 15
SELECT COUNT(*) FROM orders;    -- Debería ser 10
SELECT * FROM products LIMIT 3;

# Ver productos chilenos ficticios
SELECT name, price_clp, category FROM products;

# Salir
\q
```

### 4.3 Configurar Clerk para Demo

```bash
# 1. Crear nueva aplicación en Clerk Dashboard
# 2. Nombre: "SmarterOS Demo"
# 3. Configurar dominio: demo.smarterbot.cl
# 4. Obtener keys:
#    - NEXT_PUBLIC_CLERK_PUBLISHABLE_KEY
#    - CLERK_SECRET_KEY

# 5. Guardar en Vault
docker exec -it smarter-vault vault login  # Root Token

docker exec smarter-vault vault kv put smarteros/demo/clerk \
  publishable_key="pk_test_XXXXXXX" \
  secret_key="sk_test_XXXXXXX"
```

### 4.4 Deploy Demo App

```bash
# En tu máquina local (no VPS)
cd /opt/SmarterOS/app.smarterbot.cl

# Crear nuevo proyecto Vercel para demo
vercel --name smarteros-demo

# Configurar variables en Vercel:
vercel env add NEXT_PUBLIC_CLERK_PUBLISHABLE_KEY
# Pegar pk_test_XXXXXXX

vercel env add CLERK_SECRET_KEY
# Pegar sk_test_XXXXXXX

vercel env add DATABASE_URL
# Pegar: postgresql://demo_user:demo_pass@smarterbot.cl:5433/demo_db

# Deploy
vercel --prod

# Configurar dominio custom: demo.smarterbot.cl
```

---

## 🤖 Fase 5: SmarterOS MCP Server

### 5.1 Build en Local

```bash
# En tu máquina local
cd /opt/SmarterOS/smarteros-specs

# Instalar herramientas
make install-tools

# Generar código protobuf + MCP
make generate

# Esto crea:
# - gen/go/smarteros/v1/*.pb.go (protobuf)
# - gen/go/smarteros/v1/*_grpc.pb.go (gRPC)
# - gen/go/smarteros/v1/smarterosv1mcp/*.pb.mcp.go (MCP tools)

# Build binary
make build

# Resultado: bin/smarteros-mcp-server
```

### 5.2 Deploy al VPS

```bash
# Copiar binary
scp bin/smarteros-mcp-server root@smarterbot.cl:/usr/local/bin/

# O usar make:
make deploy-vps
```

### 5.3 Crear Systemd Service

```bash
# En el VPS
ssh root@smarterbot.cl

# Crear service file
cat > /etc/systemd/system/smarteros-mcp-server.service <<'EOF'
[Unit]
Description=SmarterOS MCP Server (Auto-generated from Protobuf)
After=network.target docker.service
Requires=docker.service

[Service]
Type=simple
User=root
WorkingDirectory=/opt/SmarterOS
ExecStart=/usr/local/bin/smarteros-mcp-server

# Environment variables
Environment="LLM_PROVIDER=openai"
Environment="VAULT_ADDR=http://vault.smarterbot.cl:8200"
Environment="VAULT_TOKEN=s.XXXXXXX"  # Token de Paso 2.5
Environment="REDPANDA_BROKERS=kafka.smarterbot.cl:19092"
Environment="SUPABASE_URL=https://api.smarterbot.cl"
Environment="SENTRY_DSN=https://XXXX@sentry.smarterbot.cl/1"

# Restart policy
Restart=on-failure
RestartSec=10s

# Logging
StandardOutput=journal
StandardError=journal
SyslogIdentifier=smarteros-mcp

[Install]
WantedBy=multi-user.target
EOF

# Recargar systemd
systemctl daemon-reload

# Habilitar inicio automático
systemctl enable smarteros-mcp-server

# Iniciar servicio
systemctl start smarteros-mcp-server

# Verificar status
systemctl status smarteros-mcp-server

# Ver logs
journalctl -u smarteros-mcp-server -f
```

### 5.4 Configurar Claude Desktop

```bash
# En tu máquina local (Mac)

# Generar config
cd /opt/SmarterOS/smarteros-specs
make claude-config

# Copiar a Claude Desktop config location
mkdir -p ~/Library/Application\ Support/Claude/
cp claude-mcp-config.json ~/Library/Application\ Support/Claude/claude_desktop_config.json

# O agregar manualmente a tu config existente:
{
  "mcpServers": {
    "smarteros": {
      "command": "ssh",
      "args": [
        "root@smarterbot.cl",
        "/usr/local/bin/smarteros-mcp-server"
      ],
      "env": {}
    }
  }
}

# Reiniciar Claude Desktop
```

---

## ✅ Verificación Final

### 1. Redpanda Health

```bash
docker exec smarter-redpanda rpk cluster health
# Output esperado: Healthy: true
```

### 2. Vault Status

```bash
docker exec smarter-vault vault status
# Output esperado: Sealed: false
```

### 3. Topics Created

```bash
docker exec smarter-redpanda rpk topic list | wc -l
# Output esperado: 20 (o más)
```

### 4. Observability Stack

```bash
curl -f https://grafana.smarterbot.cl/api/health
curl -f https://sentry.smarterbot.cl/api/0/
```

### 5. Demo Environment

```bash
docker exec demo-postgres psql -U demo_user -d demo_db -c "SELECT COUNT(*) FROM products;"
# Output esperado: 15
```

### 6. MCP Server

```bash
# Verificar que está corriendo
systemctl is-active smarteros-mcp-server
# Output: active

# Test de herramientas (en Claude Desktop)
# Escribir: "Lista los tools disponibles de SmarterOS"
# Debería mostrar 23 tools
```

---

## 🔥 Smoke Test Completo

```bash
# 1. Producir evento a Redpanda
docker exec smarter-redpanda rpk topic produce smarteros.events << EOF
{"tenant_id":"test-tenant","event":"system.health_check","timestamp":"$(date -Iseconds)"}
EOF

# 2. Consumir desde otro terminal
docker exec smarter-redpanda rpk topic consume smarteros.events

# 3. Verificar telemetría en Grafana
open https://grafana.smarterbot.cl
# Dashboard: "SmarterOS Events Flow"
# Debería mostrar el evento

# 4. Test MCP tool desde Claude
# Prompt: "Ejecuta el tool smarteros_v1_TenantService_GetTenant con tenant_id=test-tenant"
# Debería responder (aunque sea error porque no existe)

# 5. Verificar logs de todo
docker-compose -f /opt/SmarterOS/dkcompose/redpanda.yml logs --tail=50
docker-compose -f /opt/SmarterOS/dkcompose/vault.yml logs --tail=50
docker-compose -f /opt/SmarterOS/dkcompose/observability.yml logs --tail=50
journalctl -u smarteros-mcp-server --since "5 minutes ago"
```

---

## 📊 Métricas de Éxito

✅ Redpanda: 20 topics creados, cluster healthy
✅ Vault: Transit engine activo, políticas configuradas
✅ Observability: Grafana + Sentry recibiendo datos
✅ Demo: 15 productos + RLS funcionando
✅ MCP Server: 23 tools disponibles en Claude Desktop
✅ E2E: Evento → Redpanda → OTEL → ClickHouse → Grafana

---

## 🆘 Troubleshooting

### Redpanda no arranca
```bash
# Verificar puertos
netstat -tlnp | grep -E '9092|19092|18082'

# Limpiar data (⚠️ borra todo)
docker-compose -f redpanda.yml down -v
docker-compose -f redpanda.yml up -d
```

### Vault sealed después de restart
```bash
# Unseal con 3 keys (como en Paso 2.3)
docker exec -it smarter-vault vault operator unseal
# Repetir 3 veces con 3 keys diferentes
```

### MCP Server no conecta a Redpanda
```bash
# Verificar conectividad
telnet kafka.smarterbot.cl 19092

# Verificar DNS
dig kafka.smarterbot.cl

# Verificar logs
journalctl -u smarteros-mcp-server -n 100
```

### Grafana sin datos
```bash
# Verificar OTEL Collector
docker logs otel-collector

# Verificar ClickHouse
docker exec clickhouse clickhouse-client --query "SELECT count() FROM otel.otel_traces"

# Restart observability stack
docker-compose -f observability.yml restart
```

---

## 🎉 ¡Deployment Completo!

Ahora tienes:
- ✅ **Redpanda**: Event streaming con 20 topics
- ✅ **Vault**: Secrets encriptados con Transit
- ✅ **Observability**: Sentry + OTEL + Grafana + ClickHouse
- ✅ **Demo**: Ambiente aislado con datos fake
- ✅ **MCP Server**: 23 tools auto-generated disponibles en Claude

**Score Final: 10/10** 🚀

Next: Implementar la lógica de negocio en cada RPC method para conectar todo.
