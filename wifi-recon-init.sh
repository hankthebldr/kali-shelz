#!/bin/bash

# Function to display usage instructions
function usage() {
    echo "Usage: $0 <interface> <network_prefix>"
    echo "Example: $0 wlan0 192.168.1.0/24"
    exit 1
}

# Check if network interface and prefix are provided
if [ -z "$1" ] || [ -z "$2" ]; then
    usage
fi

# Variables
INTERFACE=$1
NETWORK_PREFIX=$2

# Enable Monitor Mode
echo "Enabling monitor mode on $INTERFACE..."
sudo airmon-ng start $INTERFACE

# Scan for Networks
echo "Scanning for networks..."
sudo airodump-ng ${INTERFACE}mon -w scan_results --output-format csv

# Extract BSSID and Channel of the first network found
BSSID=$(awk -F, 'NR==2{print $1}' scan_results-01.csv)
CHANNEL=$(awk -F, 'NR==2{print $4}' scan_results-01.csv | xargs)

if [ -z "$BSSID" ] || [ -z "$CHANNEL" ]; then
    echo "No networks found. Exiting..."
    sudo airmon-ng stop ${INTERFACE}mon
    exit 1
fi

# Capture Packets on the specified network
echo "Capturing packets on BSSID: $BSSID, Channel: $CHANNEL..."
sudo airodump-ng --bssid $BSSID --channel $CHANNEL -w capture ${INTERFACE}mon

# Stop Monitor Mode
echo "Stopping monitor mode on $INTERFACE..."
sudo airmon-ng stop ${INTERFACE}mon

# Scan with Kismet
echo "Running Kismet..."
sudo kismet -c ${INTERFACE}

# Run Wifite for automated attacks
echo "Running Wifite..."
sudo wifite

# Network Discovery with Netdiscover
echo "Running Netdiscover..."
sudo netdiscover -r $NETWORK_PREFIX

# Note for manual Wireshark usage
echo "To analyze captured packets, use Wireshark manually."
echo "Run: sudo wireshark and open the capture files generated."

echo "Network scanning and inspection completed."
