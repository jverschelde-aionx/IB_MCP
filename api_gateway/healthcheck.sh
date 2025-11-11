#!/bin/sh
SCHEME="${GATEWAY_SCHEME:-http}"     # set to https if conf.yaml keeps TLS
PORT="${GATEWAY_PORT:-5055}"
PATH="${GATEWAY_TEST_ENDPOINT:-/v1/api/servertime}"
URL="${SCHEME}://127.0.0.1:${PORT}${PATH}"

[ "$SCHEME" = "https" ] && K="-k" || K=""
STATUS=$(curl -sS $K -o /tmp/api.json -w "%{http_code}" "$URL" || true)

case "$STATUS" in
  200|401|403) exit 0 ;;
  *) echo "Gateway not ready (HTTP ${STATUS:-curl_failed})"; exit 1 ;;
esac
