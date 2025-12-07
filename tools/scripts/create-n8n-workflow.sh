#!/bin/bash

echo "🚀 Creando Workflow en N8N via API"
echo "===================================="
echo ""

# Variables
N8N_URL="https://n8n.smarterbot.cl"
WORKFLOW_FILE="/root/n8n-workflow-complete.json"

echo "📋 N8N URL: $N8N_URL"
echo "📁 Workflow File: $WORKFLOW_FILE"
echo ""

# Verificar que existe el archivo
if [ ! -f "$WORKFLOW_FILE" ]; then
  echo "❌ Error: No se encuentra el archivo del workflow"
  exit 1
fi

echo "✅ Archivo del workflow encontrado"
echo ""

# Intentar crear el workflow via API
echo "🔄 Intentando crear workflow via API..."
echo ""

# Nota: N8N API requiere autenticación
# Necesitamos el API key o las credenciales

echo "⚠️  Para crear el workflow via API necesitamos:"
echo ""
echo "1. API Key de N8N"
echo "   - Se configura en N8N → Settings → API"
echo "   - Variable: N8N_API_KEY"
echo ""
echo "2. O usar n8n CLI dentro del contenedor"
echo ""
echo "📝 ALTERNATIVA - Importar via Web UI:"
echo ""
echo "1. Copiar el contenido del workflow:"
echo "   cat /root/n8n-workflow-complete.json"
echo ""
echo "2. Ir a: https://n8n.smarterbot.cl"
echo ""
echo "3. Click '+' → 'Import from Text/JSON'"
echo ""
echo "4. Pegar y hacer Import"
echo ""

# Verificar si tenemos acceso al contenedor
N8N_CONTAINER=$(docker ps --filter "name=n8n" --format "{{.Names}}" | head -1)

if [ -n "$N8N_CONTAINER" ]; then
  echo "✅ Contenedor N8N encontrado: $N8N_CONTAINER"
  echo ""
  echo "🔧 Intentando importar via CLI en el contenedor..."
  echo ""
  
  # Copiar archivo al contenedor
  docker cp "$WORKFLOW_FILE" "$N8N_CONTAINER:/tmp/workflow.json"
  
  # Intentar importar usando n8n CLI
  docker exec $N8N_CONTAINER n8n import:workflow --input=/tmp/workflow.json 2>&1
  
  if [ $? -eq 0 ]; then
    echo ""
    echo "✅ Workflow importado exitosamente!"
    echo ""
    echo "🔗 Ver en: https://n8n.smarterbot.cl/workflows"
  else
    echo ""
    echo "⚠️  El comando CLI no funcionó. Opciones:"
    echo ""
    echo "1. Importar manualmente via Web UI"
    echo "2. Configurar N8N API Key"
    echo "3. Usar el workflow funcional como base"
  fi
else
  echo "❌ No se encontró contenedor de N8N"
  echo ""
  echo "📝 Por favor importa manualmente:"
  echo "   https://n8n.smarterbot.cl → '+' → 'Import from Text/JSON'"
fi

echo ""
echo "═══════════════════════════════════════════════════════════"
echo ""

