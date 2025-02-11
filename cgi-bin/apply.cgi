#!/bin/bash
# /usr/lib/cgi-bin/apply.cgi
# A simple (and rudimentary) CGI script to update Wi-Fi and Web UI credentials.
# (For a production system, use proper error checking and secure input handling.)

echo "Content-type: text/html"
echo ""

# Read POST data from stdin (assumes application/x-www-form-urlencoded)
read -n $CONTENT_LENGTH POST_DATA

# Rudimentary parsing (percent-decoding is not fully handled here)
SSID=$(echo "$POST_DATA" | sed -n 's/.*ssid=\([^&]*\).*/\1/p')
WIFIPASS=$(echo "$POST_DATA" | sed -n 's/.*wifipassword=\([^&]*\).*/\1/p')
USERNAME=$(echo "$POST_DATA" | sed -n 's/.*username=\([^&]*\).*/\1/p')
PASSWORD=$(echo "$POST_DATA" | sed -n 's/.*password=\([^&]*\).*/\1/p')

# Apply new Wi-Fi settings.
echo "<p>Updating Wi-Fi settings...</p>"
sudo cp /etc/wpa_supplicant/wpa_supplicant.conf /etc/wpa_supplicant/wpa_supplicant.conf.bak
sudo bash -c "cat > /etc/wpa_supplicant/wpa_supplicant.conf" <<EOF
ctrl_interface=DIR=/var/run/wpa_supplicant GROUP=netdev
update_config=1
country=US

network={
    ssid=\"$SSID\"
    psk=\"$WIFIPASS\"
}
EOF

# Update web UI credentials.
echo "<p>Updating Web UI credentials...</p>"
# (In this example, we simply write a new .htpasswd file.
#  In production, you should encrypt passwords appropriately.)
echo "$USERNAME:$PASSWORD" | sudo tee /etc/lighttpd/.htpasswd >/dev/null

cat <<EOF
<html>
<head>
  <title>Settings Updated</title>
</head>
<body>
  <h1>Settings have been updated.</h1>
  <p>The device may reconnect or require a reboot.</p>
  <a href="/config.html">Back to Config</a>
</body>
</html>
EOF
