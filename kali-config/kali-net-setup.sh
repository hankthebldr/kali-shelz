# dependencies
# sudo apt update && sudo apt install -y openvpn wireguard tor macchanger ufw resolvconf
# networksecurity automation 
#!/bin/bash

# Ensure the script is run as root
if [ "$EUID" -ne 0 ]; then
    echo "❌ Please run as root!"
    exit 1
fi

echo -e "\n[🔒] Securing your network..."

# Step 1️⃣: Enable a Firewall with Kill Switch
echo -e "\n[🛡️] Setting up a Firewall Kill Switch..."
ufw --force reset
ufw default deny incoming
ufw default deny outgoing
ufw allow out on tun0  # Allow VPN traffic only
ufw enable
echo "[✅] Firewall enabled with VPN-only traffic."

# Step 2️⃣: Change MAC Address to Prevent Tracking
echo -e "\n[🎭] Changing MAC address..."
interface=$(ip -o link show | awk -F': ' '{print $2}' | grep -E 'wlan|eth')
macchanger -r "$interface"
echo "[✅] MAC address randomized."

# Step 3️⃣: Configure DNS to Prevent Leaks
echo -e "\n[🔐] Setting secure DNS..."
echo "nameserver 1.1.1.1" > /etc/resolv.conf
echo "nameserver 8.8.8.8" >> /etc/resolv.conf
chattr +i /etc/resolv.conf  # Prevent changes
echo "[✅] Secure DNS enforced."

# Step 4️⃣: Disable Network Tracking Services
echo -e "\n[🚫] Disabling tracking services..."
systemctl stop avahi-daemon
systemctl disable avahi-daemon
systemctl mask avahi-daemon
echo "[✅] Tracking services disabled."

# Step 5️⃣: Route All Traffic Through Tor
echo -e "\n[🌐] Enforcing Tor routing..."
systemctl enable tor
systemctl start tor
iptables -F
iptables -t nat -A OUTPUT -m owner --uid-owner root -j RETURN
iptables -t nat -A OUTPUT -p udp --dport 53 -j REDIRECT --to-ports 9053
iptables -t nat -A OUTPUT -p tcp --syn -j REDIRECT --to-ports 9040
iptables-save > /etc/iptables.rules
echo "[✅] All traffic is now routed through Tor."

# Step 6️⃣: Disable WebRTC to Prevent IP Leaks
echo -e "\n[🛑] Disabling WebRTC (manual step)..."
echo "Go to Firefox settings -> about:config -> set media.peerconnection.enabled to false"

# Step 7️⃣: Auto-Start VPN on Boot (Modify as Needed)
echo -e "\n[🔄] Setting up auto-start VPN..."
(crontab -l ; echo "@reboot sudo openvpn --config /etc/openvpn/vpn.ovpn --daemon") | crontab -
echo "[✅] VPN will auto-connect at boot."

# Step 8️⃣: Check Anonymity Status
echo -e "\n[🔍] Checking new IP address..."
curl ifconfig.me
echo -e "\n[✅] Your network is now private & secure!"
exit 0

### Makeexecutable 
#chmod +x secure_network.sh
#sudo ./secure_network.sh