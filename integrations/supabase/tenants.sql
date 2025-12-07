-- =========================================================
-- SmarterOS - Tenants schema (multi-tenant por RUT)
-- Versión: v0.8.0
-- Última actualización: 2025-11-22 (Phase 3 - Commit 5)
-- =========================================================

-- Extensiones recomendadas
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- Tabla principal de tenants (empresa)
CREATE TABLE IF NOT EXISTS public.tenants (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

  -- Identidad legal en Chile
  rut VARCHAR(16) NOT NULL UNIQUE,          -- ej: 12345678-9
  business_name VARCHAR(255) NOT NULL,      -- Nombre comercial
  contact_email VARCHAR(255),

  -- Dueño del tenant (usuario en Clerk)
  clerk_user_id TEXT NOT NULL,              -- clerk user id
  owner_email TEXT,                         -- redundante para debug

  -- Servicios activados del OS
  services_enabled JSONB NOT NULL DEFAULT
    '{
      "crm": false,
      "bot": false,
      "erp": false,
      "workflows": false,
      "kpi": false
    }'::JSONB,

  -- IDs de integración con otros servicios
  chatwoot_inbox_id INTEGER,
  botpress_workspace_id TEXT,
  odoo_company_id INTEGER,
  n8n_project_id TEXT,
  metabase_dashboard_id TEXT,

  -- Estado y metadata
  active BOOLEAN DEFAULT TRUE,
  
  -- Timestamps
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Índices para performance
CREATE INDEX IF NOT EXISTS idx_tenants_clerk_user
  ON public.tenants (clerk_user_id);

CREATE INDEX IF NOT EXISTS idx_tenants_rut
  ON public.tenants (rut);

CREATE INDEX IF NOT EXISTS idx_tenants_active
  ON public.tenants (active) WHERE active = TRUE;

-- Trigger para updated_at automático
CREATE OR REPLACE FUNCTION public.tenants_set_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_tenants_set_updated_at ON public.tenants;

CREATE TRIGGER trg_tenants_set_updated_at
BEFORE UPDATE ON public.tenants
FOR EACH ROW EXECUTE PROCEDURE public.tenants_set_updated_at();

-- =========================================================
-- RLS (Row Level Security) - base
-- =========================================================
-- IMPORTANTE: Las requests desde el frontend usan el JWT de Supabase.
-- clerk_user_id debe matchear auth.uid()

ALTER TABLE public.tenants ENABLE ROW LEVEL SECURITY;

-- Política: cada usuario ve SOLO sus tenants
DROP POLICY IF EXISTS "tenants_select_own" ON public.tenants;
CREATE POLICY "tenants_select_own"
ON public.tenants
FOR SELECT
USING (clerk_user_id = auth.uid()::TEXT);

-- Política: cada usuario crea SOLO sus tenants
DROP POLICY IF EXISTS "tenants_insert_own" ON public.tenants;
CREATE POLICY "tenants_insert_own"
ON public.tenants
FOR INSERT
WITH CHECK (clerk_user_id = auth.uid()::TEXT);

-- Política: updates limitados al dueño
DROP POLICY IF EXISTS "tenants_update_own" ON public.tenants;
CREATE POLICY "tenants_update_own"
ON public.tenants
FOR UPDATE
USING (clerk_user_id = auth.uid()::TEXT)
WITH CHECK (clerk_user_id = auth.uid()::TEXT);

-- Política: deletes limitados al dueño (soft delete recomendado vía active=false)
DROP POLICY IF EXISTS "tenants_delete_own" ON public.tenants;
CREATE POLICY "tenants_delete_own"
ON public.tenants
FOR DELETE
USING (clerk_user_id = auth.uid()::TEXT);

-- =========================================================
-- Funciones helper (opcional)
-- =========================================================

-- Función para obtener tenant_id del contexto actual
CREATE OR REPLACE FUNCTION public.current_tenant_id()
RETURNS UUID AS $$
  SELECT id FROM public.tenants 
  WHERE clerk_user_id = auth.uid()::TEXT 
  LIMIT 1;
$$ LANGUAGE SQL STABLE;

-- =========================================================
-- Comentarios de documentación
-- =========================================================

COMMENT ON TABLE public.tenants IS 'Multi-tenant registry - one row per company/RUT';
COMMENT ON COLUMN public.tenants.rut IS 'Chilean RUT (tax ID) - format: 12345678-9';
COMMENT ON COLUMN public.tenants.clerk_user_id IS 'Clerk auth user ID (owner of this tenant)';
COMMENT ON COLUMN public.tenants.services_enabled IS 'JSON object tracking which OS services are active for this tenant';
COMMENT ON COLUMN public.tenants.chatwoot_inbox_id IS 'Chatwoot inbox ID created during tenant bootstrap';
COMMENT ON COLUMN public.tenants.botpress_workspace_id IS 'Botpress workspace ID created during tenant bootstrap';
COMMENT ON COLUMN public.tenants.odoo_company_id IS 'Odoo company ID created during tenant bootstrap';
COMMENT ON COLUMN public.tenants.n8n_project_id IS 'n8n project/credential ID created during tenant bootstrap';
COMMENT ON COLUMN public.tenants.metabase_dashboard_id IS 'Metabase dashboard ID for tenant KPIs';
