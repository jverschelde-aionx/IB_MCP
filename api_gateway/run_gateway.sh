#!/bin/sh
set -eu
# We are already in /app/gateway/clientportal.gw (WORKDIR)
CONF="${1:-root/conf.yaml}"

# Hard fail with a helpful message if the vendor files are missing
for p in bin/run.sh dist build/lib/runtime; do
  [ -e "$p" ] || { echo "FATAL: missing $p in $(pwd)"; ls -la; exit 127; }
done

# Start vendor script (it uses #!/bin/bash)
exec bash ./bin/run.sh "$CONF"
