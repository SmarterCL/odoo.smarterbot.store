#!/bin/bash

echo "🔧 Accediendo a la base de datos de N8N para arreglar el credential..."

# Obtener el credential ID desde el workflow funcional
WORKFLOW_JSON=$(docker exec smarter-n8n n8n export:workflow --id=BWdJF4keyeKKIfaS --output=/dev/stdout 2>/dev/null)

# El credential debe estar en la DB de N8N, necesitamos acceder con SQL
docker exec smarter-n8n sh -c '
echo "📋 Listando credentials actuales..."
sqlite3 /home/node/.n8n/database.sqlite "SELECT id, name, type FROM credentials_entity WHERE type = \"githubApi\";"

echo ""
echo "🔧 Actualizando credential para permitir todos los dominios..."

# Obtener el credential actual
CRED_DATA=$(sqlite3 /home/node/.n8n/database.sqlite "SELECT data FROM credentials_entity WHERE type = \"githubApi\" LIMIT 1;")

# Actualizar para permitir todos los dominios
sqlite3 /home/node/.n8n/database.sqlite "UPDATE credentials_entity SET data = json_set(data, \"$.allowedRequestDomains\", \"allDomains\") WHERE type = \"githubApi\";"

echo ""
echo "✅ Credential actualizado"
echo ""
echo "Verificando..."
sqlite3 /home/node/.n8n/database.sqlite "SELECT id, name, json_extract(data, \"$.allowedRequestDomains\") as domains FROM credentials_entity WHERE type = \"githubApi\";"
'

echo ""
echo "🔄 Reiniciando N8N para aplicar cambios..."
docker restart smarter-n8n

echo ""
echo "⏳ Esperando que N8N reinicie (15 segundos)..."
sleep 15

echo ""
echo "✅ N8N reiniciado"
echo ""
echo "🔗 Ahora probá el workflow: https://n8n.smarterbot.cl/workflow/7DqvnlnY2CgdSkte"
echo ""
echo "👉 Click 'Execute Workflow' para test"
