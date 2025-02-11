# Raspberry Pi Zero W USB-over-IP Server

This project sets up a Raspberry Pi Zero W as an open-source USB-over-IP server for industrial equipment maintenance/diagnosis. The system is designed to:

- Automatically start USB/IP services at boot and bind all plugged‑in USB devices.
- Connect to a known Wi‑Fi network. If no network is found, the Pi automatically starts a Wi‑Fi hotspot (using hostapd and dnsmasq) so that a user can access the configuration page.
- Serve a simple web configuration page (with basic authentication) to update Wi‑Fi settings and Web UI credentials.
- Be extensible for future security improvements (e.g., zero‑trust authentication).

## Folder and File Overview

- **bin/**
  - `usbip_bind_all.sh`: Script to enumerate and bind all plugged‑in USB devices via USB/IP.
  - `wifi_hotspot.sh`: Script that checks for a Wi‑Fi connection on wlan0 and, if not found, brings up a hotspot so users can access the config page.

- **systemd/**
  - `usbip.service`: Systemd service that starts the USB/IP daemon and runs the USB bind script.
  - `wifi-hotspot.service`: Systemd service that runs the Wi‑Fi hotspot fallback script.

- **hostapd/**
  - `hostapd.conf`: Sample hostapd configuration file to set up the Pi as a hotspot.

- **dnsmasq/**
  - `dnsmasq.conf`: Sample dnsmasq configuration file to provide DHCP/DNS for the hotspot.

- **www/**
  - `config.html`: A simple HTML page that allows an administrator to update Wi‑Fi and web UI credentials.

- **cgi-bin/**
  - `apply.cgi`: A basic CGI script (to be run by your web server) that applies the configuration changes submitted via the HTML page.

## Installation & Setup

1. **Install Required Packages**

   For example, on Raspberry Pi OS:
   ```bash
   sudo apt-get update
   sudo apt-get install -y usbip hostapd dnsmasq lighttpd php-cgi apache2-utils
