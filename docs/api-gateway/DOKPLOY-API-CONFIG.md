# Configuración Dokploy API - SmarterBot

**Fecha:** 2025-11-19
**Servidor:** 89.116.23.167

## 📍 Dominios Configurados

| Dominio | Estado | SSL | DNS Provider |
|---------|--------|-----|--------------|
| api.smarterbot.cl | ✅ Activo | ✅ Let's Encrypt | Cloudflare (sin proxy) |
| api.smarterbot.store | ✅ Activo | ✅ Let's Encrypt | Hostinger |

## 🌐 Configuración DNS en Cloudflare

### smarterbot.cl (COMPLETADO ✅)
```
Tipo:    A
Nombre:  api
IPv4:    89.116.23.167
Proxy:   Desactivado (nube gris ☁️)
TTL:     Auto
```

### smarterbot.store (PENDIENTE ⏳) - HOSTINGER
```
Tipo:    A
Nombre:  api
Apunta a: 89.116.23.167
TTL:     14400 (o por defecto)
```

**Pasos para configurar en Hostinger:**
1. Ir a https://hpanel.hostinger.com
2. Login → Dominios → smarterbot.store
3. DNS / Name Servers → Manage
4. Add New Record / Agregar registro
5. Configurar según los datos arriba
6. Guardar (propagación: 5-15 minutos típicamente)

## ⚙️ Configuración Caddy

**Archivo:** `/root/Caddyfile`

```caddyfile
# Dokploy API - Deployment API
api.smarterbot.cl, api.smarterbot.store {
    reverse_proxy dokploy:3000 {
        header_up X-Forwarded-Proto {scheme}
        header_up X-Forwarded-For {remote_host}
        header_up X-Real-IP {remote_host}
    }
    encode gzip
    
    header {
        X-Frame-Options "SAMEORIGIN"
        X-Content-Type-Options "nosniff"
        Referrer-Policy "strict-origin-when-cross-origin"
    }
    
    log {
        output file /var/log/caddy/api.log
    }
}
```

## 🔧 Backend

- **Container:** dokploy
- **Puerto:** 3000
- **Red:** smarter-net
- **Servidor:** 89.116.23.167

## 🔐 SSL/TLS

- **Proveedor:** Let's Encrypt (automático)
- **Renovación:** Automática cada 60 días
- **Validación:** HTTP-01 challenge
- **Gestión:** Caddy automático

## 📊 Endpoints API

### api.smarterbot.cl (Activo)
```
https://api.smarterbot.cl/
https://api.smarterbot.cl/api/auth/login
https://api.smarterbot.cl/api/auth/register
https://api.smarterbot.cl/api/projects
https://api.smarterbot.cl/api/deployments
```

### api.smarterbot.store (Tras configurar DNS)
```
https://api.smarterbot.store/
https://api.smarterbot.store/api/auth/login
https://api.smarterbot.store/api/projects
https://api.smarterbot.store/api/deployments
```

## 🧪 Comandos de Verificación

### Verificar DNS
```bash
dig api.smarterbot.store +short
```

### Probar conectividad HTTP
```bash
curl -I http://89.116.23.167 -H "Host: api.smarterbot.store"
```

### Probar HTTPS
```bash
curl -I https://api.smarterbot.store/
```

### Ver logs
```bash
# Logs Caddy
docker logs caddy-proxy --tail 50 | grep api.smarterbot

# Logs API específicos
docker exec caddy-proxy tail -f /var/log/caddy/api.log

# Logs Dokploy
docker logs -f dokploy
```

### Verificar certificado SSL
```bash
echo | openssl s_client -connect api.smarterbot.store:443 \
  -servername api.smarterbot.store 2>/dev/null | \
  openssl x509 -noout -dates
```

### Recargar configuración Caddy
```bash
docker exec caddy-proxy caddy reload --config /etc/caddy/Caddyfile
```

### Reiniciar Caddy (si necesario)
```bash
docker restart caddy-proxy
```

## ⚠️ Notas Importantes

1. **Proxy Cloudflare:** Debe estar DESACTIVADO (nube gris) para que Let's Encrypt valide el dominio
2. **Después del SSL:** Puedes activar proxy si deseas, pero NO recomendado para APIs
3. **Propagación DNS:** 2-5 minutos típicamente
4. **Obtención SSL:** Automática cuando Caddy detecta tráfico HTTPS
5. **Rate Limits:** Let's Encrypt tiene límites de 5 intentos fallidos/hora

## 🔒 Seguridad

- Headers de seguridad configurados
- X-Frame-Options: SAMEORIGIN
- X-Content-Type-Options: nosniff
- Referrer-Policy: strict-origin-when-cross-origin
- Logs habilitados para auditoría
- Compresión gzip habilitada

## 📝 Historial

- **2025-11-19 12:15:** Configurado api.smarterbot.cl ✅
- **2025-11-19 12:30:** SSL activo para api.smarterbot.cl ✅
- **2025-11-19 12:33:** Agregado api.smarterbot.store a Caddyfile ✅
- **2025-11-19 12:36:** Configurado DNS en Hostinger para api.smarterbot.store ✅
- **2025-11-19 12:36:** SSL activo para api.smarterbot.store ✅
- **2025-11-19 12:36:** ✅ AMBOS DOMINIOS OPERATIVOS

## ✅ Checklist Próximos Pasos

- [x] Configurar DNS para api.smarterbot.store en Hostinger
- [x] Verificar propagación DNS
- [x] Confirmar obtención automática de SSL
- [x] Probar endpoints API
- [ ] Documentar credenciales de acceso (separadamente)
- [ ] Configurar monitoreo de uptime
- [ ] Implementar rate limiting si necesario

---

**Mantenido por:** SmarterBot DevOps Team
**Última actualización:** 2025-11-19 12:33 UTC
