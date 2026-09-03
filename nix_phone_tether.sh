#!/bin/bash

# Automatic network tethering setup script for a NixOS phone
# Usage: sudo ./nix_phone_tether.sh

set -e  # Stop on error

echo "=== Automatic Network Tethering Setup for NixOS Phone ==="
echo ""

# Process command-line arguments
if [ $# -eq 2 ]; then
    WIFI_IFACE="$1"
    USB_IFACE="$2"
    echo "✓ Using manually specified interfaces"
    echo "  Wi-Fi: $WIFI_IFACE"
    echo "  USB: $USB_IFACE"
    echo ""
else
    # 1. Find the Wi-Fi interface (interface with an IP address)
    echo "[1/4] Searching for Wi-Fi interface..."
    WIFI_IFACE=$(ip -4 addr show | grep -v "127.0.0.1\|172.16\|172.17" | grep "inet " | head -1 | awk '{print $NF}')
    
    if [ -z "$WIFI_IFACE" ]; then
        echo "❌ Wi-Fi interface not found."
        echo ""
        echo "Available interfaces:"
        ip -4 addr show | grep "inet " | awk '{print "  - " $NF " (" $2 ")"}'
        echo ""
        echo "Specify it manually: sudo $0 <wifi_iface> <usb_iface>"
        echo "Example: sudo $0 wlp0s20f3 enp0s20f0u1"
        exit 1
    fi
    
    echo "✓ Wi-Fi interface: $WIFI_IFACE"
    echo ""
    
    # 2. Find the USB interface (172.16.x.x range)
    echo "[2/4] Searching for USB interface..."
    USB_IFACE=$(ip -4 addr show | grep "172.16" | head -1 | awk '{print $NF}')
    
    if [ -z "$USB_IFACE" ]; then
        echo "❌ USB interface not found."
        echo ""
        echo "Available interfaces:"
        ip -4 addr show | grep "inet " | awk '{print "  - " $NF " (" $2 ")"}'
        echo ""
        echo "Specify it manually: sudo $0 <wifi_iface> <usb_iface>"
        echo "Example: sudo $0 wlp0s20f3 enp0s20f0u1"
        exit 1
    fi
    
    echo "✓ USB interface: $USB_IFACE"
    echo ""
fi

# 3. Enable IP forwarding
echo "[3/4] Enabling IP forwarding..."
sudo sysctl -w net.ipv4.ip_forward=1 > /dev/null
echo "✓ IP forwarding enabled"
echo ""

# 4. Configure iptables rules
echo "[4/4] Configuring iptables rules..."
echo "  Running:"
echo "    sudo iptables -t nat -A POSTROUTING -o $WIFI_IFACE -j MASQUERADE"
sudo iptables -t nat -A POSTROUTING -o $WIFI_IFACE -j MASQUERADE

echo "    sudo iptables -A FORWARD -i $USB_IFACE -o $WIFI_IFACE -j ACCEPT"
sudo iptables -A FORWARD -i $USB_IFACE -o $WIFI_IFACE -j ACCEPT

echo "    sudo iptables -A FORWARD -i $WIFI_IFACE -o $USB_IFACE -m state --state RELATED,ESTABLISHED -j ACCEPT"
sudo iptables -A FORWARD -i $WIFI_IFACE -o $USB_IFACE -m state --state RELATED,ESTABLISHED -j ACCEPT

echo "✓ iptables rules configured successfully"
echo ""
echo "=== Setup Complete! ==="
echo ""
echo "Run the following commands on the phone:"
echo "  sudo ip route add default via 172.16.42.2"
echo "  ping -c 3 8.8.8.8"
echo ""
echo "Check the configuration:"
echo "  sudo iptables -L -n -v"
