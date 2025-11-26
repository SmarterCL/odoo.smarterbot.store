# SmarterOS Tools

Esta carpeta contiene toda la configuración operativa del VPS migrada al repo.

## Estructura

```
/tools
├── docker/         # docker-compose files
├── scripts/        # shell scripts de deployment
├── envs/           # archivos .env
├── n8n/            # configuración n8n
├── hostinger-mcp/  # MCP Hostinger
├── mcp/            # MCP custom
├── proxy/          # configs proxy
├── caddy/          # Caddy configs
├── traefik/        # Traefik configs
├── nginx/          # Nginx configs
└── login/          # login.smarterbot.store
```

## Uso

Para levantar el stack completo:

```bash
git clone https://github.com/SmarterCL/smarteros-specs
cd smarteros-specs
cp .env.example .env  # edita con tus valores
docker compose -f docker-compose.smarteros.yml up -d
```

## Migración desde VPS

Todos estos archivos fueron migrados automáticamente desde el VPS.
El VPS original debe quedar limpio después de esta migración.
