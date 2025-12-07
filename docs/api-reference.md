# SmarterOS API Documentation v1.2.0

Welcome to the SmarterOS API documentation. This guide details the API endpoints, including request/response formats, authentication methods, and error handling for the SmarterOS platform.

## Authentication

All API requests require authentication. The API uses API keys for authentication. Include your API key in the header of each request:

```bash
Authorization: Bearer <YOUR_API_KEY>
```

Replace `<YOUR_API_KEY>` with your actual API key.

## Rate Limiting

The SmarterOS API enforces rate limiting to ensure fair resource usage. If you exceed the rate limits, you will receive a `429 Too Many Requests` response. Contact support for higher limits.

## Error Handling

Errors are returned as standard HTTP status codes:

- `400 Bad Request` - Invalid request format.
- `401 Unauthorized` - Authentication failed.
- `404 Not Found` - The requested resource does not exist.
- `429 Too Many Requests` - Rate limit exceeded.
- `500 Internal Server Error` - Server error.

Error responses will include more details in the body:

```json
{
  "error": "Description of the error."
}
```

## MCP Registry Integration

### Retrieve MCP Registry

**GET** `/registry.json`

Returns a list of all available tools and categories.

**Request:**

```bash
curl -H "Authorization: Bearer <YOUR_API_KEY>" https://api.smarterbot.cl/registry.json
```

**Response:**

```json
{
  "odoo": 5,
  "supabase": 5,
  "n8n": 6,
  "chatwoot": 7,
  "core": 5
}
```

## API Endpoints

### Core Endpoints

#### Health Check

**GET** `/health`

Checks the API's health.

**Request:**

```bash
curl -H "Authorization: Bearer <YOUR_API_KEY>" https://api.smarterbot.cl/health
```

**Response:**

```json
{
  "status": "healthy",
  "details": {
    "supabase": "configured",
    "n8n": "configured"
  }
}
```

### Odoo Endpoints

#### Search and Read

**POST** `/odoo/search_read`

Performs a search and read operation.

**Request:**

```bash
curl -X POST https://api.smarterbot.cl/odoo/search_read \
  -H "Authorization: Bearer <YOUR_API_KEY>" \
  -H "Content-Type: application/json" \
  -d '{"model": "res.partner", "domain": [["is_company", "=", true]], "fields": ["name", "email"], "limit": 10}'
```

**Response:**

```json
[
  {
    "name": "Company A",
    "email": "contact@companya.com"
  },
  {
    "name": "Company B",
    "email": "info@companyb.com"
  }
]
```

### Supabase Endpoints

#### Insert Row

**POST** `/supabase/insert`

Inserts a new row into a table.

**Request:**

```bash
curl -X POST https://api.smarterbot.cl/supabase/insert \
  -H "Authorization: Bearer <YOUR_API_KEY>" \
  -H "Content-Type: application/json" \
  -d '{"table": "contacts", "values": {"name": "John Doe", "email": "john.doe@example.com"}}'
```

**Response:**

```json
{
  "id": 1,
  "name": "John Doe",
  "email": "john.doe@example.com"
}
```

### n8n Endpoints

#### Get Workflows

**GET** `/n8n/workflows`

Retrieves all workflows.

**Request:**

```bash
curl -H "Authorization: Bearer <YOUR_API_KEY>" https://api.smarterbot.cl/n8n/workflows
```

**Response:**

```json
[
  {
    "id": "1",
    "name": "Data Processing",
    "active": true
  },
  {
    "id": "2",
    "name": "Alert Notification",
    "active": false
  }
]
```

### Chatwoot Endpoints

#### Get Contacts

**GET** `/chatwoot/contacts`

Retrieves all contacts.

**Request:**

```bash
curl -H "Authorization: Bearer <YOUR_API_KEY>" https://api.smarterbot.cl/chatwoot/contacts
```

**Response:**

```json
[
  {
    "id": 1,
    "name": "Alice",
    "email": "alice@example.com"
  },
  {
    "id": 2,
    "name": "Bob",
    "email": "bob@example.com"
  }
]
```

For more detailed API references, including additional endpoints and parameters, refer to the specific section in our documentation.