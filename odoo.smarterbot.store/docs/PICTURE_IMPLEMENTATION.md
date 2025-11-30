# Ejemplo: Implementación `<picture>` con srcset

Este documento muestra cómo reemplazar etiquetas `<img>` estándar por elementos `<picture>` con soporte WebP y responsive srcset.

## Anatomía de un `<picture>` optimizado

```html
<picture>
  <!-- WebP para navegadores compatibles -->
  <source srcset="/web/image/optimized/hero-dashboard-480.webp 480w,
                  /web/image/optimized/hero-dashboard-768.webp 768w,
                  /web/image/optimized/hero-dashboard-1280.webp 1280w"
          sizes="(max-width: 768px) 100vw, 1280px"
          type="image/webp">
  
  <!-- JPEG fallback con srcset -->
  <source srcset="/web/image/optimized/hero-dashboard-480.jpg 480w,
                  /web/image/optimized/hero-dashboard-768.jpg 768w,
                  /web/image/optimized/hero-dashboard-1280.jpg 1280w"
          sizes="(max-width: 768px) 100vw, 1280px"
          type="image/jpeg">
  
  <!-- Fallback final -->
  <img src="/web/image/optimized/hero-dashboard-1280.jpg"
       alt="Dashboard automatización SmarterOS con IA y n8n"
       loading="lazy"
       decoding="async"
       width="1280"
       height="720">
</picture>
```

## Caso 1: Hero/Banner principal

**Antes:**
```xml
<div class="hero-section">
  <img src="/modern-tech-dashboard-with-automation-flows-and-ai.jpg" alt="Dashboard"/>
</div>
```

**Después (template Odoo):**
```xml
<template id="homepage_hero_optimized" inherit_id="website.homepage">
  <xpath expr="//div[@class='hero-section']//img" position="replace">
    <picture>
      <source srcset="/web/image/optimized/modern-tech-dashboard-with-automation-flows-and-ai.webp"
              type="image/webp">
      <img src="/web/image/optimized/modern-tech-dashboard-with-automation-flows-and-ai.jpg"
           alt="Dashboard de automatización SmarterOS con IA y n8n"
           loading="eager"
           decoding="async"
           width="1280"
           height="720">
    </picture>
  </xpath>
</template>
```

> **Nota:** Hero usa `loading="eager"` (por defecto) para carga inmediata; resto de imágenes `loading="lazy"`.

## Caso 2: Imágenes de servicios (below fold)

**Antes:**
```xml
<img src="/whatsapp-business-chat-integration.jpg" alt="WhatsApp"/>
```

**Después:**
```xml
<picture>
  <source srcset="/web/image/optimized/whatsapp-business-chat-integration.webp"
          type="image/webp">
  <img src="/web/image/optimized/whatsapp-business-chat-integration.jpg"
       alt="Integración WhatsApp Business con Odoo"
       loading="lazy"
       decoding="async"
       width="800"
       height="600">
</picture>
```

## Caso 3: Logos/Iconos (SVG preferido)

Para logos que no son fotos, prioriza SVG cuando sea posible:

```xml
<img src="/logo-smarteros.svg" alt="SmarterOS Logo" width="200" height="50">
```

Si no hay SVG disponible:

```xml
<picture>
  <source srcset="/web/image/optimized/logo-smarteros.webp" type="image/webp">
  <img src="/web/image/optimized/logo-smarteros.png"
       alt="SmarterOS - Automatización Odoo Chile"
       width="200"
       height="50">
</picture>
```

## Generar variantes de tamaño (opcional)

```bash
# Usando ImageMagick para crear versiones responsive
for size in 480 768 1280; do
  magick hero-original.jpg -resize ${size}x -strip -quality 82 hero-${size}.jpg
  cwebp -q 82 hero-${size}.jpg -o hero-${size}.webp
done
```

## Aplicar en templates Odoo existentes

Ubicación típica de templates: `addons/<module>/views/templates.xml`

Estrategia:

1. Identificar templates con `<img>` críticas (hero, banners, features).
2. Crear template heredado con `inherit_id`.
3. Usar `xpath` para reemplazar nodo `<img>` por `<picture>`.
4. Actualizar módulo: `odoo -u <module_name> -d <db>`.

## Verificación

```bash
# Verificar que WebP se sirva en navegadores compatibles
curl -H "Accept: image/webp" -I https://odoo.smarterbot.store/web/image/optimized/hero.webp

# Lighthouse CI (Core Web Vitals)
npx lighthouse https://odoo.smarterbot.store --only-categories=performance --output=json
```

## Impacto esperado

- **LCP (Largest Contentful Paint):** Reducción 20-40% en hero/banner.
- **Peso de página:** Ahorro 60-80% en imágenes (JPEG → WebP).
- **CLS (Cumulative Layout Shift):** 0 si se especifican `width` y `height`.

## Referencias

- [MDN: `<picture>`](https://developer.mozilla.org/en-US/docs/Web/HTML/Element/picture)
- [web.dev: Serve responsive images](https://web.dev/serve-responsive-images/)
- [Can I use WebP](https://caniuse.com/webp)
