from odoo import models, fields, api
import logging
from datetime import datetime

_logger = logging.getLogger(__name__)

class AccountMovePrinter(models.Model):
    _inherit = 'account.move'
    
    def action_print_invoice(self):
        """Print invoice using the custom printer"""
        # Only process customer and vendor invoices
        if self.move_type not in ('out_invoice', 'in_invoice'):
            return {
                'type': 'ir.actions.client',
                'tag': 'display_notification',
                'params': {
                    'title': 'Error!',
                    'message': 'Only invoices can be printed',
                    'type': 'danger'
                }
            }
            
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
                    'message': 'Invoice printed successfully',
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
        """Prepare invoice data for printing"""
        company = self.company_id
        invoice_type = "SATIŞ FAKTURASI" if self.move_type == 'out_invoice' else "ALIŞ FAKTURASI"
        
        # Format items data
        items = []
        for line in self.invoice_line_ids:
            if line.display_type == 'line_section' or line.display_type == 'line_note':
                continue
                
            items.append({
                'name': line.product_id.name[:20],  # Limit name length
                'qty': line.quantity,
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
            'date': self.invoice_date.strftime('%d.%m.%Y') if self.invoice_date else datetime.now().strftime('%d.%m.%Y'),
            'time': datetime.now().strftime('%H:%M'),
            'customer': self.partner_id.name,
            'invoice_type': invoice_type,
            'footer': 'Təşəkkür edirik!'
        }
        
        return receipt_data