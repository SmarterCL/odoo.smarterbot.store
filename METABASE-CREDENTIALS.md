# 🔐 METABASE CREDENTIALS — SmarterOS

**CONFIDENTIAL - Internal Use Only**

---

## 🌐 Acceso Web

**URL:** https://kpi.smarterbot.cl

**Admin User:**
- Email: smarterbotcl@gmail.com
- Password: Chevrolet2025+

---

## 🗄️ Conexión Database (Supabase)

**Engine:** PostgreSQL  
**Connection Type:** Pooler (Transactional)

```json
{
  "host": "aws-0-us-east-1.pooler.supabase.com",
  "port": 6543,
  "database": "postgres",
  "user": "postgres.rjfcmmzjlguiititkmyh",
  "password": "RctbsgNqeUeEIO9e",
  "ssl_mode": "require",
  "additional_options": "sslmode=require&prepareThreshold=0"
}
```

**Connection String:**
```
postgresql://postgres.rjfcmmzjlguiititkmyh:RctbsgNqeUeEIO9e@aws-0-us-east-1.pooler.supabase.com:6543/postgres?sslmode=require&prepareThreshold=0
```

---

## 🔑 API Authentication

**Session Token:** (Generated after login)

```bash
# Login to get session token
curl -X POST https://kpi.smarterbot.cl/api/session \
  -H "Content-Type: application/json" \
  -d '{
    "username": "smarterbotcl@gmail.com",
    "password": "Chevrolet2025+"
  }'
```

---

## 📊 Schemas Enabled

- `public` (main application data)
- `auth` (Supabase authentication)
- `storage` (file storage metadata)

**Excluded schemas:**
- `pg_*` (PostgreSQL internals)
- `information_schema`
- `extensions`

---

## 🔐 Vault Path

**Production:**
```
/secret/metabase/prod/
├── admin_email
├── admin_password
├── db_host
├── db_port
├── db_name
├── db_user
├── db_password
└── embedding_secret_key
```

---

**Last Updated:** 2025-11-23  
**Status:** ✅ Active and Connected
