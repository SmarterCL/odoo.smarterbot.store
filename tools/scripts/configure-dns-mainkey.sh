#!/bin/bash

echo "╔══════════════════════════════════════════════════════════════╗"
echo "║                                                              ║"
echo "║   🔐 Configurar DNS para mainkey (Vault) - Dual Domain       ║"
echo "║                                                              ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo ""

# Variables
IP="89.116.23.167"
SUBDOMAIN="mainkey"

# Dominios a configurar
DOMAIN1="smarterbot.cl"
FULL_DOMAIN1="${SUBDOMAIN}.${DOMAIN1}"

DOMAIN2="smarterbot.store"
FULL_DOMAIN2="${SUBDOMAIN}.${DOMAIN2}"

echo "📝 Configuración:"
echo "   ${FULL_DOMAIN1} → ${IP}"
echo "   ${FULL_DOMAIN2} → ${IP}"
echo "   Servicio: Vault (SmarterOS Key Management)"
echo ""

# Solicitar API Token
read -sp "Ingresa tu Cloudflare API Token: " CF_TOKEN
echo ""
echo ""

if [ -z "$CF_TOKEN" ]; then
    echo "❌ No ingresaste ningún token"
    exit 1
fi

# Función para configurar DNS
configure_dns() {
    local DOMAIN=$1
    local FULL_DOMAIN=$2
    
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "🔍 Configurando ${FULL_DOMAIN}..."
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    echo "🔍 Buscando Zone ID de ${DOMAIN}..."
    ZONE_ID=$(curl -s -X GET "https://api.cloudflare.com/client/v4/zones?name=${DOMAIN}" \
      -H "Authorization: Bearer ${CF_TOKEN}" \
      -H "Content-Type: application/json" | jq -r '.result[0].id')
    
    if [ "$ZONE_ID" = "null" ] || [ -z "$ZONE_ID" ]; then
        echo "❌ No se encontró la zona ${DOMAIN}"
        echo "⚠️  Verifica que el dominio esté en Cloudflare"
        return 1
    fi
    
    echo "✅ Zone ID: ${ZONE_ID}"
    
    echo "🔍 Verificando si el registro DNS ya existe..."
    RECORD_ID=$(curl -s -X GET "https://api.cloudflare.com/client/v4/zones/${ZONE_ID}/dns_records?name=${FULL_DOMAIN}&type=A" \
      -H "Authorization: Bearer ${CF_TOKEN}" \
      -H "Content-Type: application/json" | jq -r '.result[0].id')
    
    if [ "$RECORD_ID" != "null" ] && [ ! -z "$RECORD_ID" ]; then
        echo "⚠️  Registro DNS ya existe (ID: ${RECORD_ID})"
        echo "🔄 Actualizando registro existente..."
        
        RESPONSE=$(curl -s -X PUT "https://api.cloudflare.com/client/v4/zones/${ZONE_ID}/dns_records/${RECORD_ID}" \
          -H "Authorization: Bearer ${CF_TOKEN}" \
          -H "Content-Type: application/json" \
          --data "{\"type\":\"A\",\"name\":\"${FULL_DOMAIN}\",\"content\":\"${IP}\",\"ttl\":1,\"proxied\":false}")
        
        SUCCESS=$(echo $RESPONSE | jq -r '.success')
        
        if [ "$SUCCESS" = "true" ]; then
            echo "✅ Registro DNS actualizado: ${FULL_DOMAIN} → ${IP}"
        else
            echo "❌ Error al actualizar ${FULL_DOMAIN}:"
            echo $RESPONSE | jq '.'
            return 1
        fi
    else
        echo "➕ Creando nuevo registro DNS..."
        
        RESPONSE=$(curl -s -X POST "https://api.cloudflare.com/client/v4/zones/${ZONE_ID}/dns_records" \
          -H "Authorization: Bearer ${CF_TOKEN}" \
          -H "Content-Type: application/json" \
          --data "{\"type\":\"A\",\"name\":\"${FULL_DOMAIN}\",\"content\":\"${IP}\",\"ttl\":1,\"proxied\":false}")
        
        SUCCESS=$(echo $RESPONSE | jq -r '.success')
        
        if [ "$SUCCESS" = "true" ]; then
            echo "✅ Registro DNS creado: ${FULL_DOMAIN} → ${IP}"
        else
            echo "❌ Error al crear ${FULL_DOMAIN}:"
            echo $RESPONSE | jq '.'
            return 1
        fi
    fi
    
    return 0
}

# Configurar ambos dominios
configure_dns "${DOMAIN1}" "${FULL_DOMAIN1}"
RESULT1=$?

configure_dns "${DOMAIN2}" "${FULL_DOMAIN2}"
RESULT2=$?

echo ""
echo "╔══════════════════════════════════════════════════════════════╗"
echo "║                                                              ║"
echo "║   ✅  CONFIGURACIÓN DNS COMPLETADA                           ║"
echo "║                                                              ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo ""

if [ $RESULT1 -eq 0 ]; then
    echo "✅ ${FULL_DOMAIN1} → ${IP}"
else
    echo "❌ ${FULL_DOMAIN1} - Error en configuración"
fi

if [ $RESULT2 -eq 0 ]; then
    echo "✅ ${FULL_DOMAIN2} → ${IP}"
else
    echo "❌ ${FULL_DOMAIN2} - Error en configuración"
fi

echo ""
echo "╔══════════════════════════════════════════════════════════════╗"
echo "║   Servicio: Vault Key Management                            ║"
echo "║   Proxy: Disabled (DNS only - Direct IP)                    ║"
echo "║   SSL: Será gestionado por Caddy                            ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo ""
echo "🕐 Esperando propagación DNS (1-5 minutos)..."
echo ""
echo "🧪 Verificar propagación:"
echo "   dig ${FULL_DOMAIN1} +short"
echo "   dig ${FULL_DOMAIN2} +short"
echo ""
echo "🔐 Acceso a Vault (después de configurar Caddy):"
echo "   https://${FULL_DOMAIN1}"
echo "   https://${FULL_DOMAIN2}"
echo ""
