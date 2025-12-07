#!/bin/bash
# VALIDACIÓN RÁPIDA - Estado de Archivos Generados
# Ejecutar en el VPS para verificar que todo está listo

set -e

echo "🔍 SmarterOS - Validación de Archivos Generados"
echo "================================================"
echo ""

# Colores
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

ERRORS=0
WARNINGS=0

check_file() {
    local file=$1
    local description=$2
    
    if [ -f "$file" ]; then
        local size=$(wc -c < "$file")
        echo -e "${GREEN}✅ $description${NC}"
        echo -e "   📄 $(basename $file) (${size} bytes)"
    else
        echo -e "${RED}❌ $description${NC}"
        echo -e "   ⚠️  Archivo no encontrado: $file"
        ((ERRORS++))
    fi
}

check_executable() {
    local file=$1
    local description=$2
    
    if [ -f "$file" ]; then
        if [ -x "$file" ]; then
            echo -e "${GREEN}✅ $description (ejecutable)${NC}"
        else
            echo -e "${YELLOW}⚠️  $description (no ejecutable)${NC}"
            ((WARNINGS++))
        fi
    else
        echo -e "${RED}❌ $description (no encontrado)${NC}"
        ((ERRORS++))
    fi
}

echo "Verificando archivos en /root/..."
echo ""

# Archivos principales de unificación
echo "📦 Archivos de Unificación:"
check_file "/root/SMARTEROS-UNIFICACION-COMPLETA.md" "Documento maestro de arquitectura"
check_file "/root/smarteros-unified-components.tar.gz.txt" "Componentes listos para copiar"
check_file "/root/GUIA-SETUP-MAC.md" "Guía paso a paso para Mac"
check_file "/root/CHECKLIST-VALIDACION-SMARTEROS.md" "Checklist de validación"
check_file "/root/RESUMEN-EJECUTIVO-UNIFICACION.md" "Resumen ejecutivo"
echo ""

# Scripts
echo "🔧 Scripts:"
check_executable "/root/setup-smarteros-unification.sh" "Script de setup automático"
echo ""

# Archivos de configuración
echo "⚙️  Archivos de Configuración:"
check_file "/root/CLERK-CREDENTIALS.txt" "Credenciales de Clerk"
check_file "/root/automation-manifest.json" "Catálogo de workflows"
check_file "/root/api-gateway.env" "Variables de entorno API Gateway"
echo ""

# Verificar contenido de archivos críticos
echo "🔍 Validando contenido de archivos críticos..."
echo ""

# SMARTEROS-UNIFICACION-COMPLETA.md
if [ -f "/root/SMARTEROS-UNIFICACION-COMPLETA.md" ]; then
    if grep -q "UnifiedLogin" "/root/SMARTEROS-UNIFICACION-COMPLETA.md" && \
       grep -q "SmarterOSAssistant" "/root/SMARTEROS-UNIFICACION-COMPLETA.md" && \
       grep -q "Demo 24h" "/root/SMARTEROS-UNIFICACION-COMPLETA.md"; then
        echo -e "${GREEN}✅ SMARTEROS-UNIFICACION-COMPLETA.md contiene todas las secciones${NC}"
    else
        echo -e "${YELLOW}⚠️  SMARTEROS-UNIFICACION-COMPLETA.md puede estar incompleto${NC}"
        ((WARNINGS++))
    fi
fi

# smarteros-unified-components.tar.gz.txt
if [ -f "/root/smarteros-unified-components.tar.gz.txt" ]; then
    if grep -q "UnifiedLogin.tsx" "/root/smarteros-unified-components.tar.gz.txt" && \
       grep -q "SmarterOSAssistant.tsx" "/root/smarteros-unified-components.tar.gz.txt" && \
       grep -q "/api/workflows/route.ts" "/root/smarteros-unified-components.tar.gz.txt"; then
        echo -e "${GREEN}✅ smarteros-unified-components.tar.gz.txt contiene todos los componentes${NC}"
    else
        echo -e "${YELLOW}⚠️  smarteros-unified-components.tar.gz.txt puede estar incompleto${NC}"
        ((WARNINGS++))
    fi
