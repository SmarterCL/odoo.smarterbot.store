#!/bin/bash

# Script para conectar Metabase con Supabase vía API
# Usando connection string completo

METABASE_URL="https://kpi.smarterbot.cl"
METABASE_USER="smarterbotcl@gmail.com"
METABASE_PASS="Chevrolet2025+"

# 1. Login y obtener session token
echo "🔐 Authenticando en Metabase..."
SESSION_TOKEN=$(curl -s -X POST "${METABASE_URL}/api/session" \
  -H "Content-Type: application/json" \
  -d "{\"username\":\"${METABASE_USER}\",\"password\":\"${METABASE_PASS}\"}" | jq -r '.id')

if [ "$SESSION_TOKEN" == "null" ] || [ -z "$SESSION_TOKEN" ]; then
  echo "❌ Error: No se pudo autenticar en Metabase"
  exit 1
fi

echo "✅ Sesión obtenida: ${SESSION_TOKEN:0:20}..."

# 2. Crear conexión a Supabase usando connection string
echo "📡 Creando conexión a Supabase..."

# Usando el pooler connection (port 6543)
CONNECTION_PAYLOAD='{
  "engine": "postgres",
  "name": "SmarterDB",
  "details": {
    "host": "aws-0-us-east-1.pooler.supabase.com",
    "port": 6543,
    "dbname": "postgres",
    "user": "postgres.rjfcmmzjlguiititkmyh",
    "password": "RctbsgNqeUeEIO9e",
    "schema-filters-type": "inclusion",
    "schema-filters-patterns": "public,auth",
    "ssl": true,
    "ssl-mode": "require",
    "tunnel-enabled": false,
    "advanced-options": false,
    "let-user-control-scheduling": true
  },
  "auto_run_queries": true,
  "is_full_sync": true,
  "is_on_demand": false,
  "schedules": {
    "metadata_sync": {
      "schedule_day": null,
      "schedule_frame": null,
      "schedule_hour": 0,
      "schedule_type": "hourly"
    }
  }
}'

RESPONSE=$(curl -s -X POST "${METABASE_URL}/api/database" \
  -H "Content-Type: application/json" \
  -H "X-Metabase-Session: ${SESSION_TOKEN}" \
  -d "$CONNECTION_PAYLOAD")

echo "📊 Respuesta de Metabase:"
echo "$RESPONSE" | jq '.'

# Verificar si la conexión fue exitosa
DB_ID=$(echo "$RESPONSE" | jq -r '.id')

if [ "$DB_ID" != "null" ] && [ ! -z "$DB_ID" ]; then
  echo "✅ Base de datos conectada exitosamente! ID: $DB_ID"
  
  # Trigger sync
  echo "🔄 Iniciando sincronización..."
  curl -s -X POST "${METABASE_URL}/api/database/${DB_ID}/sync_schema" \
    -H "X-Metabase-Session: ${SESSION_TOKEN}"
  
  echo "✅ Sincronización iniciada"
else
  echo "❌ Error al conectar la base de datos"
  echo "$RESPONSE" | jq '.message // .errors'
fi

# Logout
curl -s -X DELETE "${METABASE_URL}/api/session" \
  -H "X-Metabase-Session: ${SESSION_TOKEN}"

echo "✅ Proceso completado"
