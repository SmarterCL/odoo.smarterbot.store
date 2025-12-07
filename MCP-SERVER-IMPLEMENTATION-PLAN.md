# 🏗️ MCP SERVER - PLAN DE IMPLEMENTACIÓN COMPLETO

**Fecha**: 2025-11-23
**Dominio**: mcp.smarterbot.cl
**Status**: 🟡 En Construcción

---

## 📋 TABLA DE CONTENIDOS

1. [Arquitectura MCP Server](#1-arquitectura-mcp-server)
2. [Bolt como Agente MCP](#2-bolt-como-agente-mcp)
3. [Tenant RUT Onboarding](#3-tenant-rut-onboarding)
4. [Integración de Servicios](#4-integración-de-servicios)
5. [Motor de Contabilidad y Pagos](#5-motor-de-contabilidad-y-pagos)
6. [Roadmap de Implementación](#6-roadmap-de-implementación)

---

## 1. ARQUITECTURA MCP SERVER

### 🌐 Dominio
- **URL**: `mcp.smarterbot.cl`
- **SSL**: Caddy auto-provisioning
- **DNS**: Cloudflare/Mainkey

### 🐳 Componentes Docker

```yaml
services:
  mcp-server:
    image: smarteros/mcp-server:latest
    container_name: mcp-smarterbot
    ports:
      - "8080:8080"
    environment:
      - MCP_HOST=0.0.0.0
      - MCP_PORT=8080
      - VAULT_ADDR=http://vault:8200
      - SUPABASE_URL=${SUPABASE_URL}
    volumes:
      - ./specs:/app/specs:ro
      - ./logs:/app/logs:rw
    networks:
      - smarteros
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.mcp.rule=Host(`mcp.smarterbot.cl`)"
```

### 📡 Endpoints Core

#### `/tools` - Tool Discovery
```json
{
  "tools": [
    {
      "name": "bolt.writer",
      "description": "AI documentation generator",
      "schema": {...}
    },
    {
      "name": "bolt.spec.generator",
      "description": "Specification generator",
      "schema": {...}
    },
    {
      "name": "bolt.docs.generator",
      "description": "Documentation suite generator",
      "schema": {...}
    },
    {
      "name": "bolt.autofix",
      "description": "Code and doc auto-fixer",
      "schema": {...}
    }
  ]
}
```

#### `/client/handshake` - Client Registration
```json
{
  "client_id": "chatwoot-tenant-123",
  "capabilities": ["tools", "agents", "events"],
  "protocol_version": "2024-11-05"
}
```

#### `/agents` - Agent Registry
```json
{
  "agents": [
    {
      "id": "bolt",
      "type": "documentation_generator",
      "status": "operational",
      "tools": ["bolt.writer", "bolt.spec.generator"]
    }
  ]
}
```

### 🔐 Seguridad

#### API Key Management
```python
# Middleware de autenticación
@app.middleware("http")
async def auth_middleware(request: Request, call_next):
    api_key = request.headers.get("X-MCP-API-Key")
    if not validate_key(api_key):
        return JSONResponse(
            status_code=401,
            content={"error": "Invalid API key"}
        )
    return await call_next(request)
```

#### Vault Integration
```python
# Vault client setup
vault_client = hvac.Client(
    url=os.getenv("VAULT_ADDR"),
    token=os.getenv("VAULT_TOKEN")
)

# Read tenant secrets
def get_tenant_secrets(rut: str):
    path = f"tenant/{rut}/credentials"
    return vault_client.secrets.kv.v2.read_secret_version(path)
```

### 📊 Logging Estructurado

```python
import structlog

logger = structlog.get_logger()

logger.info(
    "tool_invoked",
    tool="bolt.writer",
    tenant_rut="12345678-9",
    duration_ms=1234,
    status="success"
)
```

---

## 2. BOLT COMO AGENTE MCP

### 🤖 Registro de Bolt

```python
# mcp/agents/bolt.py
class BoltAgent:
    def __init__(self):
        self.id = "bolt"
        self.type = "documentation_generator"
        self.version = "1.0.0"
        self.tools = [
            "bolt.writer",
            "bolt.spec.generator",
            "bolt.docs.generator",
            "bolt.autofix"
        ]
    
    async def invoke(self, tool: str, params: dict):
        """Invoke Bolt tool"""
        if tool == "bolt.writer":
            return await self.generate_document(params)
        elif tool == "bolt.spec.generator":
            return await self.generate_spec(params)
        # ... more tools
```

### 🛠️ Tools de Bolt

#### 1. `bolt.writer`
**Descripción**: Generador de documentación AI
```json
{
  "name": "bolt.writer",
  "description": "Generate AI-powered documentation",
  "parameters": {
    "doc_type": {
      "type": "string",
      "enum": ["guide", "api", "troubleshooting"],
      "required": true
    },
    "specs": {
      "type": "object",
      "required": true
    },
    "output_format": {
      "type": "string",
      "enum": ["markdown", "html", "pdf"],
      "default": "markdown"
    }
  }
}
```

#### 2. `bolt.spec.generator`
**Descripción**: Generador de especificaciones técnicas
```json
{
  "name": "bolt.spec.generator",
  "description": "Generate technical specifications",
  "parameters": {
    "service_name": {"type": "string", "required": true},
    "components": {"type": "array", "required": true},
    "architecture_type": {
      "type": "string",
      "enum": ["microservices", "monolithic", "serverless"]
    }
  }
}
```

#### 3. `bolt.docs.generator`
**Descripción**: Suite completa de documentación
```json
{
  "name": "bolt.docs.generator",
  "description": "Generate complete documentation suite",
  "parameters": {
    "project": {"type": "string", "required": true},
    "include": {
      "type": "array",
      "items": {
        "enum": ["api", "user-guide", "architecture", "deployment"]
      }
    }
  }
}
```

#### 4. `bolt.autofix`
**Descripción**: Auto-corrección de código y docs
```json
{
  "name": "bolt.autofix",
  "description": "Auto-fix code and documentation issues",
  "parameters": {
    "target": {"type": "string", "required": true},
    "issue_type": {
      "type": "string",
      "enum": ["syntax", "formatting", "deprecated", "security"]
    }
  }
}
```

### 🔌 Exposición como Tool Provider

```python
# mcp/server.py
from fastapi import FastAPI
from mcp.agents.bolt import BoltAgent

app = FastAPI()
bolt = BoltAgent()

@app.get("/tools")
async def list_tools():
    """List all available tools"""
    return {
        "tools": [
            {
                "name": tool,
                "provider": "bolt",
                "schema": bolt.get_tool_schema(tool)
            }
            for tool in bolt.tools
        ]
    }

@app.post("/tools/{tool_name}/invoke")
async def invoke_tool(tool_name: str, params: dict):
    """Invoke a specific tool"""
    result = await bolt.invoke(tool_name, params)
    return {"status": "success", "result": result}
```

---

## 3. TENANT RUT ONBOARDING

### 🔑 Endpoints

#### `POST /tenant/rut/validate`
**Validación de RUT chileno**

```python
from fastapi import HTTPException
import re

def validate_chilean_rut(rut: str) -> bool:
    """Validate Chilean RUT format and checksum"""
    # Remove dots and dashes
    rut = rut.replace(".", "").replace("-", "")
    
    # Check format
    if not re.match(r'^\d{7,8}[0-9Kk]$', rut):
        return False
    
    # Validate checksum
    body = rut[:-1]
    dv = rut[-1].upper()
    
    sum = 0
    multiplier = 2
    for digit in reversed(body):
        sum += int(digit) * multiplier
        multiplier = multiplier + 1 if multiplier < 7 else 2
    
    expected_dv = 11 - (sum % 11)
    if expected_dv == 11:
        expected_dv = '0'
    elif expected_dv == 10:
        expected_dv = 'K'
    else:
        expected_dv = str(expected_dv)
    
    return dv == expected_dv

@app.post("/tenant/rut/validate")
async def validate_rut(rut: str, company_name: str):
    """Validate and register tenant by RUT"""
    if not validate_chilean_rut(rut):
        raise HTTPException(400, "Invalid RUT format")
    
    # Create tenant in Vault
    await create_vault_space(rut)
    
    # Create Supabase row
    await create_tenant_db(rut, company_name)
    
    # Provision Odoo instance
    await provision_odoo(rut)
    
    return {
        "status": "validated",
        "rut": rut,
        "tenant_id": generate_tenant_id(rut)
    }
```

#### `GET /vault/tenant/{rut}/credentials`
**Obtener credenciales del tenant**

```python
@app.get("/vault/tenant/{rut}/credentials")
async def get_tenant_credentials(rut: str):
    """Get tenant credentials from Vault"""
    path = f"tenant/{rut}/credentials"
    
    try:
        secret = vault_client.secrets.kv.v2.read_secret_version(path)
        return {
            "shopify_token": secret["data"]["data"]["shopify_token"],
            "odoo_api_key": secret["data"]["data"]["odoo_api_key"],
            "chatwoot_token": secret["data"]["data"]["chatwoot_token"]
        }
    except Exception as e:
        raise HTTPException(404, f"Tenant not found: {e}")
```

### 🗄️ Supabase Schema

```sql
-- Tabla de tenants
CREATE TABLE tenants (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    rut VARCHAR(12) UNIQUE NOT NULL,
    company_name VARCHAR(255) NOT NULL,
    status VARCHAR(50) DEFAULT 'active',
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- Tabla de credenciales (referencias a Vault)
CREATE TABLE tenant_credentials (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id UUID REFERENCES tenants(id),
    service VARCHAR(50) NOT NULL,
    vault_path VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT NOW()
);

-- RLS Policies
ALTER TABLE tenants ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Tenants can read own data"
    ON tenants FOR SELECT
    USING (rut = current_setting('app.current_tenant')::VARCHAR);
```

### 🚀 Auto Provisioning

```python
async def provision_tenant(rut: str, company_name: str):
    """Auto-provision all services for new tenant"""
    
    # 1. Create Vault namespace
    vault_path = f"tenant/{rut}"
    vault_client.sys.enable_secrets_engine(
        backend_type='kv-v2',
        path=vault_path
    )
    
    # 2. Create Odoo database
    odoo_db = f"odoo_{rut.replace('-', '')}"
    await create_odoo_database(odoo_db, company_name)
    
    # 3. Create Shopify app installation
    shopify_token = await initiate_shopify_oauth(rut)
    
    # 4. Create Chatwoot inbox
    chatwoot_inbox = await create_chatwoot_inbox(company_name)
    
    # 5. Store credentials in Vault
    await vault_client.secrets.kv.v2.create_or_update_secret(
        path=f"{vault_path}/credentials",
        secret={
            "shopify_token": shopify_token,
            "odoo_db": odoo_db,
            "chatwoot_inbox_id": chatwoot_inbox
        }
    )
    
    # 6. Create Supabase tenant row
    await supabase.table("tenants").insert({
        "rut": rut,
        "company_name": company_name,
        "status": "active"
    }).execute()
    
    return {
        "status": "provisioned",
        "services": ["odoo", "shopify", "chatwoot", "vault"]
    }
```

---

## 4. INTEGRACIÓN DE SERVICIOS

### 🛍️ Shopify Integration

#### OAuth Flow
```python
from shopify import Session, ShopifyResource

@app.get("/integrations/shopify/auth")
async def shopify_auth_start(rut: str):
    """Start Shopify OAuth flow"""
    shop = f"{rut}.myshopify.com"
    scopes = ["read_products", "write_orders", "read_customers"]
    redirect_uri = f"https://mcp.smarterbot.cl/integrations/shopify/callback"
    
    auth_url = Session.create_permission_url(
        shop=shop,
        scopes=scopes,
        redirect_uri=redirect_uri
    )
    
    return {"auth_url": auth_url}

@app.get("/integrations/shopify/callback")
async def shopify_callback(shop: str, code: str, state: str):
    """Handle Shopify OAuth callback"""
    session = Session(shop, code)
    access_token = session.request_token()
    
    # Store in Vault
    rut = extract_rut_from_state(state)
    await vault_client.secrets.kv.v2.create_or_update_secret(
        path=f"tenant/{rut}/shopify",
        secret={"access_token": access_token, "shop": shop}
    )
    
    return {"status": "connected"}
```

#### Webhook Handler
```python
@app.post("/webhooks/shopify/orders")
async def shopify_order_webhook(order: dict, rut: str):
    """Handle Shopify order webhook"""
    
    # 1. Transform order to Odoo format
    odoo_order = transform_shopify_to_odoo(order)
    
    # 2. Create order in Odoo
    odoo_client = await get_odoo_client(rut)
    sale_order = await odoo_client.create_sale_order(odoo_order)
    
    # 3. Generate invoice
    invoice = await odoo_client.create_invoice(sale_order.id)
    
    # 4. Send to SII (Chilean tax authority)
    dte = await generate_dte(invoice, rut)
    await send_to_sii(dte)
    
    # 5. Notify Chatwoot
    await notify_chatwoot(rut, {
        "type": "new_order",
        "order_id": order["id"],
        "invoice_id": invoice.id
    })
    
    return {"status": "processed"}
```

### 📊 Odoo Integration

```python
import xmlrpc.client

class OdooClient:
    def __init__(self, url: str, db: str, username: str, password: str):
        self.url = url
        self.db = db
        self.username = username
        self.password = password
        self.uid = None
        self.models = None
        
    async def authenticate(self):
        """Authenticate with Odoo"""
        common = xmlrpc.client.ServerProxy(f'{self.url}/xmlrpc/2/common')
        self.uid = common.authenticate(
            self.db, self.username, self.password, {}
        )
        self.models = xmlrpc.client.ServerProxy(
            f'{self.url}/xmlrpc/2/object'
        )
    
    async def create_sale_order(self, order_data: dict):
        """Create sale order in Odoo"""
        order_id = self.models.execute_kw(
            self.db, self.uid, self.password,
            'sale.order', 'create',
            [order_data]
        )
        return order_id
    
    async def create_invoice(self, order_id: int):
        """Create invoice from sale order"""
        invoice_id = self.models.execute_kw(
            self.db, self.uid, self.password,
            'sale.order', 'action_invoice_create',
            [[order_id]]
        )
        return invoice_id
```

### 💬 Chatwoot Integration

```python
import httpx

class ChatwootClient:
    def __init__(self, api_key: str, account_id: int):
        self.base_url = "https://chatwoot.smarterbot.cl/api/v1"
        self.api_key = api_key
        self.account_id = account_id
    
    async def create_conversation(self, contact_id: int, inbox_id: int):
        """Create new conversation"""
        async with httpx.AsyncClient() as client:
            response = await client.post(
                f"{self.base_url}/accounts/{self.account_id}/conversations",
                headers={"api_access_token": self.api_key},
                json={
                    "contact_id": contact_id,
                    "inbox_id": inbox_id
                }
            )
            return response.json()
    
    async def send_message(self, conversation_id: int, message: str):
        """Send message to conversation"""
        async with httpx.AsyncClient() as client:
            response = await client.post(
                f"{self.base_url}/accounts/{self.account_id}/conversations/{conversation_id}/messages",
                headers={"api_access_token": self.api_key},
                json={
                    "content": message,
                    "message_type": "outgoing"
                }
            )
            return response.json()
```

### 🔄 n8n Integration

```python
@app.post("/integrations/n8n/workflow/trigger")
async def trigger_n8n_workflow(workflow_id: str, data: dict):
    """Trigger n8n workflow"""
    n8n_url = f"https://n8n.smarterbot.cl/webhook/{workflow_id}"
    
    async with httpx.AsyncClient() as client:
        response = await client.post(n8n_url, json=data)
        return response.json()

@app.post("/integrations/n8n/workflow/validate")
async def validate_workflow(workflow: dict):
    """Validate n8n workflow with Bolt"""
    result = await bolt.invoke("bolt.autofix", {
        "target": "n8n_workflow",
        "content": workflow
    })
    return result
```

---

## 5. MOTOR DE CONTABILIDAD Y PAGOS

### 🔄 Flujo Completo

```python
class AccountingEngine:
    """Motor de contabilidad automatizada Chile"""
    
    async def process_sale(self, rut: str, sale_data: dict):
        """
        Proceso completo de venta con contabilidad automática
        
        Workflow:
        1. Cliente registrado con RUT ✓
        2. Vault crea espacio seguro ✓
        3. Tokens Shopify guardados por RUT ✓
        4. Venta → Shopify ✓
        5. MCP transforma → Odoo ✓
        6. Odoo genera documentos → SII ✓
        7. Chatwoot responde ✓
        8. KPIs → Metabase ✓
        9. Bot hace seguimiento ✓
        """
        
        # 1. Validar tenant
        tenant = await self.get_tenant(rut)
        if not tenant:
            raise ValueError(f"Tenant {rut} not found")
        
        # 2. Obtener credenciales de Vault
        creds = await vault_client.secrets.kv.v2.read_secret_version(
            path=f"tenant/{rut}/credentials"
        )
        
        # 3. Procesar venta en Shopify
        shopify_order = await self.create_shopify_order(
            creds["data"]["shopify_token"],
            sale_data
        )
        
        # 4. Transformar a formato Odoo
        odoo_data = self.transform_to_odoo(shopify_order)
        
        # 5. Crear orden en Odoo
        odoo_client = await self.get_odoo_client(rut)
        sale_order = await odoo_client.create_sale_order(odoo_data)
        
        # 6. Generar factura
        invoice = await odoo_client.create_invoice(sale_order)
        
        # 7. Generar DTE (Documento Tributario Electrónico)
        dte = await self.generate_dte(invoice, tenant)
        
        # 8. Enviar a SII
        sii_response = await self.send_to_sii(dte)
        
        # 9. Notificar Chatwoot
        await self.notify_customer(rut, {
            "order_id": shopify_order["id"],
            "invoice_number": invoice["number"],
            "dte_folio": dte["folio"],
            "sii_status": sii_response["status"]
        })
        
        # 10. Registrar en Metabase
        await self.log_kpi({
            "tenant_rut": rut,
            "sale_amount": sale_data["amount"],
            "tax": invoice["tax_amount"],
            "timestamp": datetime.now()
        })
        
        # 11. Trigger seguimiento bot
        await self.trigger_bot_followup(rut, shopify_order["id"])
        
        return {
            "status": "success",
            "shopify_order_id": shopify_order["id"],
            "odoo_invoice_id": invoice["id"],
            "dte_folio": dte["folio"],
            "sii_trackid": sii_response["trackid"]
        }
```

### 📄 Generación DTE (Chile)

```python
from datetime import datetime
import xml.etree.ElementTree as ET

async def generate_dte(invoice: dict, tenant: dict) -> dict:
    """
    Generar Documento Tributario Electrónico para SII Chile
    """
    # DTE tipo 33 = Factura Electrónica
    dte_type = 33
    
    # Obtener folio desde CAF (Código de Autorización de Folios)
    folio = await get_next_folio(tenant["rut"], dte_type)
    
    # Construir XML DTE
    dte = ET.Element("DTE", version="1.0")
    documento = ET.SubElement(dte, "Documento", ID=f"T{dte_type}F{folio}")
    
    # Encabezado
    encabezado = ET.SubElement(documento, "Encabezado")
    id_doc = ET.SubElement(encabezado, "IdDoc")
    ET.SubElement(id_doc, "TipoDTE").text = str(dte_type)
    ET.SubElement(id_doc, "Folio").text = str(folio)
    ET.SubElement(id_doc, "FchEmis").text = datetime.now().strftime("%Y-%m-%d")
    
    # Emisor
    emisor = ET.SubElement(encabezado, "Emisor")
    ET.SubElement(emisor, "RUTEmisor").text = tenant["rut"]
    ET.SubElement(emisor, "RznSoc").text = tenant["company_name"]
    
    # Receptor
    receptor = ET.SubElement(encabezado, "Receptor")
    ET.SubElement(receptor, "RUTRecep").text = invoice["partner_rut"]
    ET.SubElement(receptor, "RznSocRecep").text = invoice["partner_name"]
    
    # Totales
    totales = ET.SubElement(encabezado, "Totales")
    ET.SubElement(totales, "MntNeto").text = str(int(invoice["amount_untaxed"]))
    ET.SubElement(totales, "MntExe").text = "0"
    ET.SubElement(totales, "IVA").text = str(int(invoice["amount_tax"]))
    ET.SubElement(totales, "MntTotal").text = str(int(invoice["amount_total"]))
    
    # Detalles
    detalles = ET.SubElement(documento, "Detalles")
    for line in invoice["lines"]:
        detalle = ET.SubElement(detalles, "Detalle")
        ET.SubElement(detalle, "NroLinDet").text = str(line["sequence"])
        ET.SubElement(detalle, "NmbItem").text = line["product_name"]
        ET.SubElement(detalle, "QtyItem").text = str(line["quantity"])
        ET.SubElement(detalle, "PrcItem").text = str(int(line["price_unit"]))
        ET.SubElement(detalle, "MontoItem").text = str(int(line["price_subtotal"]))
    
    # Firmar DTE
    signed_dte = await sign_dte(ET.tostring(dte), tenant["cert"])
    
    return {
        "type": dte_type,
        "folio": folio,
        "xml": signed_dte,
        "hash": calculate_hash(signed_dte)
    }
```

### 🏛️ Envío a SII

```python
import httpx

async def send_to_sii(dte: dict) -> dict:
    """Enviar DTE al SII (Servicio de Impuestos Internos)"""
    
    sii_url = "https://palena.sii.cl/cgi_dte/UPL/DTEUpload"
    
    # Preparar envío
    envelope = create_sii_envelope(dte)
    
    async with httpx.AsyncClient() as client:
        response = await client.post(
            sii_url,
            files={"file": ("dte.xml", envelope, "text/xml")},
            timeout=30.0
        )
        
        if response.status_code == 200:
            trackid = parse_sii_response(response.text)
            return {
                "status": "accepted",
                "trackid": trackid,
                "timestamp": datetime.now().isoformat()
            }
        else:
            return {
                "status": "rejected",
                "error": response.text
            }
```

---

## 6. ROADMAP DE IMPLEMENTACIÓN

### Fase 1: Infraestructura Base (Semana 1)
- [ ] Setup Docker Compose para MCP Server
- [ ] Configurar dominio mcp.smarterbot.cl
- [ ] Implementar endpoints básicos (/tools, /agents, /handshake)
- [ ] Integrar Vault para secrets
- [ ] Logging estructurado con structlog

### Fase 2: Bolt como Agente (Semana 2)
- [ ] Registrar Bolt en MCP
- [ ] Implementar tools (bolt.writer, bolt.spec.generator, etc.)
- [ ] Exponer como tool provider
- [ ] Tests de integración

### Fase 3: Tenant Onboarding (Semana 3)
- [ ] Endpoint /tenant/rut/validate
- [ ] Integración Vault por RUT
- [ ] Schema Supabase para tenants
- [ ] Auto-provisioning Odoo + Shopify

### Fase 4: Integraciones (Semana 4-5)
- [ ] Shopify OAuth + webhooks
- [ ] Odoo XML-RPC client
- [ ] Chatwoot API client
- [ ] n8n workflow triggers
- [ ] Metabase dashboards

### Fase 5: Motor Contabilidad (Semana 6-7)
- [ ] Generación DTE (Chile)
- [ ] Integración SII
- [ ] Flujo completo de venta
- [ ] Conciliación automática
- [ ] Reportes tributarios

### Fase 6: Testing y Producción (Semana 8)
- [ ] Tests end-to-end
- [ ] Carga de prueba
- [ ] Documentación completa
- [ ] Deploy a producción
- [ ] Monitoreo y alertas

---

## 📊 MÉTRICAS DE ÉXITO

- **Uptime MCP Server**: >99.9%
- **Latencia promedio**: <200ms
- **Tasa de éxito DTE**: >99%
- **Tiempo onboarding tenant**: <5 minutos
- **Documentación generada por Bolt**: 100% validada

---

## 🔗 REFERENCIAS

- [MCP Specification](https://spec.modelcontextprotocol.io)
- [Shopify API Docs](https://shopify.dev/api)
- [Odoo XML-RPC](https://www.odoo.com/documentation/16.0/developer/reference/external_api.html)
- [SII Chile - DTE](https://www.sii.cl/servicios_online/1039-1185.html)
- [Vault API](https://developer.hashicorp.com/vault/api-docs)

