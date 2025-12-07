# 🚀 SmarterOS MCP Server

**Model Context Protocol Server** para la plataforma SmarterOS.

## 📋 Descripción

Servidor MCP que expone agentes AI (como Bolt) como herramientas consumibles por otros servicios del ecosistema SmarterOS.

## 🏗️ Arquitectura

```
mcp-server/
├── app/
│   └── main.py           # FastAPI application
├── agents/
│   └── bolt.py           # Bolt AI agent
├── integrations/
│   ├── shopify.py        # Shopify integration
│   ├── odoo.py           # Odoo integration
│   ├── chatwoot.py       # Chatwoot integration
│   └── n8n.py            # n8n integration
├── utils/
│   ├── vault.py          # Vault client
│   ├── supabase.py       # Supabase client
│   └── rut.py            # Chilean RUT validator
├── config/
│   └── logging.yaml      # Logging configuration
├── Dockerfile
└── requirements.txt
```

## 🔧 Instalación

### Con Docker Compose

```bash
# 1. Configurar variables de entorno
cp .env.example .env
nano .env

# 2. Levantar el servidor
docker compose -f docker-compose-mcp-server.yml up -d

# 3. Verificar health
curl http://localhost:8080/health
```

### Desarrollo Local

```bash
# 1. Crear virtual environment
python3 -m venv venv
source venv/bin/activate

# 2. Instalar dependencias
pip install -r requirements.txt

# 3. Configurar variables
export OPENAI_API_KEY="your-key"
export VAULT_ADDR="http://localhost:8200"

# 4. Ejecutar servidor
uvicorn app.main:app --reload --port 8080
```

## 📡 Endpoints

### Core MCP

- `GET /` - API info
- `GET /health` - Health check
- `GET /tools` - List available tools
- `GET /agents` - List registered agents
- `POST /client/handshake` - Client registration
- `POST /tools/{tool_name}/invoke` - Invoke tool

### Tenant Management

- `POST /tenant/rut/validate` - Validate and create tenant
- `GET /vault/tenant/{rut}/credentials` - Get tenant credentials

### Integrations

- `GET /integrations/shopify/auth` - Start Shopify OAuth
- `POST /webhooks/shopify/orders` - Shopify order webhook
- `POST /integrations/n8n/workflow/trigger` - Trigger n8n workflow

## 🤖 Bolt Agent Tools

### 1. `bolt.writer`

Generate AI-powered documentation.

**Request:**
```json
{
  "tool": "bolt.writer",
  "parameters": {
    "doc_type": "api",
    "specs": {...},
    "output_format": "markdown"
  }
}
```

### 2. `bolt.spec.generator`

Generate technical specifications.

**Request:**
```json
{
  "tool": "bolt.spec.generator",
  "parameters": {
    "service_name": "payment-service",
    "components": ["api", "worker", "database"],
    "architecture_type": "microservices"
  }
}
```

### 3. `bolt.docs.generator`

Generate complete documentation suite.

**Request:**
```json
{
  "tool": "bolt.docs.generator",
  "parameters": {
    "project": "smarteros",
    "include": ["api", "user-guide", "architecture"]
  }
}
```

### 4. `bolt.autofix`

Auto-fix code and documentation issues.

**Request:**
```json
{
  "tool": "bolt.autofix",
  "parameters": {
    "target": "code content here",
    "issue_type": "deprecated"
  }
}
```

## 🔐 Autenticación

Todas las requests requieren header `X-MCP-API-Key`:

```bash
curl -H "X-MCP-API-Key: your-api-key" \
  http://localhost:8080/tools
```

## 📊 Logging

Logs estructurados en formato JSON:

```json
{
  "event": "tool_invoked",
  "tool": "bolt.writer",
  "tenant_rut": "12345678-9",
  "timestamp": "2025-11-23T10:00:00Z",
  "level": "info"
}
```

## 🧪 Testing

```bash
# Unit tests
pytest tests/unit

# Integration tests
pytest tests/integration

# Coverage
pytest --cov=app --cov-report=html
```

## 📦 Variables de Entorno

```bash
# MCP Server
MCP_HOST=0.0.0.0
MCP_PORT=8080
MCP_API_KEY=your-secret-key

# OpenAI
OPENAI_API_KEY=sk-...

# Vault
VAULT_ADDR=http://vault:8200
VAULT_TOKEN=your-vault-token

# Supabase
SUPABASE_URL=https://xxx.supabase.co
SUPABASE_KEY=your-supabase-key

# Logging
LOG_LEVEL=INFO
```

## 🚀 Deployment

### Production

```bash
# Build
docker build -t smarteros/mcp-server:latest .

# Run
docker run -d \
  --name mcp-server \
  -p 8080:8080 \
  -e OPENAI_API_KEY=$OPENAI_API_KEY \
  -e VAULT_ADDR=$VAULT_ADDR \
  smarteros/mcp-server:latest
```

### Monitoring

Health check URL: `https://mcp.smarterbot.cl/health`

Metrics: `/metrics` (TODO: implement Prometheus)

## 📚 Referencias

- [MCP Specification](https://spec.modelcontextprotocol.io)
- [FastAPI Docs](https://fastapi.tiangolo.com)
- [OpenAI API](https://platform.openai.com/docs)
- [Vault API](https://developer.hashicorp.com/vault/api-docs)

## 📄 Licencia

Proprietary - SmarterOS Team © 2025
