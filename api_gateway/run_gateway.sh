#!/bin/sh
set -e

CONF="${1:-/app/gateway/root/conf.yaml}"
GW_DIR="/app/gateway"

if [ ! -x "$GW_DIR/bin/run.sh" ]; then
  echo "FATAL: $GW_DIR/bin/run.sh not found/executable" >&2
  ls -la "$GW_DIR" || true
  exit 1
fi

# Start the gateway in the background
"$GW_DIR/bin/run.sh" "$CONF" &
GW_PID=$!

# Probe until healthy
for i in $(seq 1 30); do
  if /usr/local/bin/healthcheck.sh; then
    echo "Gateway healthy"; break
  fi
  echo "API Gateway not ready yet, waiting..."
  sleep 2
done

wait $GW_PID
