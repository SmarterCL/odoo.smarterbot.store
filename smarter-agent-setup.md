# 🤖 SmarterAgent - Configuración Completa con MCP y WhatsApp

## 📋 Resumen
Este documento te guía para agregar capacidades MCP (Model Context Protocol) y WhatsApp al agente N8N.

---

## 🔧 PASO 1: Agregar Memory al Agent

1. Abre https://n8n.smarterbot.cl/workflow/BWdJF4keyeKKIfaS
2. Haz clic en el nodo **"Agent"**
3. En la sección **Memory**, haz clic en el botón **"+"**
4. Selecciona **"Window Buffer Memory"**
5. Configura:
   - **Context Window Length**: `10`
   - **Session Key**: `{{ $json.sessionId }}`

---

## 🛠️ PASO 2: Agregar Herramientas MCP

### Tool 1: GitHub Code Search

1. En el nodo **Agent**, sección **Tools**, clic en **"+"**
2. Selecciona **"Code"** → **"Code Tool"**
3. Configura:
   ```
   Name: github_search
   Description: Search for code, repositories, issues, and pull requests across GitHub. Use when users ask for code examples or implementations.
   ```
4. O usa **HTTP Request Tool**:
   ```
   Name: github_search
   Description: Search GitHub code repositories
   Method: GET
   URL: https://api.github.com/search/code?q={{ $json.query }}&per_page=5
   ```

### Tool 2: Web Search (usando MCP)

**Opción A - Tavily Search API** (Recomendado):
1. Agent → Tools → **"+"** → **HTTP Request Tool**
2. Configura:
   ```
   Name: web_search
   Description: Search the web for current information, news, and recent developments
   Method: POST
   URL: https://api.tavily.com/search
   Body JSON:
   {
     "api_key": "tvly-YOUR-API-KEY",
     "query": "{{ $json.query }}",
     "search_depth": "basic"
   }
   ```
   - Obtén API key gratis en: https://tavily.com/

**Opción B - Google Custom Search**:
1. Agent → Tools → **HTTP Request Tool**
2. URL: `https://www.googleapis.com/customsearch/v1?key=YOUR_KEY&cx=YOUR_CX&q={{ $json.query }}`

### Tool 3: Servidor MCP Local (GitHub disponible)

Si tienes el GitHub MCP server corriendo localmente:

1. Agent → Tools → **HTTP Request Tool**
2. Configura:
   ```
   Name: mcp_github
   Description: Advanced GitHub operations via MCP protocol
   Method: POST
   URL: http://localhost:3000/mcp/github
   Headers:
     Content-Type: application/json
   Body:
   {
     "method": "{{ $json.method }}",
     "params": {{ $json.params }}
   }
   ```

### Tool 4: File System Operations

1. Agent → Tools → **"+"** → **"Execute Command"**
2. Configura:
   ```
   Name: read_file
   Description: Read files from the filesystem. Use for accessing documentation, code, or data files.
   Command: cat {{ $json.filepath }}
   ```

3. Otro nodo para buscar:
   ```
   Name: search_files
   Description: Search for files by name or content
   Command: grep -r "{{ $json.query }}" /path/to/search
   ```

---

## 📱 PASO 3: Integración con WhatsApp

### Opción A: Webhook Directo (Simple)

1. **Agregar nodo Webhook**:
   - Arrastra un nodo **"Webhook"** al canvas
   - Posición: Antes del nodo "Agent"
   - Configura:
     ```
     HTTP Method: POST
     Path: whatsapp-webhook
     Response Mode: When Last Node Finishes
     ```

2. **Conectar flujo**:
   - Webhook → Agent
   - Agent → Respond to Webhook

3. **URL del webhook**:
   ```
   https://n8n.smarterbot.cl/webhook/whatsapp-webhook
   ```

### Opción B: Evolution API (Recomendado para WhatsApp Business)

1. **Instalar Evolution API** (si no está instalado):
   ```bash
   docker run -d \
     --name evolution-api \
     -p 8080:8080 \
     -e AUTHENTICATION_API_KEY=tu-api-key-segura \
     atendai/evolution-api:latest
   ```

2. **En N8N, agregar nodo Webhook**:
   ```
   HTTP Method: POST
   Path: whatsapp
   ```

3. **Agregar nodo "Code" para procesar mensaje**:
   ```javascript
   // Extraer mensaje de Evolution API
   const message = $input.item.json.data?.message?.conversation 
     || $input.item.json.data?.message?.extendedTextMessage?.text
     || $input.item.json.message?.text;
   
   const from = $input.item.json.data?.key?.remoteJid 
     || $input.item.json.from;
   
   return {
     chatInput: message,
     sessionId: from,
     platform: 'whatsapp'
   };
   ```

