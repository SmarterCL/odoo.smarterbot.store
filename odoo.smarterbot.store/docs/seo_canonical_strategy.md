# Estrategia SEO de Unificación

## Objetivo

Evitar contenido duplicado entre `odoo.smarterbot.cl` y `odoo.smarterbot.store`, consolidando autoridad y mejorando CTR en búsquedas relacionadas a Odoo en Chile.

## Fases

1. Canonical inmediato (módulo `website_smarteros_seo`).
2. Redirecciones 301 desde `.store` al `.cl` (fecha de corte definida).
3. Sitemap único + actualización en Google Search Console.
4. Depuración de enlaces externos (actualizar links que apuntan a `.store`).
5. Diferenciar contenido si se mantiene `.store` con propósito distinto (marketplace / integraciones).

## Parámetro Dinámico

`website.primary_canonical_url` permite cambiar el dominio sin tocar código.

## Riesgos si no se migra

- Canibalización de palabras clave.
- Dilución de backlinks.
- Señales de duplicado en indexación futura.
- Desperdicio de presupuesto de rastreo (crawl budget).

## Checklist Post-migración

- [ ] Verificar 301 (no 302) en logs Nginx.
- [ ] Confirmar canonical correcto en fuente HTML.
- [ ] Reenviar sitemap en Search Console.
- [ ] Monitorear cobertura (errores / excluidos).
- [ ] Revisar Core Web Vitals tras cambios.
- [ ] Actualizar robots.txt (remover rutas obsoletas).

## Mejora Futuro

- Implementar prefetch/preconnect para recursos críticos.
- Añadir JSON-LD FAQPage y Service.
- Optimizar imágenes grandes (script incluido).
- Purga selectiva de CSS manteniendo seguridad en templates dinámicos.

