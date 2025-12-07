#!/bin/bash

# Script para subir automation-manifest.json al repo n8n-workflows

echo "📤 Subiendo automation-manifest.json al repo..."
echo ""

# Verificar que existe el repo
if [ ! -d "/root/repos/n8n-workflows" ]; then
  echo "❌ El repo n8n-workflows no existe en /root/repos/"
  echo ""
  echo "Clonando el repo..."
  mkdir -p /root/repos
  cd /root/repos
  git clone https://github.com/SmarterCL/n8n-workflows.git
fi

cd /root/repos/n8n-workflows

# Pull latest
echo "🔄 Pulling latest changes..."
git pull origin main

# Copiar manifest
echo "📋 Copying automation-manifest.json..."
cp /root/automation-manifest.json ./automation-manifest.json

# Verificar el archivo
echo ""
echo "✅ Archivo copiado. Verificando..."
ls -lh automation-manifest.json

# Git add
git add automation-manifest.json

# Verificar cambios
echo ""
echo "📊 Cambios detectados:"
git diff --cached --stat

# Commit
echo ""
echo "💾 Creando commit..."
git commit -m "feat: Add automation manifest for API integration

- 13 workflows organizados por categoría
- Endpoints definidos para API Gateway
- Metadata completa (tags, triggers, schedules)
- Integración con Dashboard, N8N y MCP
- Categorías: odoo, shopify, marketing, whatsapp, pdf, crm, backup

Permite:
- Lectura desde api.smarterbot.cl
- Lectura desde app.smarterbot.cl
- Lectura desde MCP tools
- Búsqueda por categoría/tags
- Ejecución programática
"

# Push
echo ""
echo "🚀 Pushing to GitHub..."
git push origin main

echo ""
echo "✅ Manifest subido exitosamente!"
echo ""
echo "🔗 Verificar en:"
echo "   https://github.com/SmarterCL/n8n-workflows/blob/main/automation-manifest.json"
echo ""