4. **Configurar Evolution API webhook**:
   ```bash
   curl -X POST http://localhost:8080/webhook/set \
     -H "apikey: tu-api-key-segura" \
     -H "Content-Type: application/json" \
     -d '{
       "webhook": {
         "url": "https://n8n.smarterbot.cl/webhook/whatsapp",
         "enabled": true,
         "events": ["messages.upsert"]
       }
     }'
   ```

5. **Agregar nodo para responder por WhatsApp**:
   ```
   Tipo: HTTP Request
   Method: POST
   URL: http://localhost:8080/message/sendText
   Headers:
     apikey: tu-api-key-segura
   Body JSON:
   {
     "number": "{{ $json.sessionId }}",
     "text": "{{ $('Agent').item.json.output }}"
   }
   ```

---

## 🎨 PASO 4: Actualizar System Message

Doble clic en el nodo **Agent** y actualiza el **System Message**:

```
You are SmarterAgent, an advanced AI assistant powered by GPT-4 with access to these tools:

🔍 **GitHub Search**: Search code, repos, issues, and PRs across GitHub
   - Use for: code examples, implementations, library research
   - Example: "Find React hooks examples"

🌐 **Web Search**: Real-time web search with current information
   - Use for: news, recent events, documentation, tutorials
   - Example: "Latest AI developments in 2024"

📁 **Filesystem**: Read and search local files
   - Use for: project files, documentation, configuration
   - Example: "Read the README file"

📱 **WhatsApp**: Receive and respond to messages
   - Platform: WhatsApp Business via webhook
   - Real-time message handling

**Behavior Guidelines**:
- Always choose the most appropriate tool for each query
- Be concise but comprehensive
- Cite sources when using web search
- Format code with proper syntax highlighting
- Remember conversation context across messages
- For WhatsApp: keep responses mobile-friendly (shorter paragraphs)

**Language**: Respond in the same language as the user's message
```

---

## ⚙️ PASO 5: Configurar OpenAI Model

En el nodo **"OpenAI Model"**:

```
Model: gpt-4o (o gpt-4-turbo-preview)
Temperature: 0.7
Max Tokens: 4000
Frequency Penalty: 0.3
Presence Penalty: 0.3
```

---

## 🧪 PASO 6: Testing

### Test 1: Chat Web
1. Activa el workflow
2. Abre https://n8n.smarterbot.cl/workflow/BWdJF4keyeKKIfaS
3. Haz clic en "Chat"
4. Prueba:
   ```
   "Busca ejemplos de React hooks en GitHub"
   "¿Cuáles son las últimas noticias sobre IA?"
   "Ayúdame a entender async/await en JavaScript"
   ```

### Test 2: WhatsApp
Envía mensaje al número configurado en Evolution API:
```
"Hola, busca información sobre Docker Compose"
"Muéstrame código de Python para leer archivos"
```

---

## 📊 PASO 7: Monitoreo

1. **Ver ejecuciones**: https://n8n.smarterbot.cl/executions
2. **Logs en tiempo real**:
   ```bash
   docker logs -f smarter-n8n
   ```
3. **Métricas Evolution API**:
   ```
   http://localhost:8080/instance/connectionState
   ```

---

## 🔐 Variables de Entorno Necesarias

Agrega estas variables en N8N (Settings → Environment Variables):

```bash
# GitHub (opcional, para más rate limit)
GITHUB_TOKEN=ghp_your_token_here

# Tavily Search
TAVILY_API_KEY=tvly-your-key-here

# Evolution API
EVOLUTION_API_KEY=tu-api-key-segura
EVOLUTION_API_URL=http://localhost:8080

# OpenAI (ya configurado)
OPENAI_API_KEY=sk-your-key
```

---

## 🚀 Mejoras Futuras

1. **Agregar más MCP servers**:
   - Filesystem MCP (para operaciones avanzadas)
   - Brave Search MCP
   - PostgreSQL MCP (para bases de datos)

2. **Multi-canal**:
   - Telegram
   - Discord
   - Slack

3. **Capacidades avanzadas**:
   - Image generation (DALL-E)
   - Voice messages (Whisper API)
   - Document processing (PDFs, DOCs)

---

## ❓ Troubleshooting

### Problema: Agent no usa las herramientas
- ✅ Verifica que las descripciones sean claras
- ✅ Asegúrate que el System Message menciona las herramientas
- ✅ Revisa que las herramientas estén conectadas al Agent

### Problema: WhatsApp no recibe mensajes
- ✅ Verifica que Evolution API esté corriendo: `docker ps | grep evolution`
- ✅ Chequea webhook configurado: `curl http://localhost:8080/webhook/find -H "apikey: tu-key"`
- ✅ Revisa logs: `docker logs evolution-api`

### Problema: Rate limit en GitHub
- ✅ Agrega un GitHub token en las credenciales
- ✅ Obtén token en: https://github.com/settings/tokens

---

## 📞 Contacto y Soporte

- **N8N Dashboard**: https://n8n.smarterbot.cl
- **Workflow ID**: BWdJF4keyeKKIfaS
- **Documentación N8N**: https://docs.n8n.io

