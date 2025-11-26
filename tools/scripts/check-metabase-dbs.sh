#!/bin/bash

METABASE_URL="https://kpi.smarterbot.cl"

SESSION=$(curl -s -X POST "${METABASE_URL}/api/session" \
  -H "Content-Type: application/json" \
  -d '{"username":"smarterbotcl@gmail.com","password":"Chevrolet2025+"}' | jq -r '.id')

echo "📊 Databases actuales en Metabase:"
curl -s -X GET "${METABASE_URL}/api/database" \
  -H "X-Metabase-Session: ${SESSION}" | jq '.data[] | {id, name, engine, details}'

