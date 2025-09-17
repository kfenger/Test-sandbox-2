#!/bin/bash
set -euo pipefail

IFACE="${CAPTURE_IFACE:-eth1}"
OUTDIR="${PCAP_OUTDIR:-/var/tmp/pcap_out}"
PCAP_PREFIX="${PCAP_PREFIX:-lab_capture}"
ROTATE_SECONDS="${ROTATE_SECONDS:-60}"
MALCOLM_USER="${MALCOLM_USER:-admin}"
MALCOLM_HOST="${MALCOLM_HOST:-10.50.10.10}"
MALCOLM_DEST_DIR="${MALCOLM_DEST_DIR:-/opt/malcolm/incoming_pcaps}"
SSH_KEY="${SSH_KEY:-/root/.ssh/id_rsa}"
MAX_AGE_DAYS="${MAX_AGE_DAYS:-7}"
SCP_OPTS="-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -q"

mkdir -p "$OUTDIR"
mkdir -p "$MALCOLM_DEST_DIR" || true

command -v tcpdump >/dev/null || { echo "tcpdump mangler. Installer: apt install -y tcpdump"; exit 1; }

while true; do
  TIMESTAMP=$(date +%Y%m%d-%H%M%S)
  PCAP_FILE="$OUTDIR/${PCAP_PREFIX}_${TIMESTAMP}.pcap"
  timeout "$ROTATE_SECONDS" tcpdump -nn -s 0 -i "$IFACE" -w "$PCAP_FILE" || echo "tcpdump exit/timeout"

  if [ -f "$PCAP_FILE" ] && [ $(stat -c%s "$PCAP_FILE") -ge 128 ]; then
    scp -i "$SSH_KEY" $SCP_OPTS "$PCAP_FILE" "${MALCOLM_USER}@${MALCOLM_HOST}:${MALCOLM_DEST_DIR}/" || echo "scp feilet"
  else
    rm -f "$PCAP_FILE" || true
  fi

  find "$OUTDIR" -type f -mtime +"$MAX_AGE_DAYS" -delete || true
done
