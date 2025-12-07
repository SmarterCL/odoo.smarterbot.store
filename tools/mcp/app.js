// MCP Registry Data
const mcpData = [
  // TIER 1: Core Infrastructure
  {
    id: 'github',
    name: 'GitHub MCP',
    tier: 1,
    category: 'core',
    status: 'active',
    description: 'Official GitHub MCP server with comprehensive repository, issues, PRs, workflows, and code search capabilities',
    installed: true,
    endpoint: 'http://localhost:3001',
    dockerImage: 'ghcr.io/github/github-mcp-server:latest',
    repository: 'https://github.com/github/github-mcp-server',
    remoteServer: 'https://api.githubcopilot.com/mcp/',
    agents: ['gemini', 'copilot', 'codex'],
    tools: [
      // Repository Management
      'get_file_contents',
      'list_commits',
      'get_commit',
      'list_branches',
      // Issues
      'list_issues',
      'issue_read',
      'search_issues',
      // Pull Requests
      'list_pull_requests',
      'pull_request_read',
      'search_pull_requests',
      // Workflows & CI/CD
      'list_workflows',
      'list_workflow_runs',
      'get_workflow_run',
      'get_job_logs',
      // Search & Discovery
      'search_repositories',
      'search_code',
      'search_users',
      'web_search'
    ],
    features: {
      authentication: ['oauth', 'pat'],
      enterprise: true,
      remote: true,
      proxy: true,
      toolsets: ['default', 'read_only', 'ci_cd', 'full']
    },
    vaultPath: 'smarteros/mcp/github',
    docs: '/specs/mcp/github.yml'
  },
  {
    id: 'vault',
    name: 'Vault MCP',
    tier: 1,
    category: 'core',
    status: 'active',
    description: 'HashiCorp Vault secrets management via MCP',
    installed: true,
    endpoint: 'http://localhost:8081',
    repository: 'https://github.com/vault-mcp',
    agents: ['gemini', 'copilot', 'codex'],
    tools: ['read_secret', 'write_secret', 'list_secrets', 'delete_secret'],
    vaultPath: 'self',
    docs: '/specs/services/vault-mcp-server.yml'
  },
  {
    id: 'clerk',
    name: 'Clerk MCP',
    tier: 1,
    category: 'core',
    status: 'pending',
    description: 'User authentication and session management',
    installed: true,
    npmPackage: '@clerk/mcp-tools',
    agents: ['gemini', 'copilot', 'codex'],
    tools: ['users_list', 'user_get', 'session_validate', 'organizations'],
    vaultPath: 'smarteros/mcp/clerk',
    docs: '/specs/mcp/clerk.yml'
  },
  {
    id: 'smartermcp',
    name: 'SmarterMCP',
    tier: 1,
    category: 'core',
    status: 'pending',
    description: 'Custom SmarterOS MCP server for internal services',
    installed: false,
    npmPackage: '@smartercl/mcp-server',
    endpoint: 'https://mcp.smarterbot.cl',
    agents: ['codex', 'gemini', 'copilot'],
    tools: ['custom_operations'],
    vaultPath: 'smarteros/mcp/smartermcp',
    docs: '/specs/mcp/smartermcp.yml'
  },
  {
    id: 'docker',
    name: 'Docker MCP',
    tier: 1,
    category: 'core',
    status: 'active',
    description: 'Docker container and infrastructure management',
    installed: false,
    agents: ['codex'],
    tools: ['containers_list', 'images_list', 'compose_up', 'compose_down'],
    vaultPath: 'smarteros/mcp/docker',
    docs: '/specs/mcp/docker.yml'
  },
  {
    id: 'hostinger',
    name: 'Hostinger API MCP',
    tier: 1,
    category: 'core',
    status: 'pending',
    description: 'VPS, domain, and hosting management (100+ tools)',
    installed: true,
    npmPackage: 'hostinger-api-mcp',
    agents: ['codex', 'gemini'],
    tools: ['vps_list', 'vps_start', 'vps_stop', 'ssh_keys', 'firewall', 'backups', 'domains'],
    vaultPath: 'smarteros/mcp/hostinger',
    docs: '/specs/mcp/hostinger.yml'
  },
  {
    id: 'supabase',
    name: 'Supabase MCP',
    tier: 1,
    category: 'core',
    status: 'pending',
    description: 'Database, auth, and storage operations',
    installed: false,
    agents: ['gemini', 'copilot'],
    tools: ['query', 'rpc', 'storage_upload', 'auth_users'],
    vaultPath: 'smarteros/mcp/supabase',
    docs: '/specs/mcp/supabase.yml'
  },
  
  // TIER 2: Business Logic
  {
    id: 'shopify',
    name: 'Shopify MCP',
    tier: 2,
    category: 'business',
    status: 'inactive',
    description: 'E-commerce and product management',
    installed: false,
    agents: ['gemini', 'copilot'],
    tools: ['products_list', 'orders_get', 'inventory_check'],
    vaultPath: 'smarteros/mcp/shopify',
    docs: '/specs/mcp/shopify.yml'
  },
  {
    id: 'metabase',
    name: 'Metabase MCP',
    tier: 2,
    category: 'business',
    status: 'inactive',
    description: 'Analytics and business intelligence',
    installed: false,
    agents: ['gemini'],
    tools: ['query_database', 'dashboards_list'],
    vaultPath: 'smarteros/mcp/metabase',
    docs: '/specs/mcp/metabase.yml'
  },
  {
    id: 'odoo',
    name: 'Odoo MCP',
    tier: 2,
    category: 'business',
    status: 'inactive',
    description: 'ERP and business management',
    installed: false,
    agents: ['gemini'],
    tools: ['erp_operations'],
    vaultPath: 'smarteros/mcp/odoo',
    docs: '/specs/mcp/odoo.yml'
  },
  {
    id: 'n8n',
    name: 'N8N MCP',
    tier: 2,
    category: 'business',
    status: 'inactive',
    description: 'Workflow automation',
    installed: false,
    agents: ['gemini', 'codex'],
    tools: ['workflows_list', 'executions', 'credentials'],
    vaultPath: 'smarteros/mcp/n8n',
    docs: '/specs/mcp/n8n.yml'
  },
  {
    id: 'stripe',
    name: 'Stripe MCP',
    tier: 2,
    category: 'business',
    status: 'inactive',
    description: 'Payment processing',
    installed: false,
    agents: ['gemini'],
    tools: ['payments', 'customers', 'subscriptions'],
    vaultPath: 'smarteros/mcp/stripe',
    docs: '/specs/mcp/stripe.yml'
  },
  
  // TIER 3: AI/ML
  {
    id: 'openai',
    name: 'OpenAI MCP',
    tier: 3,
    category: 'ai',
    status: 'inactive',
    description: 'OpenAI API integration',
    installed: false,
    agents: ['gemini'],
    tools: ['completions', 'embeddings'],
    vaultPath: 'smarteros/mcp/openai',
    docs: '/specs/mcp/openai.yml'
  },
  {
    id: 'anthropic',
    name: 'Anthropic MCP',
    tier: 3,
    category: 'ai',
    status: 'inactive',
    description: 'Claude API integration',
    installed: false,
    agents: ['gemini'],
    tools: ['claude_completions'],
    vaultPath: 'smarteros/mcp/anthropic',
    docs: '/specs/mcp/anthropic.yml'
  },
  {
    id: 'google',
    name: 'Google AI MCP',
    tier: 3,
    category: 'ai',
    status: 'inactive',
    description: 'Google AI Platform',
    installed: false,
    agents: ['gemini'],
    tools: ['gemini_api'],
    vaultPath: 'smarteros/mcp/google',
    docs: '/specs/mcp/google.yml'
  },
  {
    id: 'context7',
    name: 'Context7 MCP',
    tier: 3,
    category: 'ai',
    status: 'pending',
    description: 'Documentation and context management',
    installed: true,
    npmPackage: '@upstash/context7-mcp',
    agents: ['copilot'],
    tools: ['docs_search', 'context_fetch'],
    vaultPath: 'public',
    docs: '/specs/mcp/context7.yml'
  },
  
  // TIER 4: Communication
  {
    id: 'slack',
    name: 'Slack MCP',
    tier: 4,
    category: 'communication',
    status: 'inactive',
    description: 'Team communication and notifications',
    installed: false,
    agents: ['gemini', 'codex'],
    tools: ['send_message', 'channels_list', 'users_list'],
    vaultPath: 'smarteros/mcp/slack',
    docs: '/specs/mcp/slack.yml'
  },
  {
    id: 'twilio',
    name: 'Twilio MCP',
    tier: 4,
    category: 'communication',
    status: 'inactive',
    description: 'SMS and voice communications',
    installed: false,
    agents: ['gemini'],
    tools: ['send_sms', 'make_call'],
    vaultPath: 'smarteros/mcp/twilio',
    docs: '/specs/mcp/twilio.yml'
  },
  {
    id: 'whatsapp',
    name: 'WhatsApp MCP',
    tier: 4,
    category: 'communication',
    status: 'inactive',
    description: 'WhatsApp Business API',
    installed: false,
    agents: ['gemini'],
    tools: ['send_message', 'templates'],
    vaultPath: 'smarteros/mcp/whatsapp',
    docs: '/specs/mcp/whatsapp.yml'
  },
  {
    id: 'mailgun',
    name: 'Mailgun MCP',
    tier: 4,
    category: 'communication',
    status: 'inactive',
    description: 'Email delivery service',
    installed: false,
    agents: ['gemini'],
    tools: ['send_email', 'domains_list'],
    vaultPath: 'smarteros/mcp/mailgun',
    docs: '/specs/mcp/mailgun.yml'
  },
  
  // TIER 5: DevOps
  {
    id: 'cloudflare',
    name: 'Cloudflare DNS MCP',
    tier: 5,
    category: 'devops',
    status: 'pending',
    description: 'DNS management and analytics',
    installed: false,
    endpoint: 'https://dns-analytics.mcp.cloudflare.com/mcp',
    agents: ['codex'],
    tools: ['zones_list', 'dns_records_create', 'dns_records_update', 'analytics'],
    vaultPath: 'smarteros/mcp/cloudflare',
    docs: '/specs/mcp/cloudflare-dns.yml'
  },
  {
    id: 'aws',
    name: 'AWS MCP',
    tier: 5,
    category: 'devops',
    status: 'inactive',
    description: 'AWS cloud services',
    installed: false,
    agents: ['codex'],
    tools: ['ec2', 's3', 'lambda'],
    vaultPath: 'smarteros/mcp/aws',
    docs: '/specs/mcp/aws.yml'
  },
  {
    id: 'vercel',
    name: 'Vercel MCP',
    tier: 5,
    category: 'devops',
    status: 'pending',
    description: 'Deploy MCP servers as Vercel Functions',
    installed: true,
    npmPackage: 'mcp-handler',
    agents: ['codex', 'gemini'],
    tools: ['deploy', 'projects_list', 'env_update'],
    vaultPath: 'smarteros/mcp/vercel',
    docs: '/specs/mcp/vercel.yml'
  },
  {
    id: 'linear',
    name: 'Linear MCP',
    tier: 5,
    category: 'devops',
    status: 'inactive',
    description: 'Issue tracking',
    installed: false,
    agents: ['gemini'],
    tools: ['issues_list', 'issue_create'],
    vaultPath: 'smarteros/mcp/linear',
    docs: '/specs/mcp/linear.yml'
  },
  {
    id: 'notion',
    name: 'Notion MCP',
    tier: 5,
    category: 'devops',
    status: 'inactive',
    description: 'Documentation and knowledge base',
    installed: false,
    agents: ['gemini'],
    tools: ['pages_list', 'database_query'],
    vaultPath: 'smarteros/mcp/notion',
    docs: '/specs/mcp/notion.yml'
  },
  
  // Additional installed MCPs
  {
    id: 'playwright',
    name: 'Playwright MCP',
    tier: 5,
    category: 'devops',
    status: 'pending',
    description: 'Browser automation and testing',
    installed: true,
    npmPackage: '@playwright/mcp',
    agents: ['codex'],
    tools: ['browser_navigate', 'screenshot', 'pdf_generate'],
    docs: '/specs/mcp/playwright.yml'
  },
  {
    id: 'chrome-devtools',
    name: 'Chrome DevTools MCP',
    tier: 5,
    category: 'devops',
    status: 'pending',
    description: 'Chrome debugging and automation',
    installed: true,
    npmPackage: 'chrome-devtools-mcp',
    agents: ['codex'],
    tools: ['devtools_connect', 'performance_profile'],
    docs: '/specs/mcp/chrome-devtools.yml'
  },
  {
    id: 'mcp-proxy',
    name: 'MCP Proxy',
    tier: 5,
    category: 'devops',
    status: 'active',
    description: 'SSE proxy for stdio MCP servers',
    installed: true,
    npmPackage: 'mcp-proxy',
    agents: ['all'],
    tools: ['proxy_stdio_to_sse'],
    docs: '/specs/mcp/mcp-proxy.yml'
  }
];

