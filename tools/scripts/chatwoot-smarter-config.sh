#!/bin/bash
cd /root/chatwoot

# Parchar domain
sed -i 's/APP_URL=.*/APP_URL=https:\/\/crm.smarterbot.cl/' .env.example

# Forzar CORS
sed -i 's/CHATWOOT_INBOX_URL=.*/CHATWOOT_INBOX_URL=https:\/\/crm.smarterbot.cl/' .env.example

echo "✔️ Chatwoot configurado para crm.smarterbot.cl"
