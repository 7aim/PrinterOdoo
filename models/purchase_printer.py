from odoo import models, fields, api
import logging
from datetime import datetime

_logger = logging.getLogger(__name__)

class PurchaseOrderPrinter(models.Model):
    _inherit = 'purchase.order'
    
    def action_print_purchase_invoice(self):
        """Print purchase order invoice using the custom printer"""
        # Find the first active printer
        printer = self.env['custom.printer'].search([('is_active', '=', True)], limit=1)
        
        if not printer:
            return {
                'type': 'ir.actions.client',
                'tag': 'display_notification',
                'params': {
                    'title': 'Error!',
                    'message': 'No active printer found',
                    'type': 'danger'
                }
            }
            
        # Format invoice data for printing
        receipt_data = self._prepare_invoice_print_data(printer)
        
        # Send to printer
        result = printer.send_formatted_receipt(receipt_data)
        
        if result['success']:
            return {
                'type': 'ir.actions.client',
                'tag': 'display_notification',
                'params': {
                    'title': 'Success!',
                    'message': 'Purchase invoice printed successfully',
                    'type': 'success'
                }
            }
        else:
            return {
                'type': 'ir.actions.client',
                'tag': 'display_notification',
                'params': {
                    'title': 'Error!',
                    'message': f"Print failed: {result.get('error', 'Unknown error')}",
                    'type': 'danger'
                }
            }
    
    def _prepare_invoice_print_data(self, printer):
        """Prepare purchase invoice data for printing"""
        company = self.company_id
        
        # Format items data
        items = []
        for line in self.order_line:
            items.append({
                'name': line.product_id.name[:20],  # Limit name length
                'qty': line.product_qty,
                'price': line.price_unit,
            })
        
        # Prepare receipt data
        receipt_data = {
            'shop_name': company.name,
            'address': company.street or '' + (', ' + company.city if company.city else ''),
            'phone': company.phone or '',
            'receipt_no': self.name,
            'items': items,
            'total': self.amount_total,
            'currency': self.currency_id.symbol,
            'date': datetime.now().strftime('%d.%m.%Y %H:%M'),
            'vendor': self.partner_id.name,
            'footer': 'Təşəkkür edirik!'
        }
        
        return receipt_data