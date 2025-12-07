# 📡 API Specification - SmarterOS

## 🎯 Overview

SmarterOS API Gateway is built with **FastAPI** and provides a unified interface to all backend services.

**Base URL:** `https://api.smarterbot.cl`  
**Version:** `v1`  
**Authentication:** JWT (Clerk)

---

## 🔐 Authentication

### Get Token

```bash
# Login via Clerk
curl -X POST https://clerk.smarterbot.cl/v1/client/sign_ins \
  -H "Content-Type: application/json" \
  -d '{
    "identifier": "user@example.com",
    "password": "password123"
  }'

# Response
{
  "client": {...},
  "response": {
    "session_token": "eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9..."
  }
}
```

### Use Token

```bash
curl -X GET https://api.smarterbot.cl/v1/users/me \
  -H "Authorization: Bearer eyJhbGc..."
```

---

## 📊 Core Endpoints

### Health Check

```http
GET /health
```

**Response:**
```json
{
  "status": "healthy",
  "version": "1.0.0",
  "services": {
    "odoo": "up",
    "database": "up",
    "redis": "up"
  }
}
```

---

### Users

#### Get Current User

```http
GET /v1/users/me
Authorization: Bearer {token}
```

**Response:**
```json
{
  "id": "user_2abc...",
  "tenant_id": "550e8400-...",
  "email": "user@example.com",
  "role": "admin",
  "created_at": "2025-11-23T12:00:00Z"
}
```

#### List Users (Admin)

```http
GET /v1/users?page=1&limit=20
Authorization: Bearer {admin_token}
```

---

### Tenants

#### Register Tenant

```http
POST /v1/tenants/register
Content-Type: application/json

{
  "rut": "12345678-9",
  "business_name": "Mi Empresa SPA",
  "email": "admin@miempresa.cl",
  "plan": "starter"
}
```

**Response:**
```json
{
  "tenant_id": "550e8400-...",
  "status": "provisioning",
  "onboarding_url": "https://app.smarterbot.cl/onboard"
}
```

#### Get Tenant Info

```http
GET /v1/tenants/{tenant_id}
Authorization: Bearer {token}
```

---

### Leads

#### Create Lead

```http
POST /v1/leads
Authorization: Bearer {token}
Content-Type: application/json

{
  "name": "Juan Pérez",
  "email": "juan@example.com",
  "phone": "+56912345678",
  "source": "website",
  "notes": "Interested in Starter plan"
}
```

**Response:**
```json
{
  "id": "lead_123",
  "tenant_id": "550e8400-...",
  "status": "new",
  "created_at": "2025-11-23T12:30:00Z"
}
```

#### List Leads

```http
GET /v1/leads?status=new&page=1&limit=20
Authorization: Bearer {token}
```

---

### Workflows (n8n)

#### Trigger Workflow

```http
POST /v1/workflows/{workflow_id}/trigger
Authorization: Bearer {token}
Content-Type: application/json

{
  "data": {
    "lead_id": "lead_123",
    "action": "send_welcome_email"
  }
}
```

#### List Workflows

```http
GET /v1/workflows
Authorization: Bearer {token}
```

---

### ERP (Odoo Proxy)

#### Get Products

```http
GET /v1/erp/products?category=services
Authorization: Bearer {token}
```

#### Create Sale Order

```http
POST /v1/erp/orders
Authorization: Bearer {token}
Content-Type: application/json

{
  "partner_id": 123,
  "order_line": [
    {
      "product_id": 45,
      "quantity": 1
    }
  ]
}
```

---

## 🔄 Webhooks

### Clerk User Events

```http
POST /v1/webhooks/clerk
X-Clerk-Signature: {signature}
Content-Type: application/json

{
  "type": "user.created",
  "data": {
    "id": "user_2abc...",
    "email_addresses": [...]
  }
}
```

### n8n Workflow Completed

```http
POST /v1/webhooks/n8n
X-N8N-Signature: {signature}
Content-Type: application/json

{
  "workflow_id": "wf_123",
  "execution_id": "exec_456",
  "status": "success"
}
```

---

## ⚠️ Error Handling

### Standard Error Response

```json
{
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Invalid RUT format",
    "details": {
      "field": "rut",
      "expected": "12345678-9"
    }
  }
}
```

### Error Codes

| Code | HTTP Status | Description |
|------|-------------|-------------|
| `UNAUTHORIZED` | 401 | Invalid or missing JWT |
| `FORBIDDEN` | 403 | Insufficient permissions |
| `NOT_FOUND` | 404 | Resource not found |
| `VALIDATION_ERROR` | 422 | Invalid input |
| `RATE_LIMIT_EXCEEDED` | 429 | Too many requests |
| `INTERNAL_ERROR` | 500 | Server error |

---

## 🚦 Rate Limiting

```
Free:       100 requests/minute
Starter:    1,000 requests/minute
Business:   10,000 requests/minute
Enterprise: Unlimited
```

**Headers:**
```
X-RateLimit-Limit: 1000
X-RateLimit-Remaining: 995
X-RateLimit-Reset: 1732368000
```

---

## 📦 SDK Examples

### Python

```python
import requests

class SmarterOSClient:
    def __init__(self, api_key: str):
        self.base_url = "https://api.smarterbot.cl/v1"
        self.headers = {
            "Authorization": f"Bearer {api_key}",
            "Content-Type": "application/json"
        }
    
    def create_lead(self, name: str, email: str):
        response = requests.post(
            f"{self.base_url}/leads",
            json={"name": name, "email": email},
            headers=self.headers
        )
        return response.json()

client = SmarterOSClient("your_token_here")
lead = client.create_lead("Juan Pérez", "juan@example.com")
```

### TypeScript

```typescript
class SmarterOSClient {
  constructor(private apiKey: string) {}
  
  async createLead(name: string, email: string) {
    const response = await fetch('https://api.smarterbot.cl/v1/leads', {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${this.apiKey}`,
        'Content-Type': 'application/json'
      },
      body: JSON.stringify({ name, email })
    })
    return response.json()
  }
}

const client = new SmarterOSClient('your_token_here')
const lead = await client.createLead('Juan Pérez', 'juan@example.com')
```

---

## 🧪 Testing

### Postman Collection

Download: [SmarterOS.postman_collection.json](./postman/SmarterOS.postman_collection.json)

### cURL Examples

See [examples/](./examples/) directory for complete cURL commands.

---

**Version:** 1.0  
**Last Updated:** 2025-11-23  
**Maintainer:** SmarterCL API Team
