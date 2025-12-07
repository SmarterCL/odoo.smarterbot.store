# Migración de Traefik a Caddy

## ✅ Archivos Generados

1. **Caddyfile** - Configuración principal de Caddy
2. **docker-compose-caddy.yml** - Docker Compose para Caddy
3. **migrate-to-caddy.sh** - Script de migración automatizado

## 📋 Servicios Configurados

| Servicio | Dominio | Backend | Puerto |
|----------|---------|---------|--------|
| Metabase | kpi.smarterbot.cl | smarteros-metabase | 3000 |
| Chatwoot | chatwoot.smarterbot.cl | smarter-chatwoot | 3000 |
| Botpress | chat.smarterbot.cl | smarter-botpress | 3000 |
| n8n | n8n.smarterbot.cl | smarter-n8n | 5678 |
| Odoo | odoo.smarterbot.cl | smarter-odoo | 8069 |
| Portainer | portainer.smarterbot.cl | smarter-portainer | 9000 |
| Dokploy | dokploy.smarterbot.cl | dokploy | 3000 |
| Nexa AI | ai.smarterbot.store | nexa-server | 8000 |

## 🚀 Proceso de Migración

### Opción 1: Migración Automática (Recomendada)

```bash
cd /root
./migrate-to-caddy.sh
```

El script hace:
1. ✓ Valida el Caddyfile
2. ✓ Crea backup de Traefik
3. ✓ Inicia Caddy en puertos alternativos (8080, 8443)
4. ✓ Espera certificados SSL
5. ✓ Detiene Traefik
6. ✓ Cambia Caddy a puertos estándar (80, 443)
7. ✓ Verifica todos los servicios

### Opción 2: Migración Manual

#### Paso 1: Validar Configuración
```bash
docker run --rm -v "$PWD/Caddyfile:/etc/caddy/Caddyfile" caddy:2-alpine caddy validate --config /etc/caddy/Caddyfile
```

#### Paso 2: Backup de Traefik
```bash
mkdir -p backups
docker logs root-traefik-1 > backups/traefik-logs-$(date +%Y%m%d).log
docker inspect root-traefik-1 > backups/traefik-config-$(date +%Y%m%d).json
```

#### Paso 3: Detener Traefik
```bash
docker-compose -f docker-compose-traefik.yml down
```

#### Paso 4: Iniciar Caddy
```bash
docker-compose -f docker-compose-caddy.yml up -d
```

#### Paso 5: Verificar Logs
```bash
docker logs -f caddy-proxy
```

## 🔍 Verificación Post-Migración

```bash
# Ver estado
docker ps | grep caddy

# Ver logs
docker logs -f caddy-proxy

# Probar endpoints
curl -I https://kpi.smarterbot.cl
curl -I https://chatwoot.smarterbot.cl
curl -I https://n8n.smarterbot.cl
```

## 🎯 Ventajas de Caddy

✅ **Certificados SSL automáticos** - Sin configuración manual
✅ **HTTP/3 support** - Mejor performance
✅ **Configuración simple** - Más legible que Traefik
✅ **Menor uso de memoria** - Más eficiente
✅ **Renovación automática** - Sin downtime
✅ **Logs estructurados** - Mejor debugging

## 📝 Comandos Útiles

```bash
# Ver configuración activa
docker exec caddy-proxy caddy config

# Recargar configuración (sin downtime)
docker exec caddy-proxy caddy reload --config /etc/caddy/Caddyfile

# Ver certificados
docker exec caddy-proxy ls -lh /data/caddy/certificates

# Logs en tiempo real
docker logs -f caddy-proxy

# Reiniciar Caddy
docker-compose -f docker-compose-caddy.yml restart

# Detener Caddy
docker-compose -f docker-compose-caddy.yml down
```

## 🔄 Rollback a Traefik

Si algo sale mal:

```bash
# Detener Caddy
docker-compose -f docker-compose-caddy.yml down

# Restaurar Traefik
docker-compose -f docker-compose-traefik.yml up -d

# Verificar
docker logs -f root-traefik-1
```

## ⚙️ Personalización del Caddyfile

### Agregar nuevo servicio:
```caddy
nuevo.smarterbot.cl {
    reverse_proxy container-name:port
    encode gzip
    log {
        output file /var/log/caddy/nuevo.log
    }
}
```

### Agregar autenticación básica:
```caddy
admin.smarterbot.cl {
    reverse_proxy service:port
    basicauth {
        admin $2a$14$hash...
    }
}
```

### Agregar rate limiting:
```caddy
api.smarterbot.cl {
    reverse_proxy service:port
    rate_limit {
        zone api {
            key {remote_host}
            events 100
            window 1m
        }
    }
}
```

## 📊 Monitoring

Caddy expone métricas en formato Prometheus:

```caddy
# Agregar al Caddyfile (bloque global)
{
    servers {
        metrics
    }
}
```

Acceso: `http://localhost:2019/metrics`

## 🐛 Troubleshooting

### Certificados no se generan
```bash
# Ver logs detallados
docker logs caddy-proxy 2>&1 | grep -i "certificate\|acme\|error"

# Verificar DNS
dig +short kpi.smarterbot.cl
```

### Puerto 80/443 en uso
```bash
# Ver qué usa los puertos
sudo netstat -tulpn | grep -E ":80|:443"

# Detener Traefik primero
docker stop root-traefik-1
```

### Servicio no responde
```bash
# Verificar conectividad de red
docker exec caddy-proxy ping smarteros-metabase

# Ver redes conectadas
docker network inspect root_traefik-network
```

## 📧 Soporte

- Logs: `/var/log/caddy/` dentro del contenedor
- Documentación Caddy: https://caddyserver.com/docs/
- Email configurado: admin@smarterbot.cl

---

**Fecha de creación:** 2025-11-18
**Versión Caddy:** 2-alpine
**Estado:** ✅ Listo para migración
