#!/bin/bash
cd /root/n8n

sed -i 's/N8N_HOST=.*/N8N_HOST=n8n.smarterbot.cl/' .env.example
sed -i 's/N8N_PROTOCOL=.*/N8N_PROTOCOL=https/' .env.example

echo "✔️ n8n configurado para n8n.smarterbot.cl"
