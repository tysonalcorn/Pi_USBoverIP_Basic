#!/bin/bash
# /usr/local/bin/wifi_hotspot.sh
# This script checks if wlan0 is connected to a Wi-Fi network. If not,
# it configures wlan0 with a static IP and starts hostapd/dnsmasq
# to create a hotspot for configuration.
#
# NOTE: You must have hostapd and dnsmasq installed and configured.

while true; do
    # Check whether wlan0 is associated with a network
    if iwgetid -r >/dev/null 2>&1; then
        echo "Wi-Fi is connected."
        # If hostapd/dnsmasq are running, stop them.
        systemctl is-active --quiet hostapd && systemctl stop hostapd
        systemctl is-active --quiet dnsmasq && systemctl stop dnsmasq
    else
        echo "Wi-Fi not connected. Starting hotspot mode..."
        # Configure wlan0 with a static IP for hotspot use.
        sudo ifconfig wlan0 192.168.4.1 netmask 255.255.255.0
        # Start the DHCP/DNS service and the access point.
        systemctl start dnsmasq
        systemctl start hostapd
    fi
    sleep 30
done
