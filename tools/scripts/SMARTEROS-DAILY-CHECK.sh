#!/bin/bash
# SmarterOS Daily Health Check
# Usage: ./SMARTEROS-DAILY-CHECK.sh

echo "=========================================="
echo "SmarterOS Daily Health Check"
echo "Date: $(date)"
echo "=========================================="

echo -e "\n[1/7] Container Status"
docker ps --format "table {{.Names}}\t{{.Status}}" | grep -E "dokploy|caddy|metabase|n8n|chatwoot|botpress|api|app|mcp|vault"

echo -e "\n[2/7] SSL Endpoints"
for url in app.smarterbot.cl crm.smarterbot.cl kpi.smarterbot.cl n8n.smarterbot.cl botpress.smarterbot.cl mainkey.smarterbot.cl; do
  status=$(curl -s -o /dev/null -w "%{http_code}" https://$url --max-time 5 2>/dev/null || echo "FAIL")
  echo "$url: $status"
done

echo -e "\n[3/7] API Gateway Health"
curl -s http://api.smarterbot.cl/health 2>/dev/null | jq -r '.status // "ERROR"' || echo "API Gateway unreachable"

echo -e "\n[4/7] Database Connection (Supabase)"
if command -v psql &> /dev/null; then
  psql "host=db.rjfcmmzjlguiititkmyh.supabase.co port=5432 user=postgres dbname=postgres" -c "SELECT count(*) as tenants FROM tenants;" 2>/dev/null || echo "DB connection failed"
else
  echo "psql not installed - skipping DB check"
fi

echo -e "\n[5/7] Disk Usage"
df -h / | tail -1 | awk '{print "Root: " $5 " used (" $3 "/" $2 ")"}'

echo -e "\n[6/7] Memory Usage"
free -h | grep Mem | awk '{print "Memory: " $3 "/" $2 " used"}'

echo -e "\n[7/7] Recent Errors (last 5 min)"
docker ps --format "{{.Names}}" | grep -E "dokploy|caddy|metabase|n8n|chatwoot|api" | while read container; do
  errors=$(docker logs $container --since 5m 2>&1 | grep -iE "error|fail|panic|fatal" | wc -l)
  [ $errors -gt 0 ] && echo "$container: $errors errors"
done

echo -e "\n=========================================="
echo "Check complete at $(date)"
echo "=========================================="
