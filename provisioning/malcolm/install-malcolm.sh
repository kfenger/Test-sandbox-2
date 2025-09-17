#!/bin/bash
set -euo pipefail
# Kjør på malcolm-host (root)
WORKDIR=/opt/malcolm
mkdir -p "$WORKDIR"
cd "$WORKDIR"

apt update
apt install -y git docker.io docker-compose

if [ ! -d "$WORKDIR/Malcolm" ]; then
  git clone https://github.com/cisagov/Malcolm.git Malcolm
fi

mkdir -p /opt/malcolm/persist
chown -R root:root /opt/malcolm

echo "Install script ferdig."
