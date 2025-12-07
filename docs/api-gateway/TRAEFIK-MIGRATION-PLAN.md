# 🔄 Traefik Migration Plan - Forward Auth con Vault

**Razón:** Caddy no tiene soporte nativo para Forward Auth. Traefik sí.

## 🎯 Por qué Traefik

1. **ForwardAuth nativo** - Directiva `forwardAuth` incluida
2. **Más común para este patrón** - Docker + Auth + Multi-service
3. **Mejor documentación** para auth external
4. **Dynamic configuration** - Actualiza sin restart
5. **Middleware chains** - Más flexible para auth + rate limiting + CORS

## 📋 Plan de Migración

### Fase 1: Setup Traefik (30 min)

1. Crear `traefik.yml` configuration
2. Crear `docker-compose-traefik.yml`
3. Deploy Traefik container
4. Verificar dashboard

### Fase 2: Migrate Services (20 min)

1. Agregar labels de Traefik a cada servicio
2. Configurar routers y middlewares
3. Testing de cada ruta

### Fase 3: Forward Auth (15 min)

1. Configurar middleware forwardAuth
2. Apuntar a vault-auth-validator
3. Testing de autenticación

### Fase 4: SSL (10 min)

1. Configurar cert resolver (Let's Encrypt)
2. Testing HTTPS

### Total: ~1.5 horas

## 🔧 Configuración Traefik

### traefik.yml

\`\`\`yaml
api:
  dashboard: true
  insecure: true  # Solo para testing inicial

entryPoints:
  web:
    address: ":80"
    http:
      redirections:
        entryPoint:
          to: websecure
          scheme: https
  websecure:
    address: ":443"
    
providers:
  docker:
    exposedByDefault: false
    network: smarter-net

certificatesResolvers:
  letsencrypt:
    acme:
      email: admin@smarterbot.cl
      storage: /letsencrypt/acme.json
      httpChallenge:
        entryPoint: web
\`\`\`

### Forward Auth Middleware

\`\`\`yaml
http:
  middlewares:
    vault-auth:
      forwardAuth:
        address: "http://vault-auth-validator:8080/validate"
        authResponseHeaders:
          - "X-Vault-User"
          - "X-Vault-Policies"
\`\`\`

### Service Labels (ejemplo n8n)

\`\`\`yaml
services:
  n8n:
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.n8n-api.rule=Host(\`api.smarterbot.cl\`) && PathPrefix(\`/n8n\`)"
      - "traefik.http.routers.n8n-api.entrypoints=websecure"
      - "traefik.http.routers.n8n-api.tls.certresolver=letsencrypt"
      - "traefik.http.routers.n8n-api.middlewares=vault-auth@file"
      - "traefik.http.services.n8n-api.loadbalancer.server.port=5678"
\`\`\`

## 🆚 Comparación: Caddy vs Traefik

| Feature | Caddy | Traefik |
|---------|-------|---------|
| Auto HTTPS | ✅ Excelente | ✅ Bueno |
| Forward Auth | ❌ No nativo | ✅ Nativo |
| Docker Integration | ⚠️ Manual | ✅ Labels |
| Config Reload | ✅ Sin restart | ✅ Sin restart |
| Middlewares | ⚠️ Limitado | ✅ Completo |
| Dashboard | ❌ No | ✅ Sí |
| Learning Curve | ✅ Fácil | ⚠️ Media |

## 🚀 Decisión

**Opción A: Migrar a Traefik** (Recomendado)
- ✅ Forward Auth nativo
- ✅ Mejor para este use case
- ⏱️ 1.5 horas de trabajo
- ⚠️ Cambio de reverse proxy

**Opción B: Mantener Caddy + API Key simple**
- ✅ Sin migración
- ⏱️ 5 minutos
- ⚠️ No usa Vault
- ⚠️ No sigue specs de smarteros

**Opción C: Nginx + auth_request**
- ✅ auth_request nativo
- ⚠️ Configuración más compleja
- ⏱️ 2 horas

## 📝 Siguiente Paso

¿Proceder con migración a Traefik?

\`\`\`bash
# Quick start
cd /root
# Crear traefik.yml y docker-compose-traefik.yml
# Deploy
docker-compose -f docker-compose-traefik.yml up -d
\`\`\`

