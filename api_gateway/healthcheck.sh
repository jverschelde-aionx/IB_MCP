#!/bin/sh
# Always-verbose healthcheck for IBKR gateway
set -eu

SCHEME="${GATEWAY_SCHEME:-http}"        # set to https if conf.yaml keeps TLS
PORT="${GATEWAY_PORT:-5055}"
PATH="${GATEWAY_TEST_ENDPOINT:-/v1/api/servertime}"
URL="${SCHEME}://127.0.0.1:${PORT}${PATH}"
[ "$SCHEME" = "https" ] && K="-k" || K=""

echo "[$(date -Is)] Checking $URL"
echo "Env: SCHEME=$SCHEME PORT=$PORT PATH=$PATH"

# show listening ports
echo "--- Listening ports ---"
(ss -lntp 2>/dev/null || netstat -plnt 2>/dev/null) | grep -E ":$PORT\s" || echo "No listener visible on :$PORT"

# make request
echo "--- Curl request ---"
STATUS=$(curl $K -sS -m 3 -w "%{http_code}" -D - -o /tmp/api.json "$URL" 2>&1 | tee /tmp/healthcheck.curl.log | awk 'END{print $NF}') || true

echo "--- HTTP status: ${STATUS:-curl_failed} ---"
echo "--- Body (first 300 bytes) ---"
head -c 300 /tmp/api.json 2>/dev/null && echo
echo "--- End body ---"

case "$STATUS" in
  200|401|403)
    echo "✅ Gateway reachable (HTTP $STATUS)"
    exit 0
    ;;
  *)
    echo "❌ Gateway not ready (HTTP ${STATUS:-curl_failed})"
    echo "--- Full curl output ---"
    cat /tmp/healthcheck.curl.log 2>/dev/null || true
    echo "--- End curl output ---"
    exit 1
    ;;
esac
