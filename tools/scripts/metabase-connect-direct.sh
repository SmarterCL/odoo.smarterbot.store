#!/bin/bash

METABASE_URL="https://kpi.smarterbot.cl"
METABASE_USER="smarterbotcl@gmail.com"
METABASE_PASS="Chevrolet2025+"

# Login
echo "🔐 Autenticando..."
SESSION_TOKEN=$(curl -s -X POST "${METABASE_URL}/api/session" \
  -H "Content-Type: application/json" \
  -d "{\"username\":\"${METABASE_USER}\",\"password\":\"${METABASE_PASS}\"}" | jq -r '.id')

echo "✅ Sesión: ${SESSION_TOKEN:0:20}..."

# Conexión DIRECTA (sin pooler)
echo "📡 Conectando a Supabase (directo)..."

CONNECTION_PAYLOAD='{
  "engine": "postgres",
  "name": "SmarterDB",
  "details": {
    "host": "db.rjfcmmzjlguiititkmyh.supabase.co",
    "port": 5432,
    "dbname": "postgres",
    "user": "postgres",
    "password": "RctbsgNqeUeEIO9e",
    "schema-filters-type": "inclusion",
    "schema-filters-patterns": "public,auth",
    "ssl": true,
    "ssl-mode": "require",
    "tunnel-enabled": false,
    "additional-options": "prepareThreshold=0"
  },
  "auto_run_queries": true,
  "is_full_sync": true
}'

RESPONSE=$(curl -s -X POST "${METABASE_URL}/api/database" \
  -H "Content-Type: application/json" \
  -H "X-Metabase-Session: ${SESSION_TOKEN}" \
  -d "$CONNECTION_PAYLOAD")

echo "📊 Respuesta:"
echo "$RESPONSE" | jq '.'

DB_ID=$(echo "$RESPONSE" | jq -r '.id')

if [ "$DB_ID" != "null" ] && [ ! -z "$DB_ID" ]; then
  echo "✅ CONECTADO! DB ID: $DB_ID"
  
  # Sync
  curl -s -X POST "${METABASE_URL}/api/database/${DB_ID}/sync_schema" \
    -H "X-Metabase-Session: ${SESSION_TOKEN}"
  
  echo "🔄 Sincronización iniciada"
else
  echo "❌ Error:"
  echo "$RESPONSE" | jq '.message // .errors // .'
fi

curl -s -X DELETE "${METABASE_URL}/api/session" \
  -H "X-Metabase-Session: ${SESSION_TOKEN}"
