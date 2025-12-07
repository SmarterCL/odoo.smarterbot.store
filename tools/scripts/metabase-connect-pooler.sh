#!/bin/bash

METABASE_URL="https://kpi.smarterbot.cl"

SESSION=$(curl -s -X POST "${METABASE_URL}/api/session" \
  -H "Content-Type: application/json" \
  -d '{"username":"smarterbotcl@gmail.com","password":"Chevrolet2025+"}' | jq -r '.id')

echo "🔐 Sesión: ${SESSION:0:25}..."

# Usando POOLER con puerto 5432 (transaction mode) + usuario completo
PAYLOAD='{
  "engine": "postgres",
  "name": "SmarterOS Database",
  "details": {
    "host": "aws-0-us-east-1.pooler.supabase.com",
    "port": 5432,
    "dbname": "postgres",
    "user": "postgres.rjfcmmzjlguiititkmyh",
    "password": "RctbsgNqeUeEIO9e",
    "schema-filters-type": "inclusion",
    "schema-filters-patterns": "public",
    "ssl": true,
    "ssl-mode": "require"
  }
}'

echo "📡 Conectando vía Pooler (transaction mode)..."
RESPONSE=$(curl -s -X POST "${METABASE_URL}/api/database" \
  -H "Content-Type: application/json" \
  -H "X-Metabase-Session: ${SESSION}" \
  -d "$PAYLOAD")

echo "$RESPONSE" | jq '.'

DB_ID=$(echo "$RESPONSE" | jq -r '.id // empty')

if [ ! -z "$DB_ID" ] && [ "$DB_ID" != "null" ]; then
  echo "✅ ¡METABASE CONECTADO A SUPABASE! ID: $DB_ID"
  
  echo "🔄 Sincronizando tablas..."
  curl -s -X POST "${METABASE_URL}/api/database/${DB_ID}/sync_schema" \
    -H "X-Metabase-Session: ${SESSION}"
  
  sleep 5
  
  echo "📊 Estado:"
  curl -s -X GET "${METABASE_URL}/api/database/${DB_ID}" \
    -H "X-Metabase-Session: ${SESSION}" | jq '{id, name, engine, initial_sync_status}'
  
  echo ""
  echo "✅ CONEXIÓN EXITOSA!"
  echo "🎯 Accede a: https://kpi.smarterbot.cl"
else
  echo "❌ Error:"
  echo "$RESPONSE" | jq '.message // .'
fi
