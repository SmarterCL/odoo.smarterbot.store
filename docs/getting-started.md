# Getting Started with SmarterOS

Welcome to SmarterOS - your comprehensive solution for containerized business automation. This guide will walk you through the essentials to get your system up and running smoothly.

## Prerequisites

Before diving into the installation of SmarterOS, ensure your environment meets the following requirements:
- **Operating System:** Ubuntu 22.04 LTS
- **Hardware:**
  - Minimum: 2 vCPU, 4 GB RAM, 50 GB SSD
  - Recommended: 4 vCPU, 8 GB RAM, 100 GB SSD
- **Network:** Stable internet connection with SSH access

## Installation Steps

1. **Prepare Your Environment**
   
   Update and upgrade your system packages. This ensures your system has the latest security patches and dependencies.
   ```bash
   sudo apt update && sudo apt upgrade -y
   ```

2. **Install Docker and Docker Compose**
   
   Docker is the backbone of SmarterOS, allowing containerization of services.
   ```bash
   sudo apt install docker.io docker-compose -y
   ```

3. **Clone the SmarterOS Repository**
   
   Pull the latest version of SmarterOS from the official repository.
   ```bash
   git clone https://github.com/SmarterOS/smarteros.git /root/smarteros
   cd /root/smarteros
   ```

4. **Environment Configuration**

   Copy the example environment configuration and modify it according to your setup.
   ```bash
   cp .env.example .env.production
   nano .env.production
   ```
   
   Fill in the necessary details such as database passwords, API keys, and any other service credentials.

5. **Launch Services**

   Deploy your containers using Docker Compose.
   ```bash
   docker compose up -d --build
   ```

## First Login and Setup

1. **Access Your Dashboard**

   Visit `https://api.smarterbot.cl/docs` in your web browser to access the API documentation and test endpoints. For administrative access to other services (e.g., Odoo, n8n, Supabase), use the respective URLs mentioned in the System Overview.

2. **Initial Configuration**

   - **Odoo:** Access Odoo at `https://odoo.smarterbot.cl` and follow the setup wizard to configure your ERP/CRM.
   - **Supabase:** For Supabase, the setup is managed via its cloud console at `https://supabase.io`.
   - **n8n:** Access your n8n workflow automation tool at `https://n8n.smarterbot.cl` and create your first workflow.

## Basic Configuration

### Caddy Reverse Proxy

Ensure your `Caddyfile` (/etc/caddy/Caddyfile) is correctly set up to route domain traffic to the appropriate containers. Here's a snippet for `api.smarterbot.cl` routing:

```caddy
api.smarterbot.cl {
    reverse_proxy smartapi:8000
}
```

### API Endpoints

Verify and test your API endpoints using `curl` or Postman. Here's a quick test:

```bash
curl https://api.smarterbot.cl/health
```

Expected response:

```json
{
  "status": "healthy"
}
```

## Verifying the Installation

- **Check Container Status**

  Verify all containers are running smoothly:

  ```bash
  docker ps
  ```

- **Service Health Checks**

  Use the health check endpoints to ensure each service is operational.

  ```bash
  curl https://api.smarterbot.cl/health
  curl https://n8n.smarterbot.cl/health
  curl https://odoo.smarterbot.cl/web/health
  ```

## Next Steps

After ensuring your SmarterOS installation is successful, consider exploring the following areas to enhance your system:

- **Security Hardening:** Review and strengthen security measures, including firewall rules and Docker container security practices.
- **Backup and Restore:** Implement a regular backup routine using the provided `backup.sh` and `restore.sh` scripts to protect your data.
- **Monitoring and Observability:** Set up Grafana, Prometheus, and Loki for comprehensive system monitoring and logging.
- **Expand Services:** Explore adding more containers to your ecosystem, such as `chatwoot` for customer engagement or `vault` for secrets management as your business needs grow.

## Support

Need help? Our support team is here for you:
- **Documentation:** https://smarterbot.cl/docs
- **API Reference:** https://api.smarterbot.cl/docs
- **Email:** soporte@smarterbot.cl

---

**Congratulations on setting up SmarterOS!** Explore, innovate, and automate your business processes with ease and efficiency.