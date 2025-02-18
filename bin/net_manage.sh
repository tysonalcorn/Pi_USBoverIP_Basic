#!/bin/bash
# /usr/local/bin/wifi_hotspot.sh
# This script checks if wlan0 is connected to a Wi-Fi network. If not,
# it configures wlan0 with a static IP and starts hostapd/dnsmasq
# to create a hotspot for configuration.
#
# NOTE: You must have hostapd and dnsmasq installed and configured.

while true; do
    # Attempt DHCP on eth0
    sudo dhclient eth0 -v
    ETH_IP=$(ip -4 addr show dev eth0 | grep 'inet ' || true)
    if [ -n "$ETH_IP" ]; then
        echo "Ethernet is connected."
        systemctl is-active --quiet hostapd && systemctl stop hostapd
        systemctl is-active --quiet dnsmasq && systemctl stop dnsmasq
    else
        # Attempt DHCP on wlan0 (STA mode)
        sudo dhclient wlan0 -v
        if iwgetid -r >/dev/null 2>&1; then
            echo "Wi-Fi is connected."
            systemctl is-active --quiet hostapd && systemctl stop hostapd
            systemctl is-active --quiet dnsmasq && systemctl stop dnsmasq
        else
            echo "No Ethernet/Wi-Fi. Starting hotspot mode..."
            sudo ifconfig wlan0 192.168.4.1 netmask 255.255.255.0
            systemctl start dnsmasq
            systemctl start hostapd
        fi
    fi
    sleep 30
done
