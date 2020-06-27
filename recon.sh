#!/bin/bash
echo -e "Which site are you going to hack today 🧐? : \c"
read hax

#Make a projects folder
mkdir ~/projects/$hax
cd ~/projects/$hax

#Run dns.bufferover & tls.bufferover
echo "Scanning sub-domains for $hax"
curl -s https://dns.bufferover.run/dns?q=$hax | cut -f 2 -d "," | cut -d \" -f 1 | cut -d \} -f 1 | cut -d \] -f 1 | cut -d \{ -f 1 | awk NF >> 1.txt
curl -s https://tls.bufferover.run/dns?q=$hax | cut -f 2 -d "," | cut -d \" -f 1 | cut -d \} -f 1 | cut -d \] -f 1 | cut -d \{ -f 1 | awk NF >> 1.txt

#Run certspotter & crtsh
echo "Running certspotter"
curl -s https://certspotter.com/api/v0/certs\?domain\=$hax | jq '.[].dns_names[]' | sed 's/\"//g' | sed 's/\*\.//g' | sort -u | grep $hax >> 1.txt
echo "Running crtsh"
curl -s https://crt.sh/?q=%25.$hax | grep "$hax" | grep "<TD>" | cut -d">" -f2 | cut -d"<" -f1 | sort -u | sed s/*.//g >> 1.txt

#Run Asset-finder
echo "Running asset-finder"
assetfinder --subs-only $hax >> 1.txt

#Run Findomain
echo "Running Findomain"
findomain -t $hax -u 1.txt -q

echo "Initializing Deep DNS Scans!"

#Run amass
echo "Running Amass"
amass enum --passive -d $hax -o 1.txt | wc

#Run Subfinder
echo "Running Subfinder"
subfinder -d $hax -o 1.txt -silent

#Run massdns
echo "Running Massdns"
~/pentest/massdns/./scripts/subbrute.py ~/pentest/massdns/lists/all.txt $hax > ~/projects/$hax/massdns.txt

#Append results
echo "Appending your results in a single file:"
cd ~/projects/$hax
expand massdns.txt >> 1.txt && rm massdns.txt
sort -u 1.txt >> sub.txt && rm 1.txt

#Run resolver
echo "Resolving Subdomains"
shuffledns -d $hax -list sub.txt -massdns ~/pentest/massdns/bin/massdns -r ~/pentest/massdns/lists/resolvers.txt -o resolved.txt -silent
rm sub.txt

#Run chaos-client
chaos -d $hax -o resolved.txt -silent

#Sort IPs
echo "Sorting out IPs for you:"
dig -f resolved.txt +short | grep -o '[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}' >> 1.txt

#Run asnip
asnip -t $hax
cat ips.txt >> 1.txt
sort -u 1.txt >> IPs.txt
rm ips.txt && rm cidrs.txt && rm 1.txt

#Run HTTPX
cat resolved.txt | httpx -o httpx.txt -silent

#Run Webscreenshot
webscreenshot -i httpx.txt -o screenshots

#Run Subzy
echo "Checking for subdomain-takeover vulnerability"
mkdir ~/projects/$hax/takeover
cd takeover/
subzy -targets ~/projects/$hax/resolved.txt >> 1.txt
subzy -targets ~/projects/$hax/httprobe/httpx.txt >> 2.txt
cat 1.txt >> takeover.txt && rm 1.txt
cat 2.txt >> takeover.txt && rm 2.txt
grep "VULNERABLE" takeover.txt >> possible_takeover.txt

#Run Portscan
echo "Running Portscan :)"
cd ~/projects/$hax
naabu -hL IPs.txt -o open_ports.txt -ports full -silent

#Finalize!
echo "All done!! Good Luck & Happy Hunting Hax0r 💀! :-)"
