# API Service Architecture
# api.smarterbot.cl

## Service Overview

FastAPI microservice for contact form processing across Smarter OS web properties.

## Technology Stack

- **Language**: Python 3.11
- **Framework**: FastAPI 0.115.5
- **Server**: Uvicorn (ASGI) with 2 workers
- **Database Client**: Supabase Python SDK 2.10.0
- **Email Client**: Resend API via httpx
- **Validation**: Pydantic 2.10.3
- **Container**: Docker (python:3.11-slim base)

## Architecture Pattern

```
┌────────────────────────────────────────────────────────────┐
│                     Smarter OS Ecosystem                    │
├─────────────────┬─────────────────┬────────────────────────┤
│ smarterbot.cl   │ smarterbot.store│  app.smarterbot.cl     │
│   (Next.js)     │   (Vite+React)  │     (Next.js)          │
└────────┬────────┴────────┬────────┴────────────────────────┘
         │                 │
         │ HTTPS POST      │ HTTPS POST
         │ /contact        │ /contact
         └─────────┬───────┘
                   ▼
         ┌─────────────────────┐
         │   Traefik Proxy     │
         │  api.smarterbot.cl  │
         └──────────┬──────────┘
                    ▼
         ┌─────────────────────┐
         │  FastAPI Container  │
         │    (uvicorn:8000)   │
         │                     │
         │  ┌──────────────┐   │
         │  │ POST /contact│   │
         │  │ GET /contacts│   │
         │  │ GET /health  │   │
         │  └──────────────┘   │
         └──────┬─────┬────────┘
                │     │
       ┌────────▼─────▼────────┐
       │   Async Operations    │
       │ (fire-and-forget)     │
       ├───────────┬───────────┤
       │           │           │
       ▼           ▼           ▼
┌──────────┐ ┌──────────┐ ┌─────────┐
│ Supabase │ │  Resend  │ │  Future │
│ contacts │ │  Emails  │ │  n8n    │
└──────────┘ └──────────┘ └─────────┘
```

## Data Flow

### Contact Submission Flow

1. **Client Request**
   - User fills form on smarterbot.cl or smarterbot.store
   - JavaScript `fetch()` POST to `https://api.smarterbot.cl/contact`
   - Payload: `{name, email, message, phone?, source?}`

2. **API Gateway (Traefik)**
   - HTTPS termination
   - TLS with Let's Encrypt
   - Routes to `api-smarterbot` container

3. **FastAPI Application**
   - **CORS Check**: Validate origin in allowed list
   - **Request Validation**: Pydantic schema validation
   - **Database Insert**: Supabase client → `contacts` table
   - **Email Dispatch**: Async httpx → Resend API (non-blocking)
   - **Response**: `{ok: true, message: "..."}`

4. **Database Persistence**
   - Supabase PostgreSQL with RLS
   - Service role key bypasses RLS
   - Automatic `created_at` timestamp
   - UUID primary key generation

5. **Email Notifications**
   - **User Email**: Confirmation with message copy
   - **Admin Email**: New contact notification
   - Both async, no timeout penalty if failed

## Directory Structure

```
api.smarterbot.cl/
├── main.py              # FastAPI app entry point
│   ├── app = FastAPI()
│   ├── CORS middleware
│   ├── @app.post("/contact")
│   ├── @app.get("/contacts")
│   ├── @app.get("/health")
│   └── send_resend_emails()
├── Dockerfile           # Multi-stage Python container
├── requirements.txt     # pinned dependencies
├── .env.example         # environment template
├── .gitignore          # Python + env exclusions
└── README.md           # usage documentation
```

## Environment Configuration

```bash
# Database (required)
SUPABASE_URL=https://xxx.supabase.co
SUPABASE_SERVICE_ROLE=eyJhbGciOiJ...  # bypasses RLS

# Email (optional but recommended)
RESEND_API_KEY=re_xxxxx
RESEND_FROM=no-reply@smarterbot.cl
ADMIN_EMAIL=smarterbotcl@gmail.com
```

## Docker Configuration

### Dockerfile

```dockerfile
FROM python:3.11-slim
WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY main.py .
EXPOSE 8000
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000", "--workers", "2"]
```

### Docker Compose Integration

```yaml
api-smarterbot:
  build: ../api.smarterbot.cl
  container_name: api-smarterbot
  restart: unless-stopped
  ports:
    - "8000:8000"
  environment:
    - SUPABASE_URL=${SUPABASE_URL}
    - SUPABASE_SERVICE_ROLE=${SUPABASE_SERVICE_ROLE}
    - RESEND_API_KEY=${RESEND_API_KEY}
  networks:
    - smarter-net
    - dokploy-network
  labels:
    - "traefik.enable=true"
    - "traefik.http.routers.api-smarterbot.rule=Host(`api.smarterbot.cl`)"
    - "traefik.http.routers.api-smarterbot.entrypoints=websecure"
    - "traefik.http.routers.api-smarterbot.tls.certresolver=letsencrypt"
```

## Database Schema

### contacts table

```sql
create table public.contacts (
  id uuid default gen_random_uuid() primary key,
  name text not null,
  email text not null,
  message text not null,
  phone text,
  source text,           -- 'smarterbot.cl', 'smarterbot.store'
  domain text,           -- from request Host header
  status text default 'new',  -- 'new', 'contacted', 'closed'
  created_at timestamp with time zone default now()
);

-- RLS enabled but service_role bypasses it
alter table public.contacts enable row level security;
```

Location: `smarteros-specs/integrations/supabase/sql/contacts.sql`

## API Endpoints

### POST /contact

**Purpose**: Submit new contact form

**Request Body**:
```json
{
  "name": "string (1-200 chars)",
  "email": "valid email",
  "message": "string (1-5000 chars)",
  "phone": "string (optional, max 50 chars)",
  "source": "string (optional, max 100 chars)"
}
```

**Validation**:
- Email format via Pydantic `EmailStr`
- Length constraints enforced
- All fields sanitized

**Response** (201):
```json
{
  "ok": true,
  "message": "Contact submitted successfully"
}
```

**Errors**:
- 400: Validation error (missing fields, invalid email)
- 500: Database not configured or insert failed

### GET /contacts

**Purpose**: List recent contacts (admin endpoint)

**Query Parameters**:
- `limit`: 1-100 (default: 10)
- `status`: 'new' | 'contacted' | 'closed' (optional)

**Response** (200):
```json
{
  "contacts": [
    {
      "id": "uuid",
      "name": "...",
      "email": "...",
      "message": "...",
      "phone": "...",
      "source": "...",
      "domain": "...",
      "status": "new",
      "created_at": "2025-11-22T04:30:00Z"
    }
  ],
  "count": 5
}
```

**Future**: Add authentication (Clerk/Supabase Auth)

### GET /health

**Purpose**: Service health check

**Response** (200):
```json
{
  "status": "healthy",
  "supabase": "configured",
  "resend": "configured"
}
```

Used by:
- Kubernetes liveness probes
- Monitoring (Uptime Kuma, Prometheus)
- Docker health checks

### GET /

**Purpose**: Service discovery

**Response** (200):
```json
{
  "service": "Smarter OS API",
  "status": "operational",
  "version": "1.0.0",
  "endpoints": ["/contact", "/health"]
}
```

### GET /docs

**Purpose**: Interactive API documentation (Swagger UI)

Auto-generated by FastAPI from Pydantic schemas.

### GET /redoc

**Purpose**: Alternative API documentation (ReDoc)

More polished than Swagger UI, better for public-facing docs.

## Security

### CORS Policy

```python
allow_origins=[
    "https://smarterbot.cl",
    "https://www.smarterbot.cl",
    "https://smarterbot.store",
    "https://www.smarterbot.store",
    "https://app.smarterbot.cl",
    "http://localhost:3000",  # Next.js dev
    "http://localhost:5173",  # Vite dev
]
```

### Input Validation

- Pydantic schemas enforce type safety
- Email validation via `EmailStr`
- String length constraints prevent DoS
- SQL injection impossible (Supabase client uses parameterized queries)

### Authentication

**Current**: No authentication (public endpoint)

**Future**:
- Add Clerk/Supabase Auth to `/contacts` endpoint
- JWT token validation
- Rate limiting per IP/token

### Rate Limiting

**Current**: None (rely on Traefik rate limiting)

**Future**:
- Redis-based rate limiter
- 10 requests/minute per IP for `/contact`
- 100 requests/minute for authenticated `/contacts`

## Performance

### Async Operations

- **Supabase insert**: Async via `httpx` under the hood
- **Resend emails**: Fire-and-forget with `asyncio`
- **Non-blocking**: Email failures don't affect response time

### Scaling

- **Horizontal**: Add more containers behind Traefik
- **Vertical**: Increase uvicorn workers (current: 2)
- **Database**: Supabase scales independently

### Monitoring

**Current**:
- Docker logs: `docker logs api-smarterbot -f`
- Traefik access logs

**Future**:
- Prometheus metrics endpoint
- Grafana dashboard
- Sentry error tracking
- OpenTelemetry tracing

## Error Handling

```python
try:
    result = supabase.table("contacts").insert({...}).execute()
    if not result.data:
        raise HTTPException(status_code=500, detail="Failed to insert")
except Exception as e:
    raise HTTPException(status_code=500, detail=f"Database error: {str(e)}")
```

Emails are wrapped in try/except with silent failure (logged but not raised).

## Testing Strategy

### Manual Testing

```bash
# Health check
curl https://api.smarterbot.cl/health

# Submit contact
curl -X POST https://api.smarterbot.cl/contact \
  -H "Content-Type: application/json" \
  -d '{"name":"Test","email":"test@test.com","message":"Hello"}'

# List contacts
curl https://api.smarterbot.cl/contacts?limit=5
```

### Automated Testing (Future)

```python
# tests/test_contact.py
import pytest
from fastapi.testclient import TestClient
from main import app

client = TestClient(app)

def test_create_contact():
    response = client.post("/contact", json={
        "name": "Test User",
        "email": "test@example.com",
        "message": "Test message"
    })
    assert response.status_code == 201
    assert response.json()["ok"] == True
```

Run with: `pytest tests/`

## Deployment Process

1. **Build image**:
   ```bash
   cd /Users/mac/dev/2025/api.smarterbot.cl
   docker build -t api.smarterbot.cl:latest .
   ```

2. **Test locally**:
   ```bash
   docker run -d -p 8000:8000 --env-file .env api.smarterbot.cl:latest
   curl http://localhost:8000/health
   ```

3. **Deploy with docker-compose**:
   ```bash
   cd /Users/mac/dev/2025/dkcompose
   docker-compose up -d api-smarterbot
   ```

4. **Verify**:
   ```bash
   curl https://api.smarterbot.cl/health
   ```

5. **Check logs**:
   ```bash
   docker logs api-smarterbot -f
   ```

## Rollback Strategy

```bash
# Stop new version
docker-compose stop api-smarterbot

# Revert to previous image
docker tag api.smarterbot.cl:v0.9.0 api.smarterbot.cl:latest

# Restart
docker-compose up -d api-smarterbot
```

## Integration Points

### Frontend Integration

| Site | Path | Status |
|------|------|--------|
| smarterbot.cl | `/components/contact-section.tsx` | ✅ Updated |
| smarterbot.store | `/src/pages/Contact.tsx` | ✅ Updated |
| app.smarterbot.cl | N/A (admin panel) | - |

### Database Integration

- **Provider**: Supabase (PostgreSQL)
- **Table**: `public.contacts`
- **Access**: Service role key (bypasses RLS)
- **Connection**: Via `@supabase/supabase-js` Python SDK

### Email Integration

- **Provider**: Resend
- **API**: REST (`https://api.resend.com/emails`)
- **From**: `no-reply@smarterbot.cl` (verified domain)
- **To**: User email + admin email

### Future Integrations

- **n8n**: Webhook trigger on new contact
- **Chatwoot**: Auto-create conversation
- **Odoo**: Create CRM lead
- **Slack**: Admin notification

## Maintenance

### Log Rotation

```bash
# Docker logs can grow large
docker logs api-smarterbot --tail 100 > last100.log

# Configure log rotation in docker-compose
logging:
  driver: "json-file"
  options:
    max-size: "10m"
    max-file: "3"
```

### Database Cleanup

```sql
-- Archive old contacts (>1 year)
create table contacts_archive as
select * from contacts
where created_at < now() - interval '1 year';

delete from contacts
where created_at < now() - interval '1 year';
```

### Dependency Updates

```bash
# Check for updates
pip list --outdated

# Update requirements.txt
pip freeze > requirements.txt

# Rebuild image
docker-compose build api-smarterbot
```

## Troubleshooting

### Issue: CORS errors in browser

**Symptom**: `Access-Control-Allow-Origin` header missing

**Fix**: Verify origin in allowed list in `main.py`, check browser console for exact origin

### Issue: Database connection failed

**Symptom**: 500 error "Database not configured"

**Fix**: Check `SUPABASE_URL` and `SUPABASE_SERVICE_ROLE` env vars, verify Supabase project is active

### Issue: Emails not sending

**Symptom**: Contact created but no emails received

**Fix**: Check `RESEND_API_KEY` is set, verify domain in Resend dashboard, check Resend logs

### Issue: Container exits immediately

**Symptom**: `docker ps` shows no api-smarterbot container

**Fix**: Check logs with `docker logs api-smarterbot`, verify Python syntax errors, ensure all dependencies installed

## Metrics (Future)

```python
from prometheus_client import Counter, Histogram

contact_requests = Counter('contact_requests_total', 'Total contact form submissions')
contact_errors = Counter('contact_errors_total', 'Failed contact submissions')
request_duration = Histogram('request_duration_seconds', 'Request duration')
```

Expose at `/metrics` for Prometheus scraping.

## References

- FastAPI Documentation: https://fastapi.tiangolo.com
- Supabase Python SDK: https://supabase.com/docs/reference/python
- Resend API: https://resend.com/docs/api-reference
- Uvicorn: https://www.uvicorn.org
- Pydantic: https://docs.pydantic.dev
