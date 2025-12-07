# 🤖 N8N Workflows Registry
# Catálogo centralizado de workflows N8N para SmarterOS

version: "1.0"
category: "automation"
updated: "2025-11-17"

metadata:
  n8n_instance: "https://n8n.smarterbot.cl"
  description: "Workflows de automatización para GitHub, Slack, AI Agents y más"
  total_workflows: 2

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Workflows Registry
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

workflows:
  github_slack_automation:
    id: "github-slack-sync"
    name: "GitHub → Slack Automation"
    description: "Sincroniza eventos de GitHub con notificaciones Slack"
    file: "workflows/github-slack-automation.yml"
    status: "active"
    tags: ["github", "slack", "notifications"]
    triggers:
      - "github.issues"
      - "github.pull_requests"
      - "github.push"
      - "github.workflow_run"
    actions:
      - "slack.post_message"
    integrations:
      - github
      - slack
    
  smarter_agent:
    id: "BWdJF4keyeKKIfaS"
    name: "SmarterAgent"
    description: "Agente AI con OpenAI + Gemini para análisis y código"
    file: "workflows/smarter-agent-n8n.json"
    status: "active"
    tags: ["OS", "Agent", "AI", "OpenAI", "Gemini"]
    triggers:
      - "webhook.post"
    actions:
      - "openai.chat"
      - "gemini.chat"
      - "vault.save_log"
    integrations:
      - openai
      - gemini
      - vault
    routing:
      code: "openai-only"
      analysis: "gemini-only"
      general: "both-combined"

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Integration Requirements
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

integrations:
  github:
    type: "oauth2"
    scopes: ["repo", "workflow"]
    webhook_secret: "{{ vault:smarteros/mcp/github:webhook_secret }}"
    
  slack:
    type: "oauth2"
    scopes: ["chat:write", "channels:read"]
    bot_token: "{{ vault:smarteros/mcp/slack:bot_token }}"
    
  openai:
    type: "api_key"
    api_key: "{{ vault:smarteros/mcp/openai:api_key }}"
    model: "gpt-4-turbo-preview"
    
  gemini:
    type: "api_key"
    api_key: "{{ vault:smarteros/mcp/gemini:api_key }}"
    model: "gemini-1.5-pro"
    
  vault:
    type: "token"
    address: "{{ env:VAULT_ADDR }}"
    token: "{{ vault:smarteros/n8n:vault_token }}"

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Deployment Checklist
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

deployment:
  prerequisites:
    - name: "N8N instance running"
      url: "https://n8n.smarterbot.cl"
      status: "✅"
      
    - name: "Vault secrets configured"
      paths:
        - "smarteros/mcp/github"
        - "smarteros/mcp/slack"
        - "smarteros/mcp/openai"
        - "smarteros/mcp/gemini"
      status: "⏳"
      
    - name: "GitHub webhooks configured"
      repos:
        - "SmarterCL/SmarterOS"
        - "SmarterCL/fulldaygo.smarterbot.cl"
        - "SmarterCL/smarteros-specs"
      status: "⏳"
      
    - name: "Slack app installed"
      workspace: "smartercl.slack.com"
      status: "⏳"
  
  steps:
    1_import_workflows:
      description: "Importar workflows a N8N"
      commands:
        - "Ir a https://n8n.smarterbot.cl"
        - "Import from File > seleccionar JSON"
        - "Activar workflow"
    
    2_configure_credentials:
      description: "Configurar credenciales en N8N"
      credentials:
        - name: "GitHub OAuth2"
          type: "oAuth2Api"
        - name: "Slack OAuth2"
          type: "slackOAuth2Api"
        - name: "OpenAI API"
          type: "openAiApi"
        - name: "Google Gemini API"
          type: "googleGeminiApi"
        - name: "Vault Token"
          type: "httpHeaderAuth"
    
    3_test_workflows:
      description: "Probar workflows"
      tests:
        - workflow: "github-slack-sync"
          test: "Crear issue en GitHub"
          expected: "Notificación en Slack #dev"
        - workflow: "smarter-agent"
          test: "POST a webhook con query"
          expected: "Respuesta JSON con análisis AI"

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Usage Examples
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

usage:
  github_slack:
    description: "Recibe eventos GitHub → envía a Slack"
    automatic: true
    trigger_example: "Se crea issue en GitHub"
    result_example: "Mensaje en #dev con detalles del issue"
    
  smarter_agent:
    description: "Procesa consultas con AI (OpenAI/Gemini)"
    automatic: false
    trigger_example: |
      curl -X POST https://n8n.smarterbot.cl/webhook/smarter-agent \
        -H "Content-Type: application/json" \
        -d '{
          "query": "Analiza el rendimiento del workflow de backup",
          "context": "analysis",
          "tenant_id": "fulldaygo"
        }'
    result_example: |
      {
        "query": "Analiza el rendimiento del workflow de backup",
        "context": "analysis",
        "tenant_id": "fulldaygo",
        "timestamp": "2025-11-17T10:30:00Z",
        "agent": "SmarterAgent",
        "version": "1.0",
        "models_used": ["gemini-1.5-pro"],
        "answer": "Análisis estratégico del workflow...",
        "confidence": 0.92,
        "metadata": {
          "tokens_used": {"gemini": 1250},
          "processing_time_ms": 1850,
          "routing_strategy": "analysis"
        }
      }

notes: |
  Workflows N8N implementados:
  
  1. GitHub → Slack: Automatización de notificaciones
     - Issues, PRs, Pushes, Workflow runs
     - Mensajes formateados con Slack Blocks
     - Enrutamiento a canales según tipo de evento
  
  2. SmarterAgent: Agente AI híbrido
     - OpenAI (GPT-4): Código y soluciones técnicas
     - Gemini (1.5 Pro): Análisis estratégico y negocio
     - Routing inteligente según contexto
     - Logs persistidos en Vault
     - Confidence check antes de responder
  
  Próximos workflows:
  - [ ] Shopify → Supabase sync
  - [ ] Clerk webhooks → Analytics
  - [ ] Error alerts → Slack #ops
  - [ ] Vercel deploys → Status updates
