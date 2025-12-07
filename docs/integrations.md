# SmarterOS Integration Guides

This document provides step-by-step instructions on how to integrate various external services with SmarterOS, including Odoo ERP, Supabase, n8n workflow automation, Chatwoot CRM, and payment gateway concepts. Additionally, it covers the creation of custom MCP (Model Context Protocol) tools.

## Table of Contents

1. [Odoo ERP Integration](#odoo-erp-integration)
2. [Supabase Database Setup](#supabase-database-setup)
3. [n8n Workflow Automation](#n8n-workflow-automation)
4. [Chatwoot CRM Connection](#chatwoot-crm-connection)
5. [Payment Gateway Integration (Conceptual)](#payment-gateway-integration-conceptual)
6. [Custom MCP Tools Creation](#custom-mcp-tools-creation)
7. [Troubleshooting Tips](#troubleshooting-tips)

---

## Odoo ERP Integration

Integrating Odoo ERP with SmarterOS allows you to manage business processes efficiently.

### Configuration

1. **Environment Variables**: Ensure your `.env.production` file includes Odoo credentials:

    ```bash
    ODOO_URL=https://odoo.smarterbot.cl
    ODOO_DB=smarterbot
    ODOO_API_KEY=your_odoo_api_key_here
    ```

2. **Odoo Client Setup**: Utilize the `odoo_client.py` within your `api.smarterbot.cl` directory to facilitate communication with Odoo. Example setup:

    ```python
    from odoo import OdooClient

    odoo = OdooClient(url=ODOO_URL, db=ODOO_DB, api_key=ODOO_API_KEY)
    ```

3. **API Routers**: In your FastAPI application, ensure you have an Odoo router in `routers/odoo.py` that uses the `odoo_client` for Odoo operations.

### Usage

- **CRUD Operations**: Use the Odoo client methods (`search_read`, `create`, `write`, `unlink`) within your API endpoints to interact with Odoo models.

    ```python
    @router.post("/odoo/create")
    async def create_partner(data: dict):
        return odoo.create("res.partner", data)
    ```

### Troubleshooting

- **API Key Issues**: Ensure the API key is correctly set in the environment variables and Odoo backend.
- **Network Problems**: Verify the Odoo URL is reachable from your SmarterOS instance.

---

## Supabase Database Setup

Supabase offers a robust database solution, ideal for storing application data.

### Configuration

1. **Supabase Project**: Create a new project in Supabase, noting the URL and Service Role Key.

2. **Environment Variables**: Add Supabase details to `.env.production`:

    ```bash
    SUPABASE_URL=https://your_project_id.supabase.co
    SUPABASE_SERVICE_ROLE=your_service_role_key
    ```

3. **Database Schema**: Use Supabase Dashboard to set up your database tables according to your application's needs.

### Usage

- **Supabase Client**: Implement a Supabase client in your application to interact with the database.

    ```python
    from supabase import create_client, Client

    url: str = SUPABASE_URL
    key: str = SUPABASE_SERVICE_ROLE
    supabase: Client = create_client(url, key)
    ```

- **Data Operations**: Utilize the Supabase client for CRUD operations.

    ```python
    data = {"name": "John Doe", "email": "john@example.com"}
    supabase.table("contacts").insert(data).execute()
    ```

### Troubleshooting

- **Connection Issues**: Ensure the Supabase URL and Service Role Key are correctly provided.
- **Schema Mismatches**: Double-check your table structures and data types in Supabase.

---

## n8n Workflow Automation

n8n is a powerful tool for creating automated workflows.

### Configuration

1. **n8n Setup**: Ensure the `n8n` container is running within SmarterOS.

2. **Environment Variables**: Define n8n credentials in `.env.production`:

    ```bash
    N8N_BASE_URL=https://n8n.smarterbot.cl
    N8N_API_KEY=your_n8n_api_key_here
    ```

3. **Workflow Creation**: Access n8n through `n8n.smarterbot.cl` and create workflows as needed.

### Usage

- **API Calls**: Use the n8n API to trigger workflows programmatically.

    ```bash
    curl -X POST "$N8N_BASE_URL/webhook-test/my-workflow" -H "Authorization: Bearer $N8N_API_KEY"
    ```

### Troubleshooting

- **Workflow Failures**: Check the n8n dashboard for errors and logs.
- **API Connectivity**: Ensure the n8n URL is correct and the API key is valid.

---

## Chatwoot CRM Connection

Chatwoot integration allows for managing customer relationships directly within SmarterOS.

### Configuration

1. **Chatwoot Setup**: Await the deployment of the `chatwoot` container.

2. **Environment Variables**: Add Chatwoot details to `.env.production`:

    ```bash
    CHATWOOT_BASE_URL=https://chatwoot.smarterbot.cl
    CHATWOOT_TOKEN=your_chatwoot_api_token
    ```

3. **API Integration**: Use the Chatwoot API for interactions.

### Usage

- **Sending Messages**: Utilize the Chatwoot API to send messages or perform CRM operations.

    ```python
    import requests

    headers = {"API-TOKEN": CHATWOOT_TOKEN}
    data = {"content": "Hello, World!", "sender_id": 1, "message_type": "outgoing"}
    response = requests.post(f"{CHATWOOT_BASE_URL}/api/v1/conversations/{conversation_id}/messages", headers=headers, data=data)
    ```

### Troubleshooting

- **Authentication Issues**: Verify the API token is correct.
- **Network Connectivity**: Ensure Chatwoot is accessible from your SmarterOS instance.

---

## Payment Gateway Integration (Conceptual)

Integrating payment gateways involves connecting to external payment services.

### Conceptual Steps

1. **Choose a Payment Gateway**: Select providers like Stripe, PayPal, or local gateways.
2. **API Credentials**: Obtain API keys and set them in `.env.production`.
3. **Payment Processing**: Implement payment processing logic in your application.

### Troubleshooting

- **API Errors**: Check the documentation of the payment gateway for error codes.
- **Security**: Ensure sensitive information is securely stored and transmitted.

---

## Custom MCP Tools Creation

Develop custom tools for SmarterOS with the MCP standard.

### Steps

1. **Define Tool**: Identify the functionality and inputs/outputs for your tool.
2. **Implement API**: Create an API endpoint in your FastAPI application.

    ```python
    @app.post("/mcp/my_custom_tool")
    async def my_custom_tool(input: dict):
        # Implement tool logic here
        return {"result": "success"}
    ```

3. **Register Tool**: Add your tool to the MCP registry (`/registry.json`).

### Troubleshooting

- **MCP Compatibility**: Ensure your tool adheres to the MCP specifications.
- **Testing**: Thoroughly test your tool with various inputs to ensure reliability.

---

## Troubleshooting Tips

- **Logs**: Always check container logs (`docker logs container_name`) for errors.
- **Environment Variables**: Ensure all necessary environment variables are correctly set.
- **Network Connectivity**: Verify containers can communicate with each other and external services.
- **Security**: Keep your system and services updated to mitigate vulnerabilities.

By following these guides, you should be able to successfully integrate external services with SmarterOS and develop custom MCP tools tailored to your needs.