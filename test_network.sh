#!/bin/bash

# Quick Network Printer Test for Linux Server
# Bu script Linux serverdən Windows printer API-ni test edir

echo "🖨️  Odoo Network Printer Tester"
echo "================================"

# Default values
DEFAULT_IP="192.168.1.100"
DEFAULT_PORT="8765"

# Get Windows PC IP
read -p "Windows PC IP [$DEFAULT_IP]: " WINDOWS_IP
WINDOWS_IP=${WINDOWS_IP:-$DEFAULT_IP}

read -p "API Port [$DEFAULT_PORT]: " API_PORT  
API_PORT=${API_PORT:-$DEFAULT_PORT}

API_BASE="http://$WINDOWS_IP:$API_PORT"

echo
echo "🔍 Testing API: $API_BASE"
echo "================================"

# Test 1: Basic connectivity
echo "1️⃣  Testing basic connectivity..."
if curl -s --connect-timeout 5 "$API_BASE/status" > /dev/null; then
    echo "✅ Connection successful!"
else
    echo "❌ Connection failed!"
    echo "   💡 Check:"
    echo "   - Windows PC API server is running?"
    echo "   - Windows Firewall allows port $API_PORT?"
    echo "   - Network connectivity: ping $WINDOWS_IP"
    exit 1
fi

# Test 2: API Status  
echo
echo "2️⃣  Getting API status..."
STATUS=$(curl -s "$API_BASE/status")
if [ $? -eq 0 ]; then
    echo "✅ API Status:"
    echo "$STATUS" | python3 -m json.tool 2>/dev/null || echo "$STATUS"
else
    echo "❌ Failed to get API status"
fi

# Test 3: Available Printers
echo
echo "3️⃣  Getting available printers..."
PRINTERS=$(curl -s "$API_BASE/printers")
if [ $? -eq 0 ]; then
    echo "✅ Available Printers:"
    echo "$PRINTERS" | python3 -m json.tool 2>/dev/null || echo "$PRINTERS"
    
    # Extract printer names for test print
    if command -v jq >/dev/null 2>&1; then
        PRINTER_NAME=$(echo "$PRINTERS" | jq -r '.printers[0].name' 2>/dev/null)
    else
        # Fallback without jq
        PRINTER_NAME=$(echo "$PRINTERS" | grep -o '"name":"[^"]*"' | head -1 | sed 's/"name":"\([^"]*\)"/\1/')
    fi
else
    echo "❌ Failed to get printers"
    PRINTER_NAME=""
fi

# Test 4: Test Print (optional)
if [ ! -z "$PRINTER_NAME" ]; then
    echo
    echo "4️⃣  Test Print Available"
    echo "   Printer found: $PRINTER_NAME"
    read -p "   Do you want to send a test print? (y/N): " DO_PRINT
    
    if [[ $DO_PRINT =~ ^[Yy]$ ]]; then
        echo "   📄 Sending test print..."
        
        TEST_DATA='{
            "printer": "'$PRINTER_NAME'",
            "receipt": {
                "shop_name": "TEST PRINT",
                "address": "Linux Server Test",
                "phone": "Test Connection",
                "receipt_no": "TEST-001",
                "items": [
                    {"name": "Network Test", "qty": 1, "price": 0.00}
                ],
                "total": 0.00,
                "currency": "TEST"
            }
        }'
        
        RESULT=$(curl -s -X POST "$API_BASE/print/formatted" \
            -H "Content-Type: application/json" \
            -d "$TEST_DATA")
            
        if [ $? -eq 0 ]; then
            echo "✅ Test print sent!"
            echo "$RESULT" | python3 -m json.tool 2>/dev/null || echo "$RESULT"
        else
            echo "❌ Test print failed"
        fi
    fi
fi

echo
echo "🎯 Next Steps:"
echo "================================"
echo "1. Copy this API URL to Odoo Custom Printer settings:"
echo "   $API_BASE"
echo
echo "2. In Odoo:"
echo "   - Go to Settings → Custom Printers → Printers"
echo "   - Create new printer or edit existing"
echo "   - Set API URL: $API_BASE"
echo "   - Click 'Test Connection'"
echo "   - Click 'Sync Printers'"
echo
echo "3. Test in Odoo:"
echo "   - Create a sale invoice → Post → Print Invoice"
echo "   - Create a purchase order → Confirm → Print Invoice"
echo

# Save configuration
cat > printer_config.sh << EOF
#!/bin/bash
# Generated printer configuration
export PRINTER_API_URL="$API_BASE"
export WINDOWS_IP="$WINDOWS_IP"
export API_PORT="$API_PORT"

echo "Printer API: \$PRINTER_API_URL"
EOF

chmod +x printer_config.sh
echo "💾 Configuration saved to: printer_config.sh"
echo "   Run: source printer_config.sh"