@echo off
echo Starting Printer API Server on Network...
echo.
echo API will be available at:
echo - Local: http://localhost:8765
echo - Network: http://%COMPUTERNAME%:8765
echo - IP: http://[YOUR_IP]:8765
echo.

REM Check if port is already in use
netstat -an | find "0.0.0.0:8765" >nul
if %errorlevel% == 0 (
    echo WARNING: Port 8765 is already in use!
    echo Please stop the existing process or change the port.
    pause
    exit
)

REM Add firewall rule (requires admin privileges)
echo Adding Windows Firewall rule for port 8765...
netsh advfirewall firewall delete rule name="Odoo Printer API" >nul 2>&1
netsh advfirewall firewall add rule name="Odoo Printer API" dir=in action=allow protocol=TCP localport=8765 >nul 2>&1

if %errorlevel% == 0 (
    echo Firewall rule added successfully!
) else (
    echo WARNING: Could not add firewall rule. You may need to run as Administrator.
    echo Please manually allow port 8765 in Windows Firewall.
)

echo.
echo Starting server...
python printer_api.py

pause