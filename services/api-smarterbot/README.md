# api.smarterbot.cl - FastAPI Contact Service

FastAPI microservice for unified contact form submissions across all Smarter OS web properties.

## Overview

Replaces Next.js API routes with a dedicated Python FastAPI service for better:
- **Separation of concerns**: Independent from frontend deployments
- **Performance**: Async Python with uvicorn workers
- **Scalability**: Easy horizontal scaling in Docker/Kubernetes
- **Extensibility**: Foundation for ML/AI endpoints

## Architecture

```
┌─────────────────┐     ┌─────────────────┐
│ smarterbot.cl   │────▶│                 │
├─────────────────┤     │  api.smarterbot │──▶ Supabase (contacts table)
│smarterbot.store │────▶│  :8000          │
└─────────────────┘     │                 │──▶ Resend (emails)
                        └─────────────────┘
```

## Endpoints

| Method | Path | Description |
|--------|------|-------------|
| GET | `/` | Service info |
| GET | `/health` | Health check with dependency status |
| POST | `/contact` | Submit contact form |
| GET | `/contacts` | List contacts (requires auth in production) |
| GET | `/docs` | Interactive API documentation (Swagger UI) |
| GET | `/redoc` | Alternative API docs (ReDoc) |

## Repository Structure

```
api.smarterbot.cl/
├── main.py              # FastAPI application
├── Dockerfile           # Container definition
├── requirements.txt     # Python dependencies
├── .env.example         # Environment variables template
├── .gitignore          # Git ignore rules
└── README.md           # This file
```

## Dependencies

```
fastapi==0.115.5         # Web framework
uvicorn[standard]==0.32.1 # ASGI server
pydantic[email]==2.10.3  # Data validation
supabase==2.10.0         # Supabase client
httpx==0.28.1            # Async HTTP client
python-dotenv==1.0.1     # Environment variables
```

## Environment Variables

| Variable | Required | Default | Description |
|----------|----------|---------|-------------|
| `SUPABASE_URL` | ✅ | - | Supabase project URL |
| `SUPABASE_SERVICE_ROLE` | ✅ | - | Service role key (bypasses RLS) |
| `RESEND_API_KEY` | ⚠️ | - | Resend API key (email won't work without it) |
| `RESEND_FROM` | ❌ | `no-reply@smarterbot.cl` | From email address |
| `ADMIN_EMAIL` | ❌ | `smarterbotcl@gmail.com` | Admin notification email |

## Quick Start

### Local Development

```bash
# Navigate to service directory
cd /Users/mac/dev/2025/api.smarterbot.cl

# Install dependencies
pip install -r requirements.txt

# Create .env file
cp .env.example .env
# Edit .env with your credentials

# Run server
uvicorn main:app --reload --port 8000

# Visit http://localhost:8000/docs
```

### Docker

```bash
# Build image
docker build -t api.smarterbot.cl .

# Run container
docker run -d \
  -p 8000:8000 \
  --env-file .env \
  --name api-smarterbot \
  api.smarterbot.cl
```

### Docker Compose (Production)

Service already configured in `dkcompose/docker-compose.yml`:

```yaml
services:
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
      - RESEND_FROM=${RESEND_FROM:-no-reply@smarterbot.cl}
      - ADMIN_EMAIL=${ADMIN_EMAIL:-smarterbotcl@gmail.com}
    networks:
      - smarter-net
      - dokploy-network
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.api-smarterbot.rule=Host(`api.smarterbot.cl`)"
      - "traefik.http.routers.api-smarterbot.entrypoints=websecure"
      - "traefik.http.routers.api-smarterbot.tls=true"
      - "traefik.http.routers.api-smarterbot.tls.certresolver=letsencrypt"
      - "traefik.http.services.api-smarterbot.loadbalancer.server.port=8000"
```

Deploy:
```bash
cd /Users/mac/dev/2025/dkcompose
docker-compose up -d api-smarterbot
```

## API Usage

### Submit Contact Form

**Request:**
```bash
curl -X POST https://api.smarterbot.cl/contact \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Juan Pérez",
    "email": "juan@example.com",
    "message": "Necesito automatizar mi facturación",
    "phone": "+56912345678",
    "source": "smarterbot.cl"
  }'
```

**Response:**
```json
{
  "ok": true,
  "message": "Contact submitted successfully"
}
```

**Validation:**
- `name`: 1-200 characters (required)
- `email`: Valid email format (required)
- `message`: 1-5000 characters (required)
- `phone`: 0-50 characters (optional)
- `source`: 0-100 characters (optional)

### Health Check

**Request:**
```bash
curl https://api.smarterbot.cl/health
```

**Response:**
```json
{
  "status": "healthy",
  "supabase": "configured",
  "resend": "configured"
}
```

## Frontend Integration

### smarterbot.cl

Updated in `components/contact-section.tsx`:

```typescript
const res = await fetch("https://api.smarterbot.cl/contact", {
  method: "POST",
  headers: { "Content-Type": "application/json" },
  body: JSON.stringify({
    name,
    email,
    message,
    phone,
    source: "smarterbot.cl",
  }),
})
```

### smarterbot.store

Updated in `src/pages/Contact.tsx`:

```typescript
const res = await fetch('https://api.smarterbot.cl/contact', {
  method: 'POST',
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify({
    name,
    email,
    message: body,
    phone,
    source: 'smarterbot.store'
  }),
})
```

## Database Schema

Requires `contacts` table in Supabase:

```sql
create table public.contacts (
  id uuid default gen_random_uuid() primary key,
  name text not null,
  email text not null,
  message text not null,
  phone text,
  source text,
  domain text,
  status text default 'new',
  created_at timestamp with time zone default now()
);

alter table public.contacts enable row level security;

-- Service role bypasses RLS, so no policies needed for API
```

SQL file: `smarteros-specs/integrations/supabase/sql/contacts.sql`

## Email Templates

### User Confirmation Email

Subject: `Gracias por contactar a Smarter OS`

Content:
- Personalized greeting
- Message confirmation
- Link to app.smarterbot.cl
- Branding footer

### Admin Notification Email

Subject: `Nuevo contacto: [Name] <[Email]>`

Content:
- Contact details table (name, email, phone, source, domain)
- Full message body
- Clean HTML formatting

## Monitoring

### Logs

```bash
# View container logs
docker logs api-smarterbot -f

# Filter by log level
docker logs api-smarterbot 2>&1 | grep ERROR
```

### Metrics

Uvicorn provides:
- Request count
- Response times
- Error rates

Consider adding:
- Prometheus metrics endpoint
- Grafana dashboard
- Sentry error tracking

## CORS Configuration

Allowed origins:
- `https://smarterbot.cl`
- `https://www.smarterbot.cl`
- `https://smarterbot.store`
- `https://www.smarterbot.store`
- `https://app.smarterbot.cl`
- `http://localhost:3000` (development)
- `http://localhost:5173` (development)

## Security

- ✅ HTTPS enforced via Traefik
- ✅ CORS restricted to known domains
- ✅ Input validation via Pydantic
- ✅ SQL injection protection via Supabase client
- ✅ Service role key (not exposed to client)
- ⚠️ `/contacts` endpoint should add authentication

## Performance

- **Workers**: 2 uvicorn workers (configurable in Dockerfile)
- **Async I/O**: Non-blocking Supabase + Resend calls
- **Email**: Fire-and-forget (doesn't block response)
- **Timeout**: 5s for email requests

## Troubleshooting

### Container won't start

```bash
# Check logs
docker logs api-smarterbot

# Verify environment variables
docker exec api-smarterbot env | grep SUPABASE
```

### Database connection fails

- Verify `SUPABASE_URL` format: `https://xxx.supabase.co`
- Check `SUPABASE_SERVICE_ROLE` key is correct
- Ensure `contacts` table exists with correct schema

### Emails not sending

- Verify `RESEND_API_KEY` is set
- Check Resend dashboard for error logs
- Confirm `RESEND_FROM` domain is verified in Resend

### CORS errors in browser

- Check origin is in allowed list in `main.py`
- Verify frontend is using correct URL (`https://api.smarterbot.cl`)
- Check browser console for specific error

## Deployment Status

| Environment | Status | URL | Commit |
|-------------|--------|-----|--------|
| Development | ⏳ Pending | http://localhost:8000 | - |
| Production | ⏳ Pending | https://api.smarterbot.cl | - |

## Changelog

### 2025-11-22 - v1.0.0
- ✅ Initial FastAPI service
- ✅ POST `/contact` endpoint
- ✅ GET `/contacts` endpoint
- ✅ GET `/health` endpoint
- ✅ Supabase integration
- ✅ Resend email integration
- ✅ CORS configuration
- ✅ Docker configuration
- ✅ Docker Compose integration
- ✅ Frontend migration (smarterbot.cl + smarterbot.store)

## Future Enhancements

- [ ] Authentication for `/contacts` endpoint (Clerk/Supabase Auth)
- [ ] Rate limiting (Redis-based)
- [ ] Webhook support for CRM integrations
- [ ] CSV export endpoint
- [ ] Prometheus metrics
- [ ] Sentry error tracking
- [ ] Unit tests (pytest)
- [ ] Load tests (locust)

## Related Documentation

- `smarteros-specs/integrations/supabase/sql/contacts.sql` - Database schema
- `smarteros-specs/vault/policies/specs-pass-read.hcl` - Vault access policy
- `smarteros-specs/integrations/chatwoot/setup-chatwoot.sh` - Chatwoot integration
- `dkcompose/docker-compose.yml` - Full stack deployment

## Support

For issues or questions:
- GitHub: https://github.com/SmarterCL/api.smarterbot.cl (pending creation)
- Email: smarterbotcl@gmail.com