// Update stats
function updateStats() {
  const total = mcpData.length;
  const active = mcpData.filter(m => m.status === 'active').length;
  const installed = mcpData.filter(m => m.installed).length;
  const tier1 = mcpData.filter(m => m.tier === 1).length;
  
  document.getElementById('total-mcps').textContent = total;
  document.getElementById('active-mcps').textContent = active;
  document.getElementById('installed-mcps').textContent = installed;
  document.getElementById('tier1-mcps').textContent = tier1;
}

// Render MCP cards
function renderMCPs(filter = 'all', search = '') {
  const grid = document.getElementById('mcp-grid');
  let filtered = mcpData;
  
  // Apply tier filter
  if (filter !== 'all') {
    if (filter === 'active') {
      filtered = filtered.filter(m => m.status === 'active');
    } else if (filter.startsWith('tier')) {
      const tierNum = parseInt(filter.replace('tier', ''));
      filtered = filtered.filter(m => m.tier === tierNum);
    }
  }
  
  // Apply search
  if (search) {
    filtered = filtered.filter(m => 
      m.name.toLowerCase().includes(search.toLowerCase()) ||
      m.description.toLowerCase().includes(search.toLowerCase()) ||
      m.tools.some(t => t.toLowerCase().includes(search.toLowerCase()))
    );
  }
  
  grid.innerHTML = filtered.map(mcp => `
    <div class="mcp-card" onclick="showMCPDetails('${mcp.id}')">
      <div class="mcp-header">
        <div>
          <h3>${mcp.name}</h3>
          <span class="tier-badge">Tier ${mcp.tier}</span>
        </div>
        <span class="status-badge status-${mcp.status}">${mcp.status}</span>
      </div>
      <p class="mcp-description">${mcp.description}</p>
      <div class="mcp-meta">
        <span>📦 ${mcp.installed ? 'Installed' : 'Not installed'}</span>
        <span>🤖 ${mcp.agents.length} agents</span>
        <span>🔧 ${mcp.tools.length} tools</span>
      </div>
      <div class="mcp-tags">
        ${mcp.tools.slice(0, 3).map(tool => `<span class="tag">${tool}</span>`).join('')}
        ${mcp.tools.length > 3 ? `<span class="tag">+${mcp.tools.length - 3} more</span>` : ''}
      </div>
      <div class="mcp-actions">
        <button class="btn btn-primary" onclick="event.stopPropagation(); showMCPDetails('${mcp.id}')">Details</button>
        ${mcp.npmPackage ? `<button class="btn btn-secondary" onclick="event.stopPropagation(); installMCP('${mcp.id}')">Install</button>` : ''}
      </div>
    </div>
  `).join('');
}

