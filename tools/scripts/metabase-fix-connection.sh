#!/bin/bash

METABASE_URL="https://kpi.smarterbot.cl"

# Login
SESSION_TOKEN=$(curl -s -X POST "${METABASE_URL}/api/session" \
  -H "Content-Type: application/json" \
  -d '{"username":"smarterbotcl@gmail.com","password":"Chevrolet2025+"}' | jq -r '.id')

echo "✅ Token: ${SESSION_TOKEN:0:30}..."

# Payload CORRECTO para Supabase
PAYLOAD='{
  "engine": "postgres",
  "name": "SmarterDB Supabase",
  "details": {
    "host": "db.rjfcmmzjlguiititkmyh.supabase.co",
    "port": 5432,
    "dbname": "postgres",
    "user": "postgres",
    "password": "RctbsgNqeUeEIO9e",
    "schema-filters-type": "inclusion",
    "schema-filters-patterns": "public",
    "ssl": true,
    "ssl-mode": "require",
    "additional-options": "prepareThreshold=0&sslmode=require"
  }
}'

echo "📡 Creando conexión..."
RESULT=$(curl -s -w "\nHTTP_CODE:%{http_code}" -X POST "${METABASE_URL}/api/database" \
  -H "Content-Type: application/json" \
  -H "X-Metabase-Session: ${SESSION_TOKEN}" \
  -d "$PAYLOAD")

HTTP_CODE=$(echo "$RESULT" | grep "HTTP_CODE" | cut -d: -f2)
BODY=$(echo "$RESULT" | sed '/HTTP_CODE/d')

echo "$BODY" | jq '.'

if [ "$HTTP_CODE" == "200" ]; then
  DB_ID=$(echo "$BODY" | jq -r '.id')
  echo "✅ ÉXITO! Database ID: $DB_ID"
  
  # Sync
  curl -s -X POST "${METABASE_URL}/api/database/${DB_ID}/sync_schema" \
    -H "X-Metabase-Session: ${SESSION_TOKEN}"
  echo "🔄 Sync iniciado"
else
  echo "❌ Error HTTP $HTTP_CODE"
fi
