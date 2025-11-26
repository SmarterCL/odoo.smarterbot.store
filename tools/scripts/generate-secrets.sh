#!/bin/bash

# SmarterOS Secret Generator
# Generates all required secrets for deployment

echo "🔐 SmarterOS Secret Generator"
echo "================================"
echo ""

echo "📝 Generating secrets..."
echo ""

# Generate secrets
SECRET_KEY_BASE=$(openssl rand -hex 64)
API_KEY=$(openssl rand -hex 32)
N8N_ENCRYPTION_KEY=$(openssl rand -hex 32)
BOTPRESS_API_KEY=$(openssl rand -hex 32)
POSTGRES_PASSWORD=$(openssl rand -hex 16)
REDIS_PASSWORD=$(openssl rand -hex 16)

echo "✅ Secrets generated!"
echo ""
echo "================================"
echo "Copy these values to your .env files:"
echo "================================"
echo ""

echo "🟦 CHATWOOT (/vault/secrets/chatwoot.env)"
echo "----------------------------------------"
echo "SECRET_KEY_BASE=$SECRET_KEY_BASE"
echo "POSTGRES_PASSWORD=$POSTGRES_PASSWORD"
echo ""

echo "🟪 BOTPRESS (/vault/secrets/botpress.env)"
echo "----------------------------------------"
echo "BOTPRESS_API_KEY=$BOTPRESS_API_KEY"
echo "DATABASE_URL=postgres://botpress:$POSTGRES_PASSWORD@postgres:5432/botpress"
echo "REDIS_URL=redis://:$REDIS_PASSWORD@redis:6379"
echo ""

echo "🟨 N8N (/vault/secrets/n8n.env)"
echo "----------------------------------------"
echo "N8N_ENCRYPTION_KEY=$N8N_ENCRYPTION_KEY"
echo "DB_POSTGRESDB_PASSWORD=$POSTGRES_PASSWORD"
echo ""

echo "🟩 ODOO (/vault/secrets/odoo.env)"
echo "----------------------------------------"
echo "DB_PASSWORD=$POSTGRES_PASSWORD"
echo ""

echo "🟧 SMARTEROS (/vault/secrets/smarteros.env)"
echo "----------------------------------------"
echo "API_KEY=$API_KEY"
echo "POSTGRES_PASSWORD=$POSTGRES_PASSWORD"
echo "REDIS_URL=redis://:$REDIS_PASSWORD@redis:6379"
echo ""

echo "================================"
echo "⚠️  SAVE THESE SECRETS SECURELY!"
echo "================================"
echo ""
echo "📋 Next steps:"
echo "1. Copy the values above to /vault/secrets/*.env files"
echo "2. Add your SMTP credentials manually"
echo "3. Add your Vault token manually"
echo "4. Import compose files into Dokploy"
echo ""