fi

# automation-manifest.json
if [ -f "/root/automation-manifest.json" ]; then
    if jq empty "/root/automation-manifest.json" 2>/dev/null; then
        workflow_count=$(jq '.workflows | length' "/root/automation-manifest.json")
        echo -e "${GREEN}✅ automation-manifest.json válido (${workflow_count} workflows)${NC}"
    else
        echo -e "${RED}❌ automation-manifest.json tiene JSON inválido${NC}"
        ((ERRORS++))
    fi
fi

echo ""
echo "================================================"

# Resumen
if [ $ERRORS -eq 0 ] && [ $WARNINGS -eq 0 ]; then
    echo -e "${GREEN}✅ TODOS LOS ARCHIVOS ESTÁN LISTOS${NC}"
    echo ""
    echo "Próximos pasos:"
    echo "1. En tu Mac, descargar archivos:"
    echo "   cd ~/dev/2025"
    echo "   scp root@164.92.118.28:/root/setup-smarteros-unification.sh ."
    echo "   scp root@164.92.118.28:/root/SMARTEROS-UNIFICACION-COMPLETA.md ."
    echo "   scp root@164.92.118.28:/root/smarteros-unified-components.tar.gz.txt ."
    echo "   scp root@164.92.118.28:/root/GUIA-SETUP-MAC.md ."
    echo "   scp root@164.92.118.28:/root/CHECKLIST-VALIDACION-SMARTEROS.md ."
    echo "   scp root@164.92.118.28:/root/RESUMEN-EJECUTIVO-UNIFICACION.md ."
    echo ""
    echo "2. Ejecutar script de setup:"
    echo "   chmod +x setup-smarteros-unification.sh"
    echo "   ./setup-smarteros-unification.sh"
    echo ""
    echo "3. Seguir guía:"
    echo "   open GUIA-SETUP-MAC.md"
    echo ""
elif [ $ERRORS -eq 0 ] && [ $WARNINGS -gt 0 ]; then
    echo -e "${YELLOW}⚠️  ARCHIVOS LISTOS CON ${WARNINGS} ADVERTENCIA(S)${NC}"
    echo ""
    echo "Puedes continuar, pero revisa las advertencias arriba."
    echo ""
else
    echo -e "${RED}❌ FALTAN ${ERRORS} ARCHIVO(S) CRÍTICO(S)${NC}"
    echo ""
    echo "Acción requerida: Regenerar archivos faltantes"
    echo ""
fi

# Información adicional
echo "================================================"
echo ""
echo "📊 Información del Sistema:"
echo "   Hostname: $(hostname)"
echo "   IP: $(hostname -I | awk '{print $1}')"
echo "   User: $(whoami)"
echo "   Fecha: $(date '+%Y-%m-%d %H:%M:%S')"
echo ""

# Verificar servicios relacionados
echo "🔌 Estado de Servicios:"

# N8N
if docker ps | grep -q "n8n"; then
    echo -e "${GREEN}✅ N8N corriendo${NC}"
else
    echo -e "${YELLOW}⚠️  N8N no detectado${NC}"
fi

# Caddy
if docker ps | grep -q "caddy"; then
    echo -e "${GREEN}✅ Caddy corriendo${NC}"
else
    echo -e "${YELLOW}⚠️  Caddy no detectado${NC}"
fi

# API Gateway
if docker ps | grep -q "api-gateway"; then
    echo -e "${GREEN}✅ API Gateway corriendo${NC}"
else
    echo -e "${YELLOW}⚠️  API Gateway no detectado${NC}"
fi

echo ""
echo "================================================"
echo ""

if [ $ERRORS -eq 0 ]; then
    echo -e "${GREEN}✅ Validación completada exitosamente${NC}"
    exit 0
else
    echo -e "${RED}❌ Validación completada con errores${NC}"
    exit 1
fi
