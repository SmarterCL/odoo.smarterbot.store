#!/bin/bash

echo "╔══════════════════════════════════════════════════════════════╗"
echo "║                                                              ║"
echo "║   🚀 Push a GitHub - smarteros-specs                         ║"
echo "║                                                              ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo ""

cd /root/specs

echo "📦 Commits pendientes de push:"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
git log --oneline origin/main..HEAD 2>/dev/null | head -10
echo ""

echo "🔐 Para hacer push necesitas:"
echo "  1. Tu username de GitHub"
echo "  2. Un Personal Access Token (PAT)"
echo ""
echo "💡 Si no tienes PAT, créalo en:"
echo "   https://github.com/settings/tokens"
echo "   Scopes necesarios: repo, workflow"
echo ""

read -p "¿Deseas continuar con el push? (y/n): " -n 1 -r
echo ""

if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo ""
    echo "🚀 Ejecutando push..."
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    git push origin main
    
    if [ $? -eq 0 ]; then
        echo ""
        echo "✅ Push completado exitosamente!"
        echo ""
        echo "📊 Commits pusheados:"
        git log --oneline origin/main~5..origin/main
        echo ""
        echo "🔗 Ver en GitHub:"
        echo "   https://github.com/SmarterCL/smarteros-specs/commits/main"
    else
        echo ""
        echo "❌ Error en push. Verifica tus credenciales."
        echo ""
        echo "💡 Tip: Para guardar credenciales:"
        echo "   git config --global credential.helper store"
    fi
else
    echo ""
    echo "❌ Push cancelado."
    echo ""
    echo "💡 Para hacer push manualmente:"
    echo "   cd /root/specs"
    echo "   git push origin main"
fi

echo ""
echo "╔══════════════════════════════════════════════════════════════╗"
echo "║                                                              ║"
echo "║  Documentación completa en:                                  ║"
echo "║  /root/DEPLOYMENT-INSTRUCTIONS.md                            ║"
echo "║                                                              ║"
echo "╚══════════════════════════════════════════════════════════════╝"
