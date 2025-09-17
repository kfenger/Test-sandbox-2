#!/bin/bash
set -euo pipefail
cd /opt/malcolm/Malcolm || { echo "Malcolm repo ikke funnet"; exit 1; }

if [ -x ./scripts/start ]; then
  ./scripts/start
else
  docker compose up -d
fi

echo "Malcolm start-kommando kjørt."
