# 📡 METABASE API — AUTOMATION GUIDE

**Complete API Reference for SmarterOS KPI Integration**

Base URL: `https://kpi.smarterbot.cl/api`

---

## 1. Autenticación

### Login
```bash
POST /api/session
Content-Type: application/json

{
  "username": "smarterbotcl@gmail.com",
  "password": "Chevrolet2025+"
}
```

**Response:**
```json
{
  "id": "SESSION_TOKEN_HERE"
}
```

**Uso en requests:**
```bash
X-Metabase-Session: SESSION_TOKEN_HERE
```

---

## 2. Database Management

### Listar databases
```bash
GET /api/database
X-Metabase-Session: SESSION_TOKEN
```

### Crear conexión a Supabase
```bash
POST /api/database
X-Metabase-Session: SESSION_TOKEN
Content-Type: application/json

{
  "name": "SmarterDB",
  "engine": "postgres",
  "details": {
    "host": "aws-0-us-east-1.pooler.supabase.com",
    "port": 6543,
    "dbname": "postgres",
    "user": "postgres.rjfcmmzjlguiititkmyh",
    "password": "RctbsgNqeUeEIO9e",
    "ssl": true,
    "tunnel-enabled": false,
    "additional-options": "sslmode=require&prepareThreshold=0"
  }
}
```

### Sincronizar schema
```bash
POST /api/database/{id}/sync_schema
X-Metabase-Session: SESSION_TOKEN
```

---

## 3. Dashboard Management

### Crear dashboard
```bash
POST /api/dashboard
X-Metabase-Session: SESSION_TOKEN
Content-Type: application/json

{
  "name": "Dashboard Ejecutivo",
  "description": "Vista General del Sistema SmarterOS"
}
```

### Listar dashboards
```bash
GET /api/dashboard
X-Metabase-Session: SESSION_TOKEN
```

### Obtener dashboard específico
```bash
GET /api/dashboard/{id}
X-Metabase-Session: SESSION_TOKEN
```

---

## 4. Card Management (Gráficos)

### Crear tarjeta SQL
```bash
POST /api/card
X-Metabase-Session: SESSION_TOKEN
Content-Type: application/json

{
  "name": "Ventas Totales",
  "display": "line",
  "visualization_settings": {
    "graph.dimensions": ["day"],
    "graph.metrics": ["revenue"]
  },
  "dataset_query": {
    "database": 1,
    "type": "native",
    "native": {
      "query": "SELECT date_trunc('day', order_date) as day, sum(total_amount) as revenue FROM odoo_orders GROUP BY 1 ORDER BY 1 DESC LIMIT 30"
    }
  }
}
```

### Agregar tarjeta al dashboard
```bash
POST /api/dashboard/{dashboard_id}/cards
X-Metabase-Session: SESSION_TOKEN
Content-Type: application/json

{
  "cardId": 32,
  "col": 0,
  "row": 0,
  "sizeX": 4,
  "sizeY": 4
}
```

---

## 5. Embedding

### Generar token de embedding
```bash
POST /api/embed/dashboard/{id}/query
X-Metabase-Session: SESSION_TOKEN
Content-Type: application/json

{
  "params": {
    "tenant_id": "76953480-3"
  },
  "exp": 3600
}
```

### Configurar embedding (Admin)
```bash
PUT /api/setting/enable-embedding
X-Metabase-Session: SESSION_TOKEN
Content-Type: application/json

{
  "value": true
}
```

### URL de embedding
```
https://kpi.smarterbot.cl/embed/dashboard/{TOKEN}#theme=night&bordered=true&titled=false
```

---

## 6. Alertas

### Crear alerta
```bash
POST /api/alert
X-Metabase-Session: SESSION_TOKEN
Content-Type: application/json

{
  "card": {
    "id": 32
  },
  "alert_condition": "rows",
  "alert_first_only": false,
  "alert_above_goal": true,
  "channels": [
    {
      "enabled": true,
      "channel_type": "http",
      "details": {
        "url": "https://n8n.smarterbot.store/webhook/kpi-alerts"
      }
    }
  ]
}
```

---

## 7. Collections (Organización)

### Crear colección por tenant
```bash
POST /api/collection
X-Metabase-Session: SESSION_TOKEN
Content-Type: application/json

{
  "name": "Tenant: 76953480-3",
  "description": "Dashboards para RUT 76953480-3",
  "color": "#509EE3"
}
```

---

## 8. Queries Nativas

### Ejecutar query SQL directo
```bash
POST /api/dataset
X-Metabase-Session: SESSION_TOKEN
Content-Type: application/json

{
  "database": 1,
  "type": "native",
  "native": {
    "query": "SELECT * FROM tenants WHERE rut = '76953480-3' LIMIT 10"
  }
}
```

---

## 9. Usuarios y Permisos

### Crear usuario
```bash
POST /api/user
X-Metabase-Session: SESSION_TOKEN
Content-Type: application/json

{
  "first_name": "Demo",
  "last_name": "Tenant",
  "email": "demo@smarterbot.cl",
  "password": "TempPass123!",
  "group_ids": [2]
}
```

### Asignar permisos a colección
```bash
PUT /api/collection/{id}/permissions
X-Metabase-Session: SESSION_TOKEN
Content-Type: application/json

{
  "groups": {
    "2": "read"
  }
}
```

---

## 10. Automatización Completa

### Script Python - Crear Dashboard Completo
```python
import requests

BASE_URL = "https://kpi.smarterbot.cl/api"
EMAIL = "smarterbotcl@gmail.com"
PASSWORD = "Chevrolet2025+"

# 1. Login
session = requests.post(f"{BASE_URL}/session", json={
    "username": EMAIL,
    "password": PASSWORD
}).json()

headers = {"X-Metabase-Session": session["id"]}

# 2. Crear Dashboard
dashboard = requests.post(f"{BASE_URL}/dashboard", headers=headers, json={
    "name": "Dashboard Ejecutivo",
    "description": "Vista 360° SmarterOS"
}).json()

# 3. Crear Card
card = requests.post(f"{BASE_URL}/card", headers=headers, json={
    "name": "Ventas Totales",
    "display": "line",
    "dataset_query": {
        "database": 1,
        "type": "native",
        "native": {
            "query": "SELECT date_trunc('day', order_date) as day, sum(total_amount) as revenue FROM odoo_orders GROUP BY 1 ORDER BY 1 DESC LIMIT 30"
        }
    }
}).json()

# 4. Agregar Card al Dashboard
requests.post(
    f"{BASE_URL}/dashboard/{dashboard['id']}/cards",
    headers=headers,
    json={
        "cardId": card["id"],
        "col": 0,
        "row": 0,
        "sizeX": 6,
        "sizeY": 4
    }
)

print(f"✅ Dashboard creado: {dashboard['id']}")
```

---

## 📞 Contacto

Email: smarterbotcl@gmail.com  
WhatsApp: +56 9 7954 0471  
Web: https://smarterbot.cl

🟢 **SmarterOS — Metabase API Integration**
