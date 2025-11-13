#!/bin/bash
set -eu

# We are already in /app/gateway (WORKDIR)
CONF="${1:-root/conf.yaml}"

# Validate gateway files exist
for p in bin/run.sh dist build/lib/runtime; do
  [ -e "$p" ] || { echo "FATAL: missing $p in $(pwd)"; ls -la; exit 127; }
done

echo "[run_gateway] Starting API Gateway in background..."
# Start the gateway in background
bash ./bin/run.sh "$CONF" &
GATEWAY_PID=$!

# Wait for the API Gateway to become healthy before starting the tickler
echo "[run_gateway] Waiting for API Gateway to become healthy..."
while ! /usr/local/bin/healthcheck.sh > /dev/null 2>&1; do
  echo "[run_gateway] API Gateway not ready yet, waiting..."
  sleep 2
done

echo "[run_gateway] API Gateway is healthy, starting tickler..."
/app/gateway/tickler.sh &
TICKLER_PID=$!

echo "[run_gateway] Both services started:"
echo "  - Gateway PID: $GATEWAY_PID"
echo "  - Tickler PID: $TICKLER_PID"

# Wait for both processes to keep container alive
wait
