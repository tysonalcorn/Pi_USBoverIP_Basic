# Raspberry Pi Zero W USB-over-IP Server

This project sets up a Raspberry Pi Zero W as an open-source USB-over-IP server for industrial equipment maintenance/diagnosis. The system is designed to:

- Automatically start USB/IP services at boot and bind all plugged‑in USB devices.
- Connect to an ethernet or known Wi‑Fi network. If no network is found, the Pi automatically starts a Wi‑Fi hotspot (using hostapd and dnsmasq) so that a user can access the configuration page.
- Serve a simple web configuration page (with basic authentication) to update Wi‑Fi settings and Web UI credentials.
- Be extensible for future security improvements (e.g., zero‑trust authentication).

---

## Folder and File Overview

- **bin/**
  - `usbip_bind_all.sh`: Script to enumerate and bind all plugged‑in USB devices via USB/IP.
  - `net-manage.sh`: Script that checks for an ethernet or Wi‑Fi connection on wlan0 and, if not found, brings up a hotspot so users can access the config page.

- **systemd/**
  - `usbip.service`: Systemd service that starts the USB/IP daemon and runs the USB bind script.
  - `net-manage.service`: Systemd service that runs network management script.

- **hostapd/**
  - `hostapd.conf`: Sample hostapd configuration file to set up the Pi as a hotspot.

- **dnsmasq/**
  - `dnsmasq.conf`: Sample dnsmasq configuration file to provide DHCP/DNS for the hotspot.

- **www/**
  - `config.html`: A simple HTML page that allows an administrator to update Wi‑Fi and web UI credentials.

- **cgi-bin/**
  - `apply.cgi`: A basic CGI script (to be run by your web server) that applies the configuration changes submitted via the HTML page.

- **README.md**
  - This file.

---

## Initial Setup Instructions

### 1. Prepare Your Raspberry Pi

1. **Flash the OS:**  
   Flash a recent Raspberry Pi OS (preferably Lite) onto your SD card and boot your Raspberry Pi Zero W.

2. **Update the System:**  
   Open a terminal or SSH session and run:
   ```bash
   sudo apt-get update
   sudo apt-get upgrade -y
   ```

### 2. Install Required Packages

Install the packages required for USB/IP, hotspot functionality, and the web server:
```bash
sudo apt-get install -y usbip hostapd dnsmasq lighttpd php-cgi apache2-utils
```

### 3. Copy Files from the Package

Assuming you have unzipped the `Pi_USBoverIP.zip` package, copy the files to their proper locations:

- **Scripts:**  
  Copy the files from the `bin/` directory to `/usr/local/bin/` and ensure they are executable:
  ```bash
  sudo cp Pi_USBoverIP/bin/usbip_bind_all.sh /usr/local/bin/
  sudo cp Pi_USBoverIP/bin/net-manage.sh /usr/local/bin/
  sudo chmod +x /usr/local/bin/usbip_bind_all.sh /usr/local/bin/net-manage.sh
  ```

- **Systemd Service Files:**  
  Copy the files from the `systemd/` directory to `/etc/systemd/system/`:
  ```bash
  sudo cp Pi_USBoverIP/systemd/usbip.service /etc/systemd/system/
  sudo cp Pi_USBoverIP/systemd/net-manage.service /etc/systemd/system/
  ```
  Then reload systemd and enable the services:
  ```bash
  sudo systemctl daemon-reload
  sudo systemctl enable usbip.service
  sudo systemctl enable net-manage.service
  ```

- **Hostapd Configuration:**  
  Copy the file from `hostapd/` to `/etc/hostapd/`:
  ```bash
  sudo cp Pi_USBoverIP/hostapd/hostapd.conf /etc/hostapd/
  ```
  Then, edit `/etc/default/hostapd` and set:
  ```
  DAEMON_CONF="/etc/hostapd/hostapd.conf"
  ```

- **Dnsmasq Configuration:**  
  Copy the file from `dnsmasq/` to `/etc/dnsmasq.d/` (or replace `/etc/dnsmasq.conf` if you prefer):
  ```bash
  sudo cp Pi_USBoverIP/dnsmasq/dnsmasq.conf /etc/dnsmasq.d/
  ```

- **Web Files:**  
  Copy `config.html` from the `www/` directory to your web server’s document root (typically `/var/www/html/`):
  ```bash
  sudo cp Pi_USBoverIP/www/config.html /var/www/html/
  ```

- **CGI Script:**  
  Copy `apply.cgi` from the `cgi-bin/` directory to your CGI directory (typically `/usr/lib/cgi-bin/`) and mark it as executable:
  ```bash
  sudo cp Pi_USBoverIP/cgi-bin/apply.cgi /usr/lib/cgi-bin/
  sudo chmod +x /usr/lib/cgi-bin/apply.cgi
  ```

- **Lighttpd CGI Module:**  
  Enable CGI in Lighttpd if it isn’t already enabled:
  ```bash
  sudo lighty-enable-mod cgi
  sudo systemctl restart lighttpd
  ```

### 4. Reboot the Raspberry Pi

Reboot your Pi so that all services start automatically on boot:
```bash
sudo reboot
```

---

## Operation

- **Normal Mode:**  
  When a known Wi‑Fi network is available, the Pi will join it and run USB/IP (exporting all connected USB devices).

- **Hotspot Mode:**  
  If no known Wi‑Fi is detected, the Pi brings up a hotspot (SSID defined in `hostapd.conf`). Connect to the hotspot (default IP: `192.168.4.1`), then open a browser and navigate to `http://192.168.4.1/config.html` to adjust settings.

- **USB/IP:**  
  Any USB device plugged into the Pi is automatically bound and exported via USB/IP. You can also rebind manually with:
  ```bash
  sudo /usr/local/bin/usbip_bind_all.sh
  ```

---

## Troubleshooting

- **Logs:**  
  Check service logs with:
  ```bash
  sudo journalctl -u usbip.service
  sudo journalctl -u net-manage.service
  ```
- **USB/IP:**  
  Use `lsusb` and `usbip list -l` to verify devices are detected and bound.
- **Wi-Fi:**  
  Verify that `iwgetid -r` returns the SSID when connected, and review hostapd/dnsmasq logs if in hotspot mode.

---

## Security Considerations

- The web configuration page uses basic HTTP authentication (via Lighttpd and an `.htpasswd` file – ensure you update credentials).
- For remote access, secure the communications (e.g., using a VPN or HTTPS).
- Future improvements can include zero‑trust authentication and trusted‑device verification.

*This package is a starting point. Further hardening and testing are recommended before production deployment.*