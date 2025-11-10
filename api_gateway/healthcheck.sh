#!/bin/sh
BASE="${GATEWAY_INTERNAL_BASE_URL:-http://localhost}"
PORT="${GATEWAY_PORT:-5055}"
# Use a publicly reachable path; "/" will render login/redirect
PATH_TO_CHECK="${GATEWAY_TEST_ENDPOINT:-/}"

STATUS=$(curl -sk -o /dev/null -w "%{http_code}" "${BASE}:${PORT}${PATH_TO_CHECK}")

case "$STATUS" in
  200|301|302|401|403)
    echo "Gateway reachable (HTTP $STATUS)."
    exit 0
    ;;
  *)
    echo "Gateway not ready (HTTP $STATUS)."
    exit 1
    ;;
esac
