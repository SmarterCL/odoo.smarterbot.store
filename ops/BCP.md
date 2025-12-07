# SMARTEROS — BUSINESS CONTINUITY PLAN (BCP)
**Mantener operaciones críticas durante interrupciones**

---

## 1. Servicios Críticos (Tier 1)

- **API Gateway** - 99.9% uptime
- **PostgreSQL** - 99.95% uptime
- **Vault MCP** - 99.99% uptime
- **Odoo ERP** - 99.5% uptime
- **Chatwoot** - 99.5% uptime

---

## 2. Escenarios de Continuidad

### Corte Eléctrico Prolongado
**Mitigación:**
- UPS 30 min
- Generador 4h
- Migración cloud automática

### Caída DNS
**Mitigación:**
- Cloudflare multi-region
- Backup DNS (Route53)
- TTL bajo (300s)

### Caída WhatsApp
**Mitigación:**
- Fallback a Email
- Fallback a SMS
- Web widget activo

### DDoS Attack
**Mitigación:**
- Cloudflare DDoS Protection
- Rate limiting API
- IP whitelist para admin

---

## 3. Procedimientos de Failover

### API Gateway Failover
```bash
# Detectar caída
smarter health-check api

# Activar backup
smarter failover api enable

# Validar
curl https://api.smarterbot.cl/health
```

### Database Failover
```bash
# Promover replica a primary
pg_ctl promote -D /var/lib/postgresql/data

# Actualizar connection strings
smarter config update db_host=backup-db.smarterbot.cl
```

---

## 4. Comunicación durante Incidentes

### Status Page
- https://status.smarterbot.cl
- Actualizaciones cada 15 min

### Notificaciones
- Email a clientes afectados
- WhatsApp broadcast
- Twitter/LinkedIn

---

## 5. Timeframes

| Evento | Detección | Notificación | Mitigación | Recovery |
|--------|-----------|--------------|------------|----------|
| API Down | 2 min | 5 min | 10 min | 30 min |
| DB Down | 5 min | 10 min | 15 min | 60 min |
| DNS Issue | 1 min | 3 min | 5 min | 15 min |

---

**Owner:** DevOps Team  
**Review:** Mensual
