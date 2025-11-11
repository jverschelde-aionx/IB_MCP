#!/bin/sh
# Always-verbose healthcheck using only /bin/sh and curl.
# Tries HTTP then HTTPS (with -k) on 127.0.0.1:<PORT> for the chosen endpoint.

PORT="${GATEWAY_PORT:-5055}"
PATH_SUFFIX="${GATEWAY_TEST_ENDPOINT:-/v1/api/servertime}"  # simple, no-login endpoint
SCHEMES="${GATEWAY_SCHEME:-http https}"                     # try both unless explicitly set

echo "=== GW healthcheck @ $(date 2>/dev/null || echo unknown-date) ==="
echo "PORT=$PORT  ENDPOINT=$PATH_SUFFIX  SCHEMES='$SCHEMES'"

ok=1
for SCHEME in $SCHEMES; do
  [ -z "$SCHEME" ] && continue
  URL="${SCHEME}://127.0.0.1:${PORT}${PATH_SUFFIX}"
  echo ""
  echo ">>> Probing: $URL"
  CURL_OPTS="-sS -m 5"
  [ "$SCHEME" = "https" ] && CURL_OPTS="$CURL_OPTS -k"

  # Save body and stderr separately; capture HTTP code
  rm -f /tmp/hc_body /tmp/hc_err
  STATUS="$(curl $CURL_OPTS -w '%{http_code}' -o /tmp/hc_body "$URL" 2>/tmp/hc_err || echo '')"

  echo "HTTP status: ${STATUS:-curl_failed}"
  if [ -s /tmp/hc_err ]; then
    echo "--- curl stderr ---"
    cat /tmp/hc_err
  fi
  if [ -s /tmp/hc_body ]; then
    echo "--- response body (printing all) ---"
    cat /tmp/hc_body
    echo
  else
    echo "(no response body)"
  fi

  case "$STATUS" in
    200|401|403)
      echo "✅ Reachable via $SCHEME"
      ok=0
      break
      ;;
    *)
      echo "❌ Not reachable via $SCHEME"
      ;;
  esac
done

exit $ok
