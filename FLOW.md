# FLOW.md - Daily Loop de SmarterOS

## 🔄 Ciclo Diario (24 horas)

### 01:00 - Sistema despierta
- Health check de todos los servicios
- Verificación de conectividad

### 02:00 - Backup automático
- N8N ejecuta workflow de backup
- PostgreSQL + volúmenes Docker
- Retención: 7 días

### 03:00 - Recolección de métricas
- Metabase actualiza dashboards
- KPIs del día anterior
- Análisis de ventas/inventario

### 08:00 - Operaciones diarias
- Odoo + Shopify procesan ventas
- Inventario sincronizado
- Facturación automática

### 09:00 - 18:00 - Automatizaciones activas
- N8N ejecuta workflows por trigger
- WhatsApp responde consultas
- Bot IA atiende clientes
- Tracking de pedidos

### 19:00 - Análisis IA
- Smarterbot analiza patrones
- Sugiere mejoras
- Genera reportes

### 20:00 - Decisiones humanas
- Fundador revisa sugerencias vía WhatsApp
- Aprueba/rechaza acciones
- Define prioridades

### 21:00 - Ejecución
- Sistema ejecuta decisiones aprobadas
- Ajustes automáticos

### 23:00 - Cierre de caja 24H
- Estado guardado
- Logs consolidados
- Preparación para siguiente ciclo

### 00:00 - Nueva vuelta comienza
- Sistema mejorado vs día anterior
- Aprendizaje acumulado
