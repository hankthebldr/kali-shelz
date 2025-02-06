# web one liners

whatweb example.com | tee whatweb.txt

# scan open ports/services 

nmap -p- -sV -T4 example.com -oN nmap_scan.txt

# Identify web technolgies 
whatweb example.com | tee whatweb.txt

# Detect CMS, Plugin, tech stact 

gobuster dir -u https://example.com -w /usr/share/wordlists/dirb/common.txt -t 50 | tee gobuster.txt

