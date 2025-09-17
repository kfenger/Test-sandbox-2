#!/bin/bash
set -euo pipefail
sleep 30

# sikre verktøy
if ! command -v nmap >/dev/null 2>&1; then
  apt update && apt install -y nmap netcat-traditional tcpreplay || true
fi

mkdir -p /root/attacks

nmap -sS -Pn 192.168.70.30 -oN /root/attacks/nmap_scan.txt || true

for i in $(seq 1 5); do
  printf 'GET / HTTP/1.1\r\nHost: 192.168.70.30\r\n\r\n' | nc 192.168.70.30 80 || true
  sleep 2
done

if [ -f /root/attacks/malicious.pcap ]; then
  tcpreplay --intf1=eth0 /root/attacks/malicious.pcap || true
fi

echo "Angrepsskript ferdig."
