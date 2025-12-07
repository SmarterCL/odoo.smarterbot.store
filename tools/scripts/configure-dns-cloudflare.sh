#!/bin/bash

echo "╔══════════════════════════════════════════════════════════════╗"
echo "║                                                              ║"
echo "║   🌐 Configurar DNS en Cloudflare                            ║"
echo "║                                                              ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo ""

# Variables
DOMAIN="smarterbot.cl"
SUBDOMAIN="mcp"
FULL_DOMAIN="${SUBDOMAIN}.${DOMAIN}"
IP="89.116.23.167"

echo "📝 Configuración:"
echo "   Dominio: ${FULL_DOMAIN}"
echo "   IP: ${IP}"
echo ""

# Solicitar API Token
read -sp "Ingresa tu Cloudflare API Token: " CF_TOKEN
echo ""
echo ""

if [ -z "$CF_TOKEN" ]; then
    echo "❌ No ingresaste ningún token"
    exit 1
fi

echo "🔍 Buscando Zone ID de ${DOMAIN}..."
ZONE_ID=$(curl -s -X GET "https://api.cloudflare.com/client/v4/zones?name=${DOMAIN}" \
  -H "Authorization: Bearer ${CF_TOKEN}" \
  -H "Content-Type: application/json" | jq -r '.result[0].id')

if [ "$ZONE_ID" = "null" ] || [ -z "$ZONE_ID" ]; then
    echo "❌ No se encontró la zona ${DOMAIN}"
    echo "Verifica que el token tenga permisos y que el dominio esté en Cloudflare"
    exit 1
fi

echo "✅ Zone ID: ${ZONE_ID}"
echo ""

echo "🔍 Verificando si el registro DNS ya existe..."
RECORD_ID=$(curl -s -X GET "https://api.cloudflare.com/client/v4/zones/${ZONE_ID}/dns_records?name=${FULL_DOMAIN}&type=A" \
  -H "Authorization: Bearer ${CF_TOKEN}" \
  -H "Content-Type: application/json" | jq -r '.result[0].id')

if [ "$RECORD_ID" != "null" ] && [ ! -z "$RECORD_ID" ]; then
    echo "⚠️  Registro DNS ya existe"
    echo "🔄 Actualizando registro existente..."
    
    RESPONSE=$(curl -s -X PUT "https://api.cloudflare.com/client/v4/zones/${ZONE_ID}/dns_records/${RECORD_ID}" \
      -H "Authorization: Bearer ${CF_TOKEN}" \
      -H "Content-Type: application/json" \
      --data "{\"type\":\"A\",\"name\":\"${FULL_DOMAIN}\",\"content\":\"${IP}\",\"ttl\":1,\"proxied\":true}")
    
    SUCCESS=$(echo $RESPONSE | jq -r '.success')
    
    if [ "$SUCCESS" = "true" ]; then
        echo "✅ Registro DNS actualizado"
    else
        echo "❌ Error al actualizar:"
        echo $RESPONSE | jq '.'
        exit 1
    fi
else
    echo "➕ Creando nuevo registro DNS..."
    
    RESPONSE=$(curl -s -X POST "https://api.cloudflare.com/client/v4/zones/${ZONE_ID}/dns_records" \
      -H "Authorization: Bearer ${CF_TOKEN}" \
      -H "Content-Type: application/json" \
      --data "{\"type\":\"A\",\"name\":\"${FULL_DOMAIN}\",\"content\":\"${IP}\",\"ttl\":1,\"proxied\":true}")
    
    SUCCESS=$(echo $RESPONSE | jq -r '.success')
    
    if [ "$SUCCESS" = "true" ]; then
        echo "✅ Registro DNS creado"
    else
        echo "❌ Error al crear:"
        echo $RESPONSE | jq '.'
        exit 1
    fi
fi

echo ""
echo "╔══════════════════════════════════════════════════════════════╗"
echo "║                                                              ║"
echo "║   ✅  DNS CONFIGURADO                                        ║"
echo "║                                                              ║"
echo "║   ${FULL_DOMAIN} → ${IP}                           ║"
echo "║                                                              ║"
echo "║   Cloudflare Proxy: Enabled (SSL automático)                ║"
echo "║                                                              ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo ""
echo "🕐 Esperando propagación DNS (puede tardar 1-5 minutos)..."
echo ""
echo "🧪 Probar:"
echo "   dig ${FULL_DOMAIN} +short"
echo "   curl -I https://${FULL_DOMAIN}"
echo ""

# Opcional: también configurar mcp.smarterbot.store
read -p "¿Configurar también mcp.smarterbot.store? (y/n): " -n 1 -r
echo ""
if [[ $REPLY =~ ^[Yy]$ ]]; then
    DOMAIN2="smarterbot.store"
    FULL_DOMAIN2="${SUBDOMAIN}.${DOMAIN2}"
    
    echo ""
    echo "🔍 Buscando Zone ID de ${DOMAIN2}..."
    ZONE_ID2=$(curl -s -X GET "https://api.cloudflare.com/client/v4/zones?name=${DOMAIN2}" \
      -H "Authorization: Bearer ${CF_TOKEN}" \
      -H "Content-Type: application/json" | jq -r '.result[0].id')
    
    if [ "$ZONE_ID2" != "null" ] && [ ! -z "$ZONE_ID2" ]; then
        echo "✅ Zone ID: ${ZONE_ID2}"
        
        echo "➕ Creando registro DNS para ${FULL_DOMAIN2}..."
        RESPONSE2=$(curl -s -X POST "https://api.cloudflare.com/client/v4/zones/${ZONE_ID2}/dns_records" \
          -H "Authorization: Bearer ${CF_TOKEN}" \
          -H "Content-Type: application/json" \
          --data "{\"type\":\"A\",\"name\":\"${FULL_DOMAIN2}\",\"content\":\"${IP}\",\"ttl\":1,\"proxied\":true}")
        
        SUCCESS2=$(echo $RESPONSE2 | jq -r '.success')
        
        if [ "$SUCCESS2" = "true" ]; then
            echo "✅ Registro DNS creado para ${FULL_DOMAIN2}"
        else
            echo "⚠️  Error al crear ${FULL_DOMAIN2}:"
            echo $RESPONSE2 | jq '.'
        fi
    else
        echo "⚠️  No se encontró la zona ${DOMAIN2}"
    fi
fi

echo ""
echo "🎉 Configuración DNS completada!"
