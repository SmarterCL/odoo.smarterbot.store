#!/bin/bash

echo "📥 Exportando workflow recién creado..."
docker exec smarter-n8n n8n export:workflow --id=7DqvnlnY2CgdSkte --output=/tmp/new-workflow.json 2>/dev/null

echo "📥 Extrayendo credential del workflow funcional..."
docker exec smarter-n8n cat /tmp/working-workflow.json > /tmp/working.json

# Extraer credential ID
CRED_ID=$(cat /tmp/working.json | grep -oP '"githubApi":\s*{\s*"id":\s*"\K[^"]+' | head -1)
CRED_NAME=$(cat /tmp/working.json | grep -oP '"githubApi":\s*{[^}]*"name":\s*"\K[^"]+' | head -1)

echo "✅ Credential encontrado:"
echo "   ID: $CRED_ID"
echo "   Name: $CRED_NAME"
echo ""

if [ -z "$CRED_ID" ]; then
  echo "❌ No se pudo obtener el credential ID"
  echo ""
  echo "📋 SOLUCIÓN MANUAL:"
  echo "1. Ir a: https://n8n.smarterbot.cl/workflow/7DqvnlnY2CgdSkte"
  echo "2. Click en cada nodo que dice 'Credentials not found'"
  echo "3. Seleccionar el credential de GitHub"
  echo "4. Save"
  exit 1
fi

echo "🔄 Actualizando nuevo workflow con credential correcto..."
docker exec smarter-n8n cat /tmp/new-workflow.json | \
  sed "s/\"REPLACE_WITH_YOUR_CREDENTIAL_ID\"/\"$CRED_ID\"/g" | \
  sed "s/\"GitHub API\"/\"$CRED_NAME\"/g" > /tmp/updated-workflow.json

# Copiar de vuelta al contenedor
docker cp /tmp/updated-workflow.json smarter-n8n:/tmp/

echo "📤 Eliminando workflow actual..."
docker exec smarter-n8n n8n remove:workflow --id=7DqvnlnY2CgdSkte 2>/dev/null

echo "📥 Importando workflow actualizado..."
docker exec smarter-n8n n8n import:workflow --input=/tmp/updated-workflow.json 2>&1 | grep -v "Permissions\|trust proxy"

echo ""
echo "✅ ¡Workflow actualizado con credentials!"
echo ""
echo "🔗 Abrir en: https://n8n.smarterbot.cl/workflow/7DqvnlnY2CgdSkte"
echo ""
echo "🧪 Ahora puedes hacer test manual"