// Show MCP details in modal
function showMCPDetails(id) {
  const mcp = mcpData.find(m => m.id === id);
  const modal = document.getElementById('mcp-modal');
  const title = document.getElementById('modal-title');
  const body = document.getElementById('modal-body');
  
  title.textContent = mcp.name;
  body.innerHTML = `
    <p><strong>Status:</strong> <span class="status-badge status-${mcp.status}">${mcp.status}</span></p>
    <p><strong>Tier:</strong> ${mcp.tier} - ${mcp.category}</p>
    <p><strong>Description:</strong> ${mcp.description}</p>
    
    ${mcp.endpoint ? `<p><strong>Endpoint:</strong> <code>${mcp.endpoint}</code></p>` : ''}
    ${mcp.dockerImage ? `<p><strong>Docker Image:</strong> <code>${mcp.dockerImage}</code></p>` : ''}
    ${mcp.npmPackage ? `<p><strong>NPM Package:</strong> <code>${mcp.npmPackage}</code></p>` : ''}
    ${mcp.repository ? `<p><strong>Repository:</strong> <a href="${mcp.repository}" target="_blank">${mcp.repository}</a></p>` : ''}
    ${mcp.remoteServer ? `<p><strong>Remote Server:</strong> <code>${mcp.remoteServer}</code></p>` : ''}
    
    <p><strong>Agents:</strong> ${mcp.agents.join(', ')}</p>
    <p><strong>Vault Path:</strong> <code>${mcp.vaultPath}</code></p>
    
    ${mcp.features ? `
      <h3>Features</h3>
      <div class="mcp-tags">
        ${Object.entries(mcp.features).map(([key, value]) => {
          if (Array.isArray(value)) {
            return value.map(v => `<span class="tag">${key}: ${v}</span>`).join('');
          }
          return value ? `<span class="tag">${key}</span>` : '';
        }).join('')}
      </div>
    ` : ''}
    
    <h3>Tools (${mcp.tools.length})</h3>
    <div class="mcp-tags">
      ${mcp.tools.map(tool => `<span class="tag">${tool}</span>`).join('')}
    </div>
    
    ${mcp.dockerImage ? `
      <h3>Docker Installation</h3>
      <pre><code>docker run -i --rm -e GITHUB_PERSONAL_ACCESS_TOKEN \\
  ${mcp.dockerImage}</code></pre>
    ` : ''}
    
    ${mcp.npmPackage ? `
      <h3>NPM Installation</h3>
      <pre><code>pnpm add -g ${mcp.npmPackage}</code></pre>
    ` : ''}
    
    ${mcp.remoteServer ? `
      <h3>Remote Server (OAuth)</h3>
      <pre><code>{
  "servers": {
    "${mcp.id}": {
      "type": "http",
      "url": "${mcp.remoteServer}"
    }
  }
}</code></pre>
    ` : ''}
    
    ${mcp.installed && mcp.endpoint ? `
      <h3>Local Configuration (PAT)</h3>
      <pre><code>{
  "mcpServers": {
    "${mcp.id}": {
      ${mcp.dockerImage ? `"command": "docker",
      "args": ["run", "-i", "--rm", "-e", "GITHUB_PERSONAL_ACCESS_TOKEN", "${mcp.dockerImage}"],` : mcp.npmPackage ? `"command": "npx",
      "args": ["${mcp.npmPackage}"],` : ''}
      "env": {
        "GITHUB_PERSONAL_ACCESS_TOKEN": "\${VAULT:${mcp.vaultPath}#github_token}"
      }
    }
  }
}</code></pre>
    ` : ''}
    
    <p><strong>Documentation:</strong> <a href="${mcp.docs}" target="_blank">${mcp.docs}</a></p>
  `;
  
  modal.classList.add('active');
}

