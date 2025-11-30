# Odoo Landing - smarterbot.store

Landing page para Odoo ERP Chile - Domain `.store`

## 🌐 Live
https://odoo.smarterbot.store/

## 🚀 Stack
- Next.js 15 + TypeScript
- Tailwind CSS + Shadcn/ui
- WCAG 2.1 AA compliant
- Docker ready

## 📦 Deploy
```bash
docker build -t odoo-store:latest .
docker run -d --name odoo-store -p 3000:3000 odoo-store:latest
```
