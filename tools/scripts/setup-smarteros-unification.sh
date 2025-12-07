#!/bin/bash
# SMARTEROS UNIFICATION SETUP
# Ejecutar este script en tu Mac desde ~/dev/2025/

set -e

echo "🚀 SmarterOS - Script de Unificación Completa"
echo "=============================================="
echo ""

# Colores
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Función de logging
log_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

log_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

log_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

log_error() {
    echo -e "${RED}❌ $1${NC}"
}

# Verificar directorio actual
CURRENT_DIR=$(pwd)
log_info "Directorio actual: $CURRENT_DIR"

if [[ ! "$CURRENT_DIR" =~ "dev/2025" ]]; then
    log_warning "No estás en ~/dev/2025/. ¿Continuar de todas formas? (y/n)"
    read -r response
    if [[ ! "$response" =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

# Paso 1: Clonar versión origen de app.smarterbot.cl
log_info "Paso 1: Clonando versión original de app.smarterbot.cl"

if [ -d "app.smarterbot.cl-origen" ]; then
    log_warning "La carpeta app.smarterbot.cl-origen ya existe. ¿Sobrescribir? (y/n)"
    read -r response
    if [[ "$response" =~ ^[Yy]$ ]]; then
        rm -rf app.smarterbot.cl-origen
    else
        log_info "Saltando clonación de origen..."
    fi
fi

if [ ! -d "app.smarterbot.cl-origen" ]; then
    git clone https://github.com/SmarterCL/app.smarterbot.cl.git app.smarterbot.cl-origen
    cd app.smarterbot.cl-origen
    git checkout ccbfa25
    log_success "Versión origen clonada en commit ccbfa25"
    cd ..
else
    log_success "Versión origen ya existe"
fi

# Paso 2: Verificar repos necesarios
log_info "Paso 2: Verificando repositorios necesarios"

REPOS=("app.smarterbot.cl" "app.smarterbot.store")
for repo in "${REPOS[@]}"; do
    if [ -d "$repo" ]; then
        log_success "Repo encontrado: $repo"
    else
        log_error "Repo no encontrado: $repo"
        log_info "Clonando $repo..."
        git clone "https://github.com/SmarterCL/$repo.git"
    fi
done

# Paso 3: Crear estructura de carpetas compartidas
log_info "Paso 3: Creando estructura de paquetes compartidos"

mkdir -p smarteros-shared/ui/components/auth
mkdir -p smarteros-shared/ui/components/assistant
mkdir -p smarteros-shared/api-client
mkdir -p smarteros-shared/types

log_success "Estructura de carpetas creada"

# Paso 4: Copiar componentes compartidos
log_info "Paso 4: Copiando componentes compartidos"

# UnifiedLogin
cat > smarteros-shared/ui/components/auth/UnifiedLogin.tsx << 'EOF'
'use client'
import { SignIn, SignUp, UserButton, useUser } from '@clerk/nextjs'
import { useState } from 'react'

interface UnifiedLoginProps {
  mode?: 'button' | 'modal' | 'full'
  redirectUrl?: string
}

export function UnifiedLogin({ mode = 'button', redirectUrl = '/dashboard' }: UnifiedLoginProps) {
  const { isSignedIn, user, isLoaded } = useUser()
  const [showModal, setShowModal] = useState(false)

  if (!isLoaded) {
    return (
      <div className="flex items-center gap-2">
        <div className="w-8 h-8 bg-gray-200 rounded-full animate-pulse" />
        <div className="w-20 h-4 bg-gray-200 rounded animate-pulse" />
      </div>
    )
  }

  if (isSignedIn) {
    return (
      <div className="flex items-center gap-4">
        <span className="text-sm text-gray-700">
          Hola, <span className="font-semibold">{user.firstName || user.emailAddresses[0].emailAddress}</span>
        </span>
        <UserButton 
          afterSignOutUrl="/"
          appearance={{
            elements: {
              avatarBox: "w-10 h-10"
            }
          }}
        />
      </div>
    )
  }

  if (mode === 'full') {
    return (
      <div className="w-full max-w-md mx-auto">
        <SignIn 
          routing="path" 
          path="/sign-in"
          signUpUrl="/sign-up"
          redirectUrl={redirectUrl}
        />
      </div>
    )
  }

  if (mode === 'modal') {
    return (
      <>
        <button
          onClick={() => setShowModal(true)}
          className="px-6 py-2 bg-gradient-to-r from-blue-600 to-purple-600 text-white font-semibold rounded-lg hover:shadow-lg transition"
        >
          Ingresar
        </button>
        
        {showModal && (
          <div className="fixed inset-0 bg-black/50 flex items-center justify-center z-50" onClick={() => setShowModal(false)}>
            <div className="bg-white rounded-2xl p-8 max-w-md w-full" onClick={e => e.stopPropagation()}>
              <SignIn 
                routing="virtual"
                signUpUrl="/sign-up"
                redirectUrl={redirectUrl}
              />
            </div>
          </div>
        )}
      </>
    )
  }

  return (
    <div className="flex items-center gap-2">
      <a href="/sign-in" className="px-4 py-2 text-gray-700 hover:text-gray-900 font-medium transition">
        Ingresar
      </a>
      <a href="/sign-up" className="px-6 py-2 bg-gradient-to-r from-blue-600 to-purple-600 text-white font-semibold rounded-lg hover:shadow-lg transition">
        Comenzar Gratis
      </a>
    </div>
  )
}
EOF

log_success "UnifiedLogin.tsx creado"

# Types
cat > smarteros-shared/types/workflow.ts << 'EOF'
export interface Workflow {
  id: string
  name: string
  description: string
  category: string
  path: string
  n8n_id: number | null
  endpoint: string
  trigger: 'manual' | 'webhook' | 'schedule'
  schedule?: string
  tags: string[]
  status: 'active' | 'inactive' | 'maintenance'
}

export interface WorkflowManifest {
  version: string
  lastUpdated: string
  repository: string
  categories: string[]
  workflows: Workflow[]
  endpoints: {
    base: string
    automation: {
      execute: string
      list: string
      sync: string
      status: string
      logs: string
    }
  }
}
EOF

log_success "Types creados"

# Paso 5: Copiar componentes a cada repo
log_info "Paso 5: Copiando componentes a cada repositorio"

for repo in "${REPOS[@]}"; do
    if [ -d "$repo" ]; then
        log_info "Actualizando $repo..."
        
        # Crear directorios
        mkdir -p "$repo/components/auth"
        mkdir -p "$repo/components/assistant"
        mkdir -p "$repo/app/api/workflows"
        mkdir -p "$repo/app/api/assistant/chat"
        mkdir -p "$repo/app/api/demo/create"
        mkdir -p "$repo/types"
        
        # Copiar componentes
        cp smarteros-shared/ui/components/auth/UnifiedLogin.tsx "$repo/components/auth/"
        cp smarteros-shared/types/workflow.ts "$repo/types/"
        
        log_success "$repo actualizado"
    fi
done

# Paso 6: Crear archivo de variables de entorno
log_info "Paso 6: Creando template de variables de entorno"

cat > smarteros-shared/.env.template << 'EOF'
# CLERK AUTH - Compartido en todos los repos
NEXT_PUBLIC_CLERK_PUBLISHABLE_KEY=pk_test_c2V0dGxpbmctaG9nLTk3LmNsZXJrLmFjY291bnRzLmRldiQ
CLERK_SECRET_KEY=sk_test_XXX_OBTENER_DE_VPS

# CLERK URLs
NEXT_PUBLIC_CLERK_SIGN_IN_URL=/sign-in
NEXT_PUBLIC_CLERK_SIGN_UP_URL=/sign-up
NEXT_PUBLIC_CLERK_AFTER_SIGN_IN_URL=/dashboard
NEXT_PUBLIC_CLERK_AFTER_SIGN_UP_URL=/onboarding

# API URLs
NEXT_PUBLIC_API_URL=https://api.smarterbot.cl
NEXT_PUBLIC_N8N_URL=https://n8n.smarterbot.cl
N8N_URL=https://n8n.smarterbot.cl
MCP_SERVER_URL=http://localhost:3100

# SUPABASE
NEXT_PUBLIC_SUPABASE_URL=https://xyzcompany.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
SUPABASE_SERVICE_ROLE_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...

# VERCEL (si aplica)
VERCEL_URL=
VERCEL_ENV=development
EOF

log_success "Template de .env creado en smarteros-shared/.env.template"

# Paso 7: Generar reporte
log_info "Paso 7: Generando reporte de instalación"

cat > SETUP-REPORT.md << 'EOF'
# SmarterOS - Reporte de Instalación

## ✅ Completado

1. **Versión origen clonada**: app.smarterbot.cl-origen (commit ccbfa25)
2. **Estructura de carpetas creada**: smarteros-shared/
3. **Componentes compartidos copiados**:
   - UnifiedLogin.tsx
   - Types (workflow.ts)

## 📋 Próximos Pasos

### En cada repositorio (app.smarterbot.cl, app.smarterbot.store):

1. **Copiar variables de entorno**:
   ```bash
   cp ../smarteros-shared/.env.template .env.local
   # Editar .env.local con las claves reales
   ```

2. **Instalar dependencias**:
   ```bash
   pnpm install
   # o
   npm install
   ```

3. **Verificar que @clerk/nextjs esté instalado**:
   ```bash
   pnpm add @clerk/nextjs lucide-react
   ```

4. **Importar UnifiedLogin en tu layout/navbar**:
   ```typescript
   import { UnifiedLogin } from '@/components/auth/UnifiedLogin'
   
   export default function Navbar() {
     return (
       <nav>
         {/* ... */}
         <UnifiedLogin mode="button" />
       </nav>
     )
   }
   ```

### Para implementar la API completa:

1. **Crear API routes** según smarteros-unified-components.tar.gz.txt
2. **Configurar webhooks en N8N**
3. **Probar flujo completo**: Demo → Login → Workflow → Resultado

### Para implementar el widget de ChatGPT:

1. **Copiar SmarterOSAssistant.tsx** de smarteros-unified-components.tar.gz.txt
2. **Crear API route** /api/assistant/chat
3. **Agregar al layout principal**:
   ```typescript
   import { SmarterOSAssistant } from '@/components/assistant/SmarterOSAssistant'
   
   export default function RootLayout({ children }) {
     return (
       <>
         {children}
         <SmarterOSAssistant />
       </>
     )
   }
   ```

## 🔗 Enlaces Útiles

- Documentación completa: SMARTEROS-UNIFICACION-COMPLETA.md (en VPS)
- Componentes listos: smarteros-unified-components.tar.gz.txt (en VPS)
- Automation Manifest: https://github.com/SmarterCL/n8n-workflows/blob/main/automation-manifest.json

## 📞 Soporte

Si tienes dudas, revisa:
1. SMARTEROS-UNIFICACION-COMPLETA.md
2. README.md de cada repo
3. CLERK-CREDENTIALS.txt en el VPS
EOF

log_success "Reporte generado: SETUP-REPORT.md"

# Resumen final
echo ""
echo "=============================================="
log_success "¡Setup completado exitosamente!"
echo "=============================================="
echo ""
log_info "Estructura creada:"
echo "  📁 app.smarterbot.cl-origen/  (versión original, commit ccbfa25)"
echo "  📁 smarteros-shared/          (componentes compartidos)"
echo "  📄 SETUP-REPORT.md            (próximos pasos)"
echo ""
log_warning "Siguiente paso: Copiar .env.template a cada repo y configurar variables"
echo ""
log_info "Lee SETUP-REPORT.md para continuar con la configuración"
echo ""
