# SMARTEROS — INCIDENT RESPONSE PLAYBOOK (IRP)

---

## SEVERITY LEVELS

### SEV-1: CRÍTICO
**Impacto:** Servicio completamente caído, múltiples tenants afectados  
**SLA:** Respuesta en 15 min, resolución en 2h  
**Notificación:** Inmediata a CTO + Clientes

### SEV-2: ALTO
**Impacto:** Funcionalidad crítica degradada  
**SLA:** Respuesta en 1h, resolución en 8h  
**Notificación:** DevOps + Product

### SEV-3: MEDIO
**Impacto:** Funcionalidad menor afectada  
**SLA:** Respuesta en 4h, resolución en 48h  
**Notificación:** Ticket normal

---

## FLUJO DE RESPUESTA

### 1. Detección
```bash
# Alerta automática
smarter monitor alert --sev=1

# Validación manual
smarter status --all
```

### 2. Clasificación
- Identificar módulo afectado
- Determinar severidad
- Asignar Incident Commander

### 3. Mitigación
```bash
# Rollback inmediato si es deploy reciente
smarter rollback --service=api --version=previous

# O activar failover
smarter failover enable
```

### 4. Comunicación
```bash
# Actualizar status page
smarter status-page update \
  --message="Investigating API latency issues" \
  --status=degraded

# Notificar clientes SEV-1
smarter notify customers --severity=1
```

### 5. Resolución
- Documentar fix
- Validar recuperación
- Monitorear 1h post-fix

### 6. Postmortem (SEV-1/SEV-2)
**Dentro de 48h:**
- Timeline completo
- Root cause analysis
- Action items
- Prevention measures

---

## INCIDENT LOG

```json
{
  "incident_id": "INC-2025-001",
  "severity": "SEV-1",
  "title": "API Gateway timeout",
  "detected_at": "2025-11-23T10:00:00Z",
  "resolved_at": "2025-11-23T11:30:00Z",
  "affected_tenants": 12,
  "root_cause": "PostgreSQL connection pool exhausted",
  "resolution": "Increased pool size from 20 to 50",
  "preventive_measures": [
    "Add connection pool monitoring",
    "Set up auto-scaling alerts"
  ]
}
```

---

## POSTMORTEM TEMPLATE

```markdown
# Incident Postmortem: [TITLE]

**Date:** YYYY-MM-DD  
**Severity:** SEV-X  
**Duration:** Xh Ym  
**Affected:** X tenants  

## Timeline
- 10:00 - Alert triggered
- 10:05 - Incident declared SEV-1
- 10:15 - Root cause identified
- 11:30 - Service restored

## Root Cause
[Descripción técnica]

## Resolution
[Qué se hizo]

## Impact
- Revenue loss: $XXX
- Customer impact: X users
- SLA breach: Yes/No

## Action Items
- [ ] Item 1 - Owner: Name - Due: Date
- [ ] Item 2 - Owner: Name - Due: Date

## Lessons Learned
[Qué aprendimos]
```

---

**Owner:** Incident Commander  
**Review:** Post-incident
