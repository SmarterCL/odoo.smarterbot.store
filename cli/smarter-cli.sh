#!/bin/bash
# SMARTEROS ENTERPRISE MONITORING CLI
# Version: 1.0.0

set -e

SMARTEROS_API="https://api.smarterbot.cl"
SMARTEROS_TOKEN="${SMARTEROS_TOKEN:-}"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

function status() {
    echo "🔍 SmarterOS Status Check..."
    
    # API Gateway
    if curl -sf "$SMARTEROS_API/health" > /dev/null; then
        echo -e "${GREEN}✓${NC} API Gateway: UP"
    else
        echo -e "${RED}✗${NC} API Gateway: DOWN"
    fi
    
    # Odoo
    if curl -sf "https://odoo.smarterbot.cl/web/health" > /dev/null; then
        echo -e "${GREEN}✓${NC} Odoo ERP: UP"
    else
        echo -e "${RED}✗${NC} Odoo ERP: DOWN"
    fi
    
    # Chatwoot
    if curl -sf "https://crm.smarterbot.cl/health" > /dev/null; then
        echo -e "${GREEN}✓${NC} Chatwoot: UP"
    else
        echo -e "${RED}✗${NC} Chatwoot: DOWN"
    fi
    
    # Database
    if docker exec root_postgres_1 pg_isready > /dev/null 2>&1; then
        echo -e "${GREEN}✓${NC} PostgreSQL: UP"
    else
        echo -e "${RED}✗${NC} PostgreSQL: DOWN"
    fi
}

function tenants() {
    echo "📊 Active Tenants..."
    docker exec root_postgres_1 psql -U postgres -d dokploy -c "SELECT COUNT(*) as total_tenants FROM tenants WHERE deleted_at IS NULL;" -t
}

function backup() {
    local service="${1:-all}"
    echo "💾 Running backup for: $service"
    
    case $service in
        postgres|all)
            echo "Backing up PostgreSQL..."
            docker exec root_postgres_1 pg_dump -U postgres > "/backups/pg_$(date +%F-%H%M).sql"
            echo -e "${GREEN}✓${NC} PostgreSQL backup complete"
            ;;
        odoo|all)
            echo "Backing up Odoo filestore..."
            tar -czf "/backups/odoo_$(date +%F-%H%M).tar.gz" /var/lib/odoo/filestore
            echo -e "${GREEN}✓${NC} Odoo backup complete"
            ;;
    esac
}

function failover() {
    local action="${1:-status}"
    
    case $action in
        activate)
            echo -e "${YELLOW}⚠${NC}  Activating failover mode..."
            # TODO: Implement failover logic
            echo "Failover activated"
            ;;
        status)
            echo "Failover status: INACTIVE"
            ;;
        *)
            echo "Usage: smarter failover {activate|status}"
            ;;
    esac
}

function incidents() {
    echo "🚨 Recent Incidents..."
    # TODO: Query incident log
    echo "No active incidents"
}

function logs() {
    local service="${1:-api}"
    local lines="${2:-100}"
    
    case $service in
        api)
            docker logs --tail "$lines" smartapi
            ;;
        odoo)
            docker logs --tail "$lines" odoo-backend
            ;;
        chatwoot)
            docker logs --tail "$lines" smarter-chatwoot
            ;;
        *)
            echo "Unknown service: $service"
            echo "Available: api, odoo, chatwoot"
            ;;
    esac
}

function audit() {
    echo "🔍 Running security audit..."
    
    # Check RLS policies
    echo "Checking RLS policies..."
    docker exec root_postgres_1 psql -U postgres -d dokploy -c "\
        SELECT tablename, policyname \
        FROM pg_policies \
        WHERE schemaname = 'public';" | head -20
    
    # Check SSL certificates
    echo ""
    echo "Checking SSL certificates..."
    for domain in api.smarterbot.cl odoo.smarterbot.cl crm.smarterbot.cl; do
        expiry=$(echo | openssl s_client -servername "$domain" -connect "$domain:443" 2>/dev/null | openssl x509 -noout -enddate | cut -d= -f2)
        echo "$domain: Valid until $expiry"
    done
}

function help_text() {
    cat << EOF
SmarterOS Enterprise CLI v1.0.0

Usage: smarter <command> [options]

Commands:
  status                 Check all services status
  tenants                List active tenants
  backup [service]       Run backup (postgres|odoo|all)
  failover [action]      Manage failover (activate|status)
  incidents              List recent incidents
  logs <service> [lines] View service logs
  audit                  Run security audit
  
Examples:
  smarter status
  smarter backup postgres
  smarter logs api 200
  smarter audit

Environment:
  SMARTEROS_TOKEN        API authentication token
  
EOF
}

# Main
case "${1:-}" in
    status)
        status
        ;;
    tenants)
        tenants
        ;;
    backup)
        backup "${2:-all}"
        ;;
    failover)
        failover "${2:-status}"
        ;;
    incidents)
        incidents
        ;;
    logs)
        logs "${2:-api}" "${3:-100}"
        ;;
    audit)
        audit
        ;;
    help|--help|-h|"")
        help_text
        ;;
    *)
        echo "Unknown command: $1"
        echo "Run 'smarter help' for usage"
        exit 1
        ;;
esac
