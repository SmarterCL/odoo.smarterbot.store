from odoo import http
from odoo.http import request

class SmarterOSSeoController(http.Controller):
    @http.route('/robots.txt', auth='public', website=True)
    def robots(self):
        ICP = request.env['ir.config_parameter'].sudo()
        canonical = ICP.get_param('website.primary_canonical_url') or 'https://odoo.smarterbot.cl/'
        lines = [
            'User-agent: *',
            'Disallow: /web/login',
            'Disallow: /web/database',
            'Disallow: /web/signup',
            'Allow: /',
            f'Sitemap: {canonical.rstrip("/")}/sitemap.xml'
        ]
        return request.make_response('\n'.join(lines), [
            ('Content-Type', 'text/plain; charset=utf-8')
        ])
