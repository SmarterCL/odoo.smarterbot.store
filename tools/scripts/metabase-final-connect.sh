#!/bin/bash

METABASE_URL="https://kpi.smarterbot.cl"

SESSION=$(curl -s -X POST "${METABASE_URL}/api/session" \
  -H "Content-Type: application/json" \
  -d '{"username":"smarterbotcl@gmail.com","password":"Chevrolet2025+"}' | jq -r '.id')

echo "🔐 Session: ${SESSION:0:20}..."

# Conexión sin additional-options
PAYLOAD=$(cat << 'PAYLOAD'
{
  "engine": "postgres",
  "name": "SmarterOS Database",
  "details": {
    "host": "db.rjfcmmzjlguiititkmyh.supabase.co",
    "port": 5432,
    "dbname": "postgres",
    "user": "postgres",
    "password": "RctbsgNqeUeEIO9e",
    "schema-filters-type": "inclusion",
    "schema-filters-patterns": "public",
    "ssl": true,
    "ssl-mode": "require"
  }
}
PAYLOAD
)

echo "📡 Conectando Supabase..."
RESPONSE=$(curl -s -X POST "${METABASE_URL}/api/database" \
  -H "Content-Type: application/json" \
  -H "X-Metabase-Session: ${SESSION}" \
  -d "$PAYLOAD")

echo "$RESPONSE" | jq '.'

DB_ID=$(echo "$RESPONSE" | jq -r '.id // empty')

if [ ! -z "$DB_ID" ] && [ "$DB_ID" != "null" ]; then
  echo "✅ ¡CONECTADO! ID: $DB_ID"
  
  # Trigger sync
  echo "🔄 Sincronizando schema..."
  curl -s -X POST "${METABASE_URL}/api/database/${DB_ID}/sync_schema" \
    -H "X-Metabase-Session: ${SESSION}"
  
  sleep 3
  
  # Check status
  echo "📊 Estado de la base de datos:"
  curl -s -X GET "${METABASE_URL}/api/database/${DB_ID}" \
    -H "X-Metabase-Session: ${SESSION}" | jq '{name, engine, initial_sync_status}'
  
  echo "✅ Metabase + Supabase conectados!"
else
  echo "❌ Error en la conexión"
  echo "$RESPONSE" | jq '.message // .errors // .'
fi