function closeModal() {
  document.getElementById('mcp-modal').classList.remove('active');
}

function installMCP(id) {
  const mcp = mcpData.find(m => m.id === id);
  if (mcp.npmPackage) {
    alert(`To install ${mcp.name}:\n\npnpm add -g ${mcp.npmPackage}`);
  }
}

// Event listeners
document.addEventListener('DOMContentLoaded', () => {
  updateStats();
  renderMCPs();
  
  // Search
  document.getElementById('search').addEventListener('input', (e) => {
    const activeFilter = document.querySelector('.filter-btn.active').dataset.filter;
    renderMCPs(activeFilter, e.target.value);
  });
  
  // Filters
  document.querySelectorAll('.filter-btn').forEach(btn => {
    btn.addEventListener('click', () => {
      document.querySelectorAll('.filter-btn').forEach(b => b.classList.remove('active'));
      btn.classList.add('active');
      const search = document.getElementById('search').value;
      renderMCPs(btn.dataset.filter, search);
    });
  });
  
  // Close modal on outside click
  document.getElementById('mcp-modal').addEventListener('click', (e) => {
    if (e.target.id === 'mcp-modal') {
      closeModal();
    }
  });
  
  // Security Posture tabs
  document.querySelectorAll('.posture-tab').forEach(tab => {
    tab.addEventListener('click', () => {
      document.querySelectorAll('.posture-tab').forEach(t => t.classList.remove('active'));
      tab.classList.add('active');
      loadPostureFindings(tab.dataset.tab);
    });
  });
  
  // Select all findings checkbox
  document.getElementById('select-all-findings')?.addEventListener('change', (e) => {
    document.querySelectorAll('.finding-checkbox').forEach(cb => {
      cb.checked = e.target.checked;
    });
  });
});

