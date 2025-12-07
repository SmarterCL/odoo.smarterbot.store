# SMARTEROS — DISASTER RECOVERY PLAN (DRP)  
**Nivel: Enterprise Class – Tier III**

---

## 1. Objetivo
Garantizar que SmarterOS pueda recuperarse completamente ante cualquier evento catastrófico en un tiempo máximo de 2 horas (objetivo interno).

---

## 2. Alcance
El DRP cubre todos los servicios críticos:

- API Gateway
- Odoo ERP
- Chatwoot CRM
- Botpress AI Layer
- n8n Automations
- PostgreSQL
- Vault MCP
- Caddy SSL Reverse Proxy
- Metabase
- Dokploy DevOps

---

## 3. RTO / RPO  
| Módulo | RTO | RPO |
|--------|-----|-----|
| API Gateway | 10 min | 1 min |
| Odoo ERP | 25 min | 5 min |
| PostgreSQL | 35 min | 5 min |
| Chatwoot CRM | 15 min | 5 min |
| Botpress | 20 min | 10 min |
| n8n | 20 min | 10 min |
| Vault | 5 min | 0 min |
| Metabase | 15 min | 10 min |

---

## 4. Eventos cubiertos

### Desastres físicos
- VPS inaccesible  
- Caída del datacenter Hostinger  
- Falla eléctrica prolongada  

### Desastres lógicos
- Borrado accidental de datos  
- Corrupción de archivos  
- Fallo en Docker networks  

### Ataques
- Ransomware  
- SQL Injection  
- Credential compromise  
- Acceso no autorizado  
- Exfiltración de datos  

---

## 5. Procedimiento general DR

### 1. Declaración de desastre  
Se declara cuando:
- 2 módulos críticos no responden  
- Latencia > 60s en API  
- Base de datos inaccesible  

### 2. Activar DRP
```bash
smarter failover activate
```

### 3. Reconstrucción
1. Descargar último snapshot  
2. Iniciar contenedores base  
3. Restaurar PostgreSQL  
4. Restaurar Vault  
5. Restaurar n8n workflows  
6. Reconectar tenants (RUT)

### 4. Validaciones
- Test `/health`  
- Test tenants sample  
- Test Shopify/Odoo sync  
- Test WhatsApp → Chatwoot  

### 5. Declaración de servicio restablecido  
```bash
smarter status
smarter audit
```

---

## 6. Backups

### PostgreSQL (cada 1h)
```bash
pg_dump -U odoo postgres > pg_$(date +%F-%H).sql
aws s3 cp pg_$(date +%F-%H).sql s3://smarteros-backups/postgres/
```

### Vault (cada 1h)
```bash
vault operator raft snapshot save vault_$(date +%F-%H).snap
aws s3 cp vault_$(date +%F-%H).snap s3://smarteros-backups/vault/
```

### Botpress (cada 12h)
```bash
rsync -av /bp/data /backups/botpress/
```

### Odoo Filestore (cada 4h)
```bash
tar -czf odoo_filestore_$(date +%F-%H).tar.gz /var/lib/odoo/filestore
```

---

## 7. DR TEST (cada 30 días)
Realizar test simulado:

1. Apagar API
2. Apagar Odoo
3. Restaurar desde snapshots
4. Validar tenants
5. Validar catálogos

**Última prueba:** 2025-11-15  
**Próxima prueba:** 2025-12-15

---

## 8. Escenarios específicos

### Escenario 1: VPS Hostinger caído
```bash
# 1. Provisionar nuevo VPS
hetzner-cli create-server --name smarteros-backup --type cx21

# 2. Restaurar desde S3
aws s3 sync s3://smarteros-backups/ /recovery/

# 3. Docker compose up
cd /recovery && docker-compose up -d

# 4. Actualizar DNS
cloudflare-cli dns update smarterbot.cl A 192.168.1.1
```

### Escenario 2: PostgreSQL corrupto
```bash
# 1. Detener servicios
docker-compose stop odoo chatwoot n8n

# 2. Restaurar último backup válido
pg_restore -U postgres -d postgres pg_2025-11-23-12.sql

# 3. Verificar integridad
psql -U postgres -c "SELECT count(*) FROM tenants;"

# 4. Reiniciar servicios
docker-compose start odoo chatwoot n8n
```

### Escenario 3: Vault comprometido
```bash
# 1. Sellar Vault inmediatamente
vault operator seal

# 2. Rotar todas las keys
vault operator rekey

# 3. Re-unseal con nuevas keys
vault operator unseal

# 4. Audit logs
vault audit list
```

---

## 9. Contactos de emergencia

| Rol | Nombre | Contacto |
|-----|--------|----------|
| Disaster Manager | Pedro Zaffuto | +56 9 7954 0471 |
| Backup Owner | DevOps Team | ops@smarterbot.cl |
| Security Officer | InfoSec | security@smarterbot.cl |
| Incident Commander | CTO | cto@smarterbot.cl |
| Hostinger Support | - | support@hostinger.com |
| Cloudflare Support | - | support@cloudflare.com |

---

## 10. Checklist Post-Recovery

- [ ] Todos los contenedores UP
- [ ] API Gateway responde `/health`
- [ ] PostgreSQL conexiones OK
- [ ] Vault unsealed
- [ ] SSL certificados válidos
- [ ] DNS resuelve correctamente
- [ ] 3 tenants de prueba validados
- [ ] Shopify webhooks funcionando
- [ ] WhatsApp → Chatwoot OK
- [ ] Logs rotando correctamente
- [ ] Backups automáticos reiniciados
- [ ] Monitoreo activo
- [ ] Incidente documentado

---

**Última actualización:** 2025-11-23  
**Versión:** 1.0  
**Owner:** Pedro Zaffuto
