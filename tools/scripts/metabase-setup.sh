#!/bin/bash

GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

METABASE_URL="http://localhost:3001"

# 1. Setup initial admin user
echo -e "${BLUE}Setting up Metabase admin user...${NC}"
SETUP_TOKEN=$(curl -s "$METABASE_URL/api/session/properties" | python3 -c "import json,sys; print(json.load(sys.stdin).get('setup-token', ''))")

if [ -n "$SETUP_TOKEN" ]; then
  echo "Setup token found: $SETUP_TOKEN"
  
  SETUP_RESPONSE=$(curl -s -X POST "$METABASE_URL/api/setup" \
    -H "Content-Type: application/json" \
    -d '{
      "token": "'"$SETUP_TOKEN"'",
      "user": {
        "first_name": "Smarter",
        "last_name": "Admin",
        "email": "smarterbotcl@gmail.com",
        "password": "SmArTeR#2025!KpI@CL",
        "site_name": "SmarterOS KPI"
      },
      "prefs": {
        "site_name": "SmarterOS KPI",
        "site_locale": "es",
        "allow_tracking": false
      }
    }')
  
  echo "$SETUP_RESPONSE" | python3 -m json.tool
  SESSION_ID=$(echo "$SETUP_RESPONSE" | python3 -c "import json,sys; print(json.load(sys.stdin).get('id', ''))")
  echo -e "${GREEN}✅ Admin user created! Password: SmArTeR#2025!KpI@CL${NC}"
else
  echo "Metabase already setup. Logging in..."
  LOGIN_RESPONSE=$(curl -s -X POST "$METABASE_URL/api/session" \
    -H "Content-Type: application/json" \
    -d '{
      "username": "smarterbotcl@gmail.com",
      "password": "SmArTeR#2025!KpI@CL"
    }')
  
  SESSION_ID=$(echo "$LOGIN_RESPONSE" | python3 -c "import json,sys; print(json.load(sys.stdin).get('id', ''))" 2>/dev/null)
fi

if [ -z "$SESSION_ID" ]; then
  echo "❌ Could not get session ID"
  exit 1
fi

echo "Session ID: $SESSION_ID"

# 2. Add Supabase database
echo -e "${BLUE}Adding Supabase database...${NC}"
DB_RESPONSE=$(curl -s -X POST "$METABASE_URL/api/database" \
  -H "Content-Type: application/json" \
  -H "X-Metabase-Session: $SESSION_ID" \
  -d '{
    "engine": "postgres",
    "name": "SmarterOS Database",
    "details": {
      "host": "db.rjfcmmzjlguiititkmyh.supabase.co",
      "port": 5432,
      "dbname": "postgres",
      "user": "postgres",
      "password": "RctbsgNqeUeEIO9e",
      "schema-filters-type": "inclusion",
      "schema-filters-patterns": "public",
      "ssl": true,
      "ssl-mode": "require",
      "tunnel-enabled": false
    },
    "auto_run_queries": true,
    "is_full_sync": true,
    "schedules": {
      "metadata_sync": {
        "schedule_type": "hourly"
      }
    }
  }')

echo "$DB_RESPONSE" | python3 -m json.tool
echo -e "${GREEN}✅ Supabase database added!${NC}"
echo -e "${GREEN}✅ Metabase is ready at https://kpi.smarterbot.cl${NC}"
echo -e "${GREEN}   Email: smarterbotcl@gmail.com${NC}"
echo -e "${GREEN}   Password: SmArTeR#2025!KpI@CL${NC}"