// Security Posture Functions
function togglePostureFilters() {
  const panel = document.getElementById('posture-filters-panel');
  const toggleText = document.getElementById('filter-toggle-text');
  
  if (panel.style.display === 'none') {
    panel.style.display = 'grid';
    toggleText.textContent = 'Ocultar filtros';
  } else {
    panel.style.display = 'none';
    toggleText.textContent = 'Mostrar filtros';
  }
}

function loadPostureFindings(type = 'saas') {
  // Mock data - En producción esto vendría de una API
  const findings = {
    saas: [],
    cloud: [],
    fixed: []
  };
  
  const tbody = document.getElementById('posture-findings-body');
  const currentFindings = findings[type] || [];
  
  if (currentFindings.length === 0) {
    tbody.innerHTML = `
      <tr class="no-results">
        <td colspan="7">
          <div class="empty-state">
            <div class="empty-icon">🎉</div>
            <h3>No hay resultados... ¡todavía!</h3>
            <p>Los hallazgos de seguridad de ${type === 'saas' ? 'SaaS' : type === 'cloud' ? 'Nube' : 'corregidos'} aparecerán aquí.</p>
          </div>
        </td>
      </tr>
    `;
  } else {
    // Render findings (cuando haya datos)
    tbody.innerHTML = currentFindings.map(finding => `
      <tr>
        <td><input type="checkbox" class="finding-checkbox"></td>
        <td><span class="severity-badge ${finding.severity}">${finding.severity}</span></td>
        <td>${finding.type}</td>
        <td>${finding.instances}</td>
        <td>${finding.integration}</td>
        <td>${finding.date}</td>
        <td><button class="btn-icon">⋮</button></td>
      </tr>
    `).join('');
  }
}

function applyPostureFilters() {
  const status = document.getElementById('filter-status').value;
  const severity = document.getElementById('filter-severity').value;
  const integration = document.getElementById('filter-integration').value;
  const dateStart = document.getElementById('filter-date-start').value;
  const dateEnd = document.getElementById('filter-date-end').value;
  
  console.log('Applying filters:', { status, severity, integration, dateStart, dateEnd });
  
  // En producción, esto filtraría los hallazgos
  loadPostureFindings(document.querySelector('.posture-tab.active').dataset.tab);
}

function clearPostureFilters() {
  document.getElementById('filter-status').value = 'active';
  document.getElementById('filter-severity').value = 'all';
  document.getElementById('filter-integration').value = 'all';
  document.getElementById('filter-date-start').value = '';
  document.getElementById('filter-date-end').value = '';
  
  loadPostureFindings(document.querySelector('.posture-tab.active').dataset.tab);
}

