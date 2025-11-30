# Guía de Instalación - Módulo website_smarteros_seo

## Requisitos previos

- Odoo 16+ (Enterprise o Community con módulo `website`)
- Acceso a shell del contenedor/servidor
- Base de datos Odoo ya creada

## Paso 1: Copiar módulo a addons

```bash
# Si trabajas con Docker/contenedor
docker cp website_smarteros_seo/ <container_name>:/mnt/extra-addons/

# O directamente si tienes acceso al filesystem
cp -r website_smarteros_seo/ /opt/odoo/addons/
```

## Paso 2: Actualizar lista de módulos

Opción A - Desde UI:
1. Ir a Apps → Update Apps List
2. Buscar "Website SmarterOS SEO"
3. Hacer clic en "Install"

Opción B - Línea de comandos:

```bash
# Reiniciar Odoo con actualización del módulo
odoo -u website_smarteros_seo -d <nombre_database> --stop-after-init

# O en contenedor
docker exec -it <container_name> odoo -u website_smarteros_seo -d <nombre_database>
```

## Paso 3: Verificar instalación

```bash
# Revisar canonical en HTML
curl -s https://odoo.smarterbot.store/ | grep -i canonical

# Verificar robots.txt
curl -s https://odoo.smarterbot.store/robots.txt

# Validar JSON-LD (Organization)
curl -s https://odoo.smarterbot.store/ | grep -o '"@type":"Organization"'
```

## Paso 4: Configurar parámetro canonical (opcional)

Si necesitas cambiar el dominio principal desde `.cl` a `.store` u otro:

```bash
# Acceder a shell Odoo
docker exec -it <container_name> odoo shell -d <database>

# Dentro del shell Python de Odoo:
env['ir.config_parameter'].sudo().set_param('website.primary_canonical_url', 'https://odoo.smarterbot.store/')
env.cr.commit()
exit()
```

O desde UI:
1. Activar modo desarrollador
2. Settings → Technical → Parameters → System Parameters
3. Buscar `website.primary_canonical_url`
4. Editar valor

## Paso 5: Optimizar imágenes

```bash
# Ejecutar script de optimización
cd scripts
chmod +x optimize_images.sh

# Optimizar imágenes desde directorio específico
./optimize_images.sh /path/to/odoo/static/src/img /path/to/odoo/static/src/img/optimized

# Para imágenes del sitio web
./optimize_images.sh ../addons/website/static/src/img ../addons/website/static/src/img/optimized
```

## Paso 6: Implementar `<picture>` en templates

Editar templates de página (ejemplo para hero/banner):

```xml
<template id="homepage_hero" inherit_id="website.homepage">
    <xpath expr="//div[@class='hero-image']//img" position="replace">
        <picture>
            <source srcset="/web/image/optimized/hero-dashboard.webp" type="image/webp"/>
            <source srcset="/web/image/optimized/hero-dashboard.jpg" type="image/jpeg"/>
            <img src="/web/image/hero-dashboard.jpg" 
                 alt="Dashboard de automatización SmarterOS"
                 loading="lazy" 
                 decoding="async"
                 width="1280" 
                 height="720"/>
        </picture>
    </xpath>
</template>
```

## Verificación final

Checklist:

- [ ] Módulo instalado sin errores
- [ ] Canonical tag presente en `<head>`
- [ ] `/robots.txt` accesible y correcto
- [ ] JSON-LD Organization renderizado
- [ ] Meta tags Open Graph presentes
- [ ] Imágenes optimizadas (WebP generado)
- [ ] `<picture>` implementado en hero/banner

## Troubleshooting

### Error: módulo no encontrado
```bash
# Verificar que el path de addons esté en odoo.conf
grep addons_path /etc/odoo/odoo.conf

# Reiniciar Odoo completamente
docker restart <container_name>
```

### Canonical no aparece
```bash
# Verificar que el template se haya heredado correctamente
# Desde shell Odoo:
env['ir.ui.view'].search([('name', '=', 'SmarterOS SEO Head')])
```

### Robots.txt da 404
- Verificar que el controlador esté cargado: revisar logs de Odoo al iniciar
- Confirmar que `website=True` en la ruta

## Comandos rápidos

```bash
# Actualizar módulo tras cambios
odoo -u website_smarteros_seo -d <db>

# Ver parámetro actual
odoo shell -d <db>
>>> env['ir.config_parameter'].sudo().get_param('website.primary_canonical_url')

# Validar structured data con Google
# Visitar: https://search.google.com/test/rich-results
# Pegar URL: https://odoo.smarterbot.store/
```
