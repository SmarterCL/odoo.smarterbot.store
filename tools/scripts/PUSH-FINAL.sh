#!/bin/bash

echo "╔══════════════════════════════════════════════════════════════╗"
echo "║                                                              ║"
echo "║   🚀 Push Final a GitHub - smarteros-specs                   ║"
echo "║                                                              ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo ""

echo "�� Necesitas un GitHub Personal Access Token"
echo ""
echo "Si no lo tienes, créalo aquí:"
echo "🔗 https://github.com/settings/tokens/new"
echo ""
echo "Scopes necesarios: ✅ repo, ✅ workflow"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

read -sp "Pega tu GitHub token (ghp_xxx...): " TOKEN
echo ""

if [ -z "$TOKEN" ]; then
    echo ""
    echo "❌ No ingresaste ningún token"
    echo ""
    exit 1
fi

echo ""
echo "🔐 Autenticando con GitHub..."
echo "$TOKEN" | gh auth login --with-token 2>&1

if [ $? -eq 0 ]; then
    echo "✅ Autenticación exitosa"
    echo ""
    echo "📊 Commits que se van a pushear:"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    cd /root/specs
    git log origin/main..HEAD --oneline 2>/dev/null | head -11
    echo ""
    
    read -p "¿Continuar con el push? (y/n): " -n 1 -r
    echo ""
    
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo ""
        echo "🚀 Configurando git credential helper..."
        git config credential.helper '!gh auth git-credential'
        
        echo "🚀 Haciendo push a origin main..."
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        git push origin main
        
        if [ $? -eq 0 ]; then
            echo ""
            echo "╔══════════════════════════════════════════════════════════════╗"
            echo "║                                                              ║"
            echo "║   ✅  PUSH COMPLETADO EXITOSAMENTE                           ║"
            echo "║                                                              ║"
            echo "╚══════════════════════════════════════════════════════════════╝"
            echo ""
            echo "🔗 Ver commits en GitHub:"
            echo "   https://github.com/SmarterCL/smarteros-specs/commits/main"
            echo ""
            echo "📊 Últimos commits pusheados:"
            git log origin/main~5..origin/main --oneline
            echo ""
            
            # Guardar token en Vault (opcional)
            echo "💾 ¿Guardar token en Vault? (y/n): "
            read -n 1 -r
            echo ""
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                export VAULT_ADDR="http://127.0.0.1:8200"
                echo "$TOKEN" | vault kv put smarteros/github token=- 2>&1
                if [ $? -eq 0 ]; then
                    echo "✅ Token guardado en Vault"
                else
                    echo "⚠️  No se pudo guardar en Vault (necesita autenticación)"
                fi
            fi
        else
            echo ""
            echo "❌ Error en push"
            echo ""
            echo "💡 Verifica:"
            echo "   - Token tiene permisos correctos (repo, workflow)"
            echo "   - Token no ha expirado"
            echo "   - Tienes permisos en el repositorio"
        fi
    else
        echo ""
        echo "❌ Push cancelado"
    fi
else
    echo "❌ Error en autenticación"
    echo ""
    echo "💡 Verifica que el token sea correcto"
fi

echo ""
echo "╔══════════════════════════════════════════════════════════════╗"
echo "║                                                              ║"
echo "║  Script completado                                           ║"
echo "║                                                              ║"
echo "╚══════════════════════════════════════════════════════════════╝"
