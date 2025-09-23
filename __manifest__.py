{
    'name': 'Custom Printer Module',
    'version': '1.0',
    'category': 'Tools',
    'summary': 'Custom Printer API for any Odoo module',
    'author': 'Aim',
    'depends': ['base', 'web', 'purchase', 'account'],
    'data': [
        'security/ir.model.access.csv',
        'views/custom_printer_views.xml',
        'views/purchase_printer_views.xml',
        'views/account_printer_views.xml',
    ],
    'installable': True,
    'application': True,
}