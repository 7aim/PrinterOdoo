# Network Printer Setup - Linux Server ↔ Windows Printer

Bu konfiqurasiya Linux serverdəki Odoo-nun Windows PC-dəki printerə çap göndərməsinə imkan verir.

## 🏗️ Arxitektura

```
Linux Server (Odoo) → HTTP Request → Windows PC (API) → Local Printer
```

## 📋 Tələblər

### Windows PC-də:
- Python 3.6+
- Qoşulmuş printer
- Network bağlantısı

### Linux Server-də:
- Odoo 18
- Network bağlantısı Windows PC ilə
- `requests` library

## 🚀 Qurulum

### 1. Windows PC Setup

1. **Dependencies quraşdırın:**
   ```cmd
   cd c:\odoo_custom_addons\pos_printer\api\
   pip install -r requirements.txt
   ```

2. **Network API server başladın:**
   ```cmd
   start_network_api.bat
   ```
   
   Və ya manual:
   ```cmd
   python printer_api.py
   ```

3. **Windows IP address-ni tapın:**
   ```cmd
   ipconfig
   ```
   Nümunə: `192.168.1.100`

4. **Firewall konfiqurasiyası:**
   - Windows Firewall-da port 8765-i açın
   - Və ya Administrator olaraq `start_network_api.bat` işə salın (avtomatik açacaq)

### 2. Linux Server Setup

1. **Network test edin:**
   ```bash
   chmod +x setup_network.sh
   ./setup_network.sh
   ```

2. **Odoo modulunu quraşdırın:**
   ```bash
   # Modulu addons path-ə kopyalayın
   cp -r pos_printer /opt/odoo/addons/
   
   # Odoo restart
   sudo systemctl restart odoo
   ```

3. **Odoo-da konfiqurasiya:**
   - Apps → "Custom Printer Module" quraşdırın
   - Settings → Custom Printers → Printers
   - API URL-ni dəyişin: `http://192.168.1.100:8765` (öz IP-nizlə)
   - "Test Connection" basın
   - "Sync Printers" basın

## ⚙️ Konfiqurasiya

### API URL Format:
```
http://[WINDOWS_PC_IP]:8765
```

### Test URLs:
- Status: `http://192.168.1.100:8765/status`
- Printers: `http://192.168.1.100:8765/printers`
- Test: `http://192.168.1.100:8765/test`

## 🔧 Troubleshooting

### 1. "Connection refused" xətası
**Problem:** Linux server Windows API-yə çata bilmir
**Həll:**
```bash
# Test connection
curl http://192.168.1.100:8765/status

# Check network
ping 192.168.1.100
```

### 2. "No printers found" xətası
**Problem:** Windows PC-də printer tapılmır
**Həll:**
- Windows-da printer quraşdırılıb?
- Printer status "Ready"?
- API server admin hüquqları ilə işləyir?

### 3. "Print failed" xətası
**Problem:** Çap əmri uğursuz
**Həll:**
```bash
# API log-larına baxın Windows PC-də
# Printer queue-nu yoxlayın Windows-da
```

### 4. Firewall problemi
**Problem:** Port 8765 bloklanıb
**Həll:**
```cmd
# Windows-da (Administrator olaraq)
netsh advfirewall firewall add rule name="Odoo Printer API" dir=in action=allow protocol=TCP localport=8765
```

## 📊 Network Security

### Port Information:
- **Port:** 8765
- **Protocol:** HTTP (TCP)
- **Direction:** Inbound (Windows PC)

### Security Notes:
- API yalnız local network üçün
- HTTPS üçün SSL sertifikat əlavə edin
- IP whitelist əlavə edin (opsional)

## 🔍 Debug & Monitoring

### Windows PC-də log:
```cmd
# API console-da log görünəcək
python printer_api.py
```

### Linux Server-də test:
```bash
# Manual API test
curl -X POST http://192.168.1.100:8765/print \
  -H "Content-Type: application/json" \
  -d '{"printer":"Your_Printer_Name","data":"Test print","type":"receipt"}'
```

### Odoo log:
```bash
# Odoo log faylında printer xətalarını axtarın
tail -f /var/log/odoo/odoo.log | grep -i printer
```

## 📈 Performance Tips

1. **Network latency azaltmaq:**
   - Same subnet istifadə edin
   - Gigabit network

2. **API performance:**
   - Keep-alive connections
   - Connection pooling

3. **Printer performance:**
   - Modern printer driver
   - USB connection Windows PC üçün

## 🆘 Support Commands

### Windows PC-də:
```cmd
# Check if port is open
netstat -an | find "8765"

# Check printer status
wmic printer list status

# Test API locally
curl http://localhost:8765/status
```

### Linux Server-də:
```bash
# Test network connectivity
telnet 192.168.1.100 8765

# Check Odoo process
ps aux | grep odoo

# Check network route
traceroute 192.168.1.100
```

## 📝 Notes

- Bu setup yalnız local network üçün tövsiyə edilir
- Internet üzərindən istifadə üçün VPN və ya SSH tunnel istifadə edin
- Production environment üçün HTTPS və authentication əlavə edin
- Multiple printers dəstəklənir - hər biri üçün ayrı API URL