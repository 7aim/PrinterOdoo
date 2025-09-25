#!/bin/bash

# Odoo Printer API Network Setup Guide for Linux Server
# Bu script sizə Windows printer ilə Linux server arasında bağlantı qurmağa kömək edir

echo "=== Odoo Printer API Network Setup ==="
echo

# Windows PC IP-ni tapın
echo "1. Windows PC IP Address-ini tapın:"
echo "   Windows PC-də cmd-də: ipconfig"
echo "   Nümunə: 192.168.1.100"
echo

# Test connection
read -p "Windows PC IP address daxil edin (məs: 192.168.1.100): " WINDOWS_IP

if [ -z "$WINDOWS_IP" ]; then
    echo "ERROR: IP address daxil edilməlidir!"
    exit 1
fi

API_URL="http://$WINDOWS_IP:8765"

echo
echo "2. Bağlantını test edirik..."
echo "API URL: $API_URL"
echo

# Test API connection
if command -v curl >/dev/null 2>&1; then
    echo "Testing connection with curl..."
    if curl -s --connect-timeout 5 "$API_URL/status" >/dev/null; then
        echo "✅ SUCCESS: API server accessible!"
        echo
        echo "API Status:"
        curl -s "$API_URL/status" | python3 -m json.tool 2>/dev/null || curl -s "$API_URL/status"
    else
        echo "❌ ERROR: Cannot connect to API server!"
        echo
        echo "Troubleshooting steps:"
        echo "1. Windows PC-də API server işləyir?"
        echo "2. Windows Firewall port 8765-i açıq?"
        echo "3. Network bağlantısı var?"
        echo "4. IP address düzgün?"
    fi
elif command -v wget >/dev/null 2>&1; then
    echo "Testing connection with wget..."
    if wget -q --spider --timeout=5 "$API_URL/status"; then
        echo "✅ SUCCESS: API server accessible!"
    else
        echo "❌ ERROR: Cannot connect to API server!"
    fi
else
    echo "curl və ya wget yüklənməlidir connection test üçün"
fi

echo
echo "3. Odoo konfiqurasiyası:"
echo "   - Custom Printer modulunda API URL-ni dəyişin:"
echo "   - Köhnə: http://127.0.0.1:8765"  
echo "   - Yeni: $API_URL"
echo
echo "4. Test:"
echo "   - Printer konfiqurasiyasında 'Test Connection' basın"
echo "   - 'Sync Printers' ilə printerləri sinxronlaşdırın"
echo

# Create Odoo config snippet
cat > odoo_printer_config.txt << EOF
# Odoo Custom Printer Configuration
# Bu məlumatları Odoo-da daxil edin:

API URL: $API_URL
Test URL: $API_URL/status
Printers URL: $API_URL/printers

# Settings -> Custom Printers -> Printers bölməsində:
# 1. Mövcud printer record-larını silin
# 2. Yeni printer yaradın və API URL-ni yuxarıdakı ilə əvəz edin
# 3. "Sync Printers" basın
# 4. "Test Connection" basın
EOF

echo "Konfiqurasiya faylı yaradıldı: odoo_printer_config.txt"
echo

echo "=== Setup Complete ==="
echo "Windows PC-də: start_network_api.bat faylını işə salın"
echo "Linux Server-də: Odoo-da API URL-ni yuxarıdakı ilə dəyişin"