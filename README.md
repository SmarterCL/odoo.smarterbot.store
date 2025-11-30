# odoo.smarterbot.store → Unificación SEO y Nomenclatura

Este repositorio corresponde al dominio `odoo.smarterbot.store`. Se establece el principio: **Repo = Dominio**. Para evitar contenido duplicado con `odoo.smarterbot.cl` se incluye un módulo SEO que agrega canonical y meta tags, y se documenta la estrategia de migración.

## Módulo SEO incluido

`website_smarteros_seo`:

- Canonical dinámico vía parámetro `website.primary_canonical_url`.
- Meta tags Open Graph + Twitter.
- JSON-LD (Organization) base.
- Listo para extender con FAQ / Services.

## Instalación rápida

1. Copiar el módulo a la carpeta de addons del contenedor Odoo.
2. Actualizar con `-u website_smarteros_seo`.
3. Ajustar parámetro si cambia el dominio principal.
4. Verificar en el HTML la etiqueta `<link rel="canonical">`.

## Script de optimización de imágenes

`scripts/optimize_images.sh` genera variantes WebP y reduce tamaño (usa `cwebp` y `magick` si están disponibles).

## Estrategia de Unificación

Ver `docs/seo_canonical_strategy.md` para fases y checklist.

---

## Ejemplo Canonical

```html
<link rel="canonical" href="https://odoo.smarterbot.cl/">
```

Sirve para:

- Evitar contenido duplicado entre dos dominios.
- Evitar penalización SEO por páginas idénticas.
- Indicar al buscador cuál URL debe indexar como principal.

Importante:

Si cada dominio tendrá contenido distinto (ya aplicaste principio Repo = Dominio) entonces NO necesitas canonical cruzada ahora. Solo úsalo cuando el mismo contenido aparece simultáneamente en dos dominios.

Estado actual:

✔ No es prioridad inmediata.
✔ Problema resuelto con la separación (1 repo = 1 dominio).
✔ Canonical se puede añadir más adelante sin urgencia.

---

```text
╔═══════════════════════════════════════════════════════════════╗
║          ✅ NOMENCLATURA COMPLETADA - PRINCIPIO APLICADO       ║
╠═══════════════════════════════════════════════════════════════╣
║ Repo = Dominio                                                 ║
╚═══════════════════════════════════════════════════════════════╝

📦 Repositorios GitHub:
  • https://github.com/SmarterCL/odoo.smarterbot.cl
  • https://github.com/SmarterCL/odoo.smarterbot.store

📁 Estructura Local (ejemplo):
  /root/
    ├── odoo.smarterbot.cl/
    └── odoo.smarterbot.store/

Principio aplicado a componentes:
┌────────────┬────────────────────┬───────────────────────┐
│ Componente │ .cl                │ .store                │
├────────────┼────────────────────┼───────────────────────┤
│ Repository │ odoo.smarterbot.cl │ odoo.smarterbot.store │
├────────────┼────────────────────┼───────────────────────┤
│ Domain     │ odoo.smarterbot.cl │ odoo.smarterbot.store │
└────────────┴────────────────────┴───────────────────────┘

Documentación relacionada (en entorno original):
  - rename-repos-documentation.md
  - SMARTEROS-SPECS-UPDATE-2025-11-30.md
  - README-SMARTEROS-OS.md

✅ Nomenclatura consistente aplicada.
```

---

## Próximos pasos sugeridos

- Activar redirecciones 301 desde `.store` si se decide consolidar.
- Añadir sitemap único y robots.txt actualizado.
- Medir impacto en Search Console (cobertura / rendimiento).
- Extender JSON-LD para FAQ y servicios específicos.
- Completar FAQ real y descomentar bloque FAQPage en `website_smarteros_seo_extended.xml`.
- Optimizar imágenes y reemplazar `<img>` por `<picture>` con `srcset`.

## Comandos útiles

```bash
# Actualizar el módulo
odoo -u website_smarteros_seo -d <database>

# Cambiar parámetro canonical (en shell Odoo)
python -c "import odoo; odoo.cli.main(['','shell','-d','<database>','-c','/etc/odoo/odoo.conf','-p','print(env['ir.config_parameter'].sudo().set_param('website.primary_canonical_url', 'https://odoo.smarterbot.cl/'))'])"

# Ver robots.txt servido
curl -s https://odoo.smarterbot.store/robots.txt

# Regenerar/forzar sitemap (Odoo suele manejarlo automáticamente)
curl -I https://odoo.smarterbot.store/sitemap.xml
```
