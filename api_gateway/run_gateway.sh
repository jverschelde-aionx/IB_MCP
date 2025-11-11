#!/bin/sh
set -e

CONF="${1:-/app/gateway/clientportal.gw/root/conf.yaml}"
GW_DIR="/app/gateway/clientportal.gw"

cd "$GW_DIR"

# Start the gateway in the background using the vendor script
./bin/run.sh "$CONF" &
GW_PID=$!

# Probe until healthy (your healthcheck script)
for i in $(seq 1 30); do
  if /usr/local/bin/healthcheck.sh; then
    echo "Gateway healthy"
    break
  fi
  echo "API Gateway not ready yet, waiting..."
  sleep 2
done

# Keep container tied to the Java process
wait $GW_PID
