#!/bin/bash

target_user="$1"
domain=$(echo "$target_user" | awk -F@ '{print $2}')
output_dir="./recon_$target_user"
mkdir -p "$output_dir"

echo "[+] Target: $target_user"
echo "[+] Domain: $domain"
echo "[*] Saving output to: $output_dir"

# 1. theHarvester – Extract emails, hosts, and names
echo "[*] Running theHarvester..."
theHarvester -d "$domain" -l 100 -b all -f "$output_dir/harvester_$domain.html"

# 2. holehe – Check where the email is registered
echo "[*] Checking account presence across platforms..."
holehe "$target_user" > "$output_dir/holehe.txt"

# 3. emailrep.io API – Threat reputation and signal
echo "[*] Gathering reputation intel..."
curl -s "https://emailrep.io/$target_user" | jq '.' > "$output_dir/emailrep.json"

# 4. HaveIBeenPwned – Breach dump check
echo "[*] Checking breach databases..."
curl -s "https://haveibeenpwned.com/unifiedsearch/$target_user" \
  -H 'User-Agent: KaliGPTRecon' \
  | jq '.' > "$output_dir/hibp.json"

# 5. whois domain info (to validate registrant/IT links)
echo "[*] Running whois on domain..."
whois "$domain" > "$output_dir/whois.txt"

# 6. Subdomain recon with dnsenum
echo "[*] Enumerating subdomains..."
dnsenum "$domain" > "$output_dir/dnsenum.txt"

echo "[+] Recon complete for $target_user. Review $output_dir."