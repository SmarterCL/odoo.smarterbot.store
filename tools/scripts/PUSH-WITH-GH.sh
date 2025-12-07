#!/bin/bash

echo "╔══════════════════════════════════════════════════════════════╗"
echo "║                                                              ║"
echo "║   🚀 Push a GitHub con gh CLI                                ║"
echo "║                                                              ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo ""

# Verificar que gh CLI está instalado
if ! command -v gh &> /dev/null; then
    echo "❌ gh CLI no está instalado"
    echo "Instalar con: sudo apt install gh"
    exit 1
fi

echo "📦 Repositorio: smarteros-specs"
echo "Remote: https://github.com/SmarterCL/smarteros-specs.git"
echo ""

# Verificar si ya está autenticado
if gh auth status &> /dev/null; then
    echo "✅ Ya estás autenticado en GitHub"
    gh auth status
    echo ""
else
    echo "🔐 Necesitas autenticarte con GitHub"
    echo ""
    echo "Opciones:"
    echo "1. Login con navegador (recomendado)"
    echo "2. Login con token"
    echo ""
    read -p "Selecciona opción (1/2): " -n 1 -r
    echo ""
    
    if [[ $REPLY == "1" ]]; then
        echo "🌐 Abriendo navegador para autenticación..."
        gh auth login -h github.com -p https -w
    else
        echo "🔑 Ingresa tu Personal Access Token:"
        read -s TOKEN
        echo ""
        echo "$TOKEN" | gh auth login -h github.com --with-token
    fi
fi

echo ""
echo "═══════════════════════════════════════════════════════════"
echo ""

# Cambiar al repo
cd /root/specs

echo "📊 Commits que se van a pushear:"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
git log origin/main..HEAD --oneline 2>/dev/null || git log --oneline -5
echo ""

read -p "¿Continuar con el push? (y/n): " -n 1 -r
echo ""

if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo ""
    echo "🚀 Ejecutando push..."
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    # Configurar git para usar gh como credential helper
    git config credential.helper ""
    git config credential.helper '!gh auth git-credential'
    
    # Hacer push
    git push origin main
    
    if [ $? -eq 0 ]; then
        echo ""
        echo "✅ Push completado exitosamente!"
        echo ""
        echo "🔗 Ver commits en GitHub:"
        echo "   https://github.com/SmarterCL/smarteros-specs/commits/main"
        echo ""
        echo "📊 Últimos commits pusheados:"
        git log origin/main~3..origin/main --oneline
    else
        echo ""
        echo "❌ Error en push"
        echo ""
        echo "💡 Troubleshooting:"
        echo "   1. Verifica que gh CLI esté autenticado: gh auth status"
        echo "   2. Verifica permisos del token"
        echo "   3. Intenta re-autenticar: gh auth login"
    fi
else
    echo ""
    echo "❌ Push cancelado"
fi

echo ""
echo "╔══════════════════════════════════════════════════════════════╗"
echo "║                                                              ║"
echo "║  Push completado - Ver estado en GitHub                     ║"
echo "║                                                              ║"
echo "╚══════════════════════════════════════════════════════════════╝"
