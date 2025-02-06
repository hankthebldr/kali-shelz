#!/bin/bash
# Install requred packages
apt update && apt install -y nikto nmap sqlmap gobuster searchsploit dirsearch xsser

# Check if a target URL is provided

if [ "$#" -ne 1 ]; then
    echo "Usage: bash web_attack_automation.sh https://example.com"
    exit 1
fi

TARGET=$1
TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")
RESULT_DIR="scan_results"
REPORT_FILE="$RESULT_DIR/report_$TIMESTAMP.txt"

# Create results directory if not exists
mkdir -p "$RESULT_DIR"

# Function to log and run commands
log_and_run() {
    echo -e "\n[🔍] Running: $2..."
    echo -e "\n[🔥] $2\n" >> "$REPORT_FILE"
    eval "$1" | tee -a "$REPORT_FILE"
}

echo -e "\n🚀 Starting Web Attack Automation Script..."
echo -e "\n[🌐] Target: $TARGET"
echo -e "\n📌 Report will be saved at: $REPORT_FILE"

# 🚀 Step 1: Run Nikto Web Scan
log_and_run "nikto -h $TARGET | tee $RESULT_DIR/nikto.txt" "Nikto Web Vulnerability Scan"

# 🚀 Step 2: Extract OSVDB vulnerabilities & search for exploits
echo -e "\n[🔍] Searching for exploits related to detected vulnerabilities..."
OSVDB_VULNS=$(grep "OSVDB" "$RESULT_DIR/nikto.txt" | cut -d " " -f2)

if [ -n "$OSVDB_VULNS" ]; then
    echo -e "\n[🔥] OSVDB Exploits Found:\n" >> "$REPORT_FILE"
    for osvdb_id in $OSVDB_VULNS; do
        EXPLOIT_RESULT=$(searchsploit "$osvdb_id")
        echo -e "\nOSVDB-$osvdb_id:\n$EXPLOIT_RESULT\n" | tee -a "$REPORT_FILE"
    done
else
    echo -e "[✅] No OSVDB vulnerabilities found." | tee -a "$REPORT_FILE"
fi

# 🚀 Step 3: Run SQLMap for SQL Injection Testing
log_and_run "sqlmap -u '$TARGET' --batch --level=5 --risk=3 --dbs" "SQL Injection Testing with SQLMap"

# 🚀 Step 4: Run Nmap for Open Ports & Web Services
log_and_run "nmap -p- -sV -A $TARGET" "Full Port Scan & Service Enumeration"

# 🚀 Step 5: Run Gobuster for Directory Enumeration
log_and_run "gobuster dir -u '$TARGET' -w /usr/share/wordlists/dirb/common.txt -t 50" "Directory Brute Forcing with Gobuster"

# 🚀 Step 6: Run Dirsearch for More Directory Scanning
log_and_run "dirsearch -u '$TARGET' -e php,html,txt,zip -t 50" "Advanced Directory Enumeration with Dirsearch"

# 🚀 Step 7: Run XSSer for Cross-Site Scripting (XSS) Testing
log_and_run "xsser --url '$TARGET'" "XSS Testing with XSSer"

# 🚀 Step 8: Finalizing Report
echo -e "\n✅ Web scanning & attack automation complete! Results saved in: $REPORT_FILE"