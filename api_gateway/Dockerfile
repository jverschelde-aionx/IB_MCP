FROM eclipse-temurin:21

# bash is required by vendor run.sh; curl/unzip for download
RUN apt-get update && apt-get install -y bash curl unzip ca-certificates && rm -rf /var/lib/apt/lists/*

# Work under /app/gateway
WORKDIR /app/gateway

# Download, unzip to a staging dir, then copy the real distro root
RUN set -eux; \
    curl -fSL -o /tmp/gw.zip "https://download2.interactivebrokers.com/portal/clientportal.gw.zip"; \
    mkdir -p /app/gateway/_unz; \
    unzip -q /tmp/gw.zip -d /app/gateway/_unz; \
    rm -f /tmp/gw.zip; \
    # find the directory that actually contains bin/run.sh
    GW_ROOT=""; \
    for d in /app/gateway/_unz /app/gateway/_unz/*; do \
      if [ -x "$d/bin/run.sh" ]; then GW_ROOT="$d"; break; fi; \
    done; \
    if [ -z "$GW_ROOT" ]; then \
      echo "Could not locate gateway root after unzip (bin/run.sh missing)"; \
      find /app/gateway/_unz -maxdepth 3 -type d -print; \
      exit 1; \
    fi; \
    # copy the distribution contents into /app/gateway
    cp -a "$GW_ROOT/." /app/gateway/; \
    rm -rf /app/gateway/_unz; \
    # minimal sanity: vendor launcher exists now
    test -x /app/gateway/bin/run.sh

# Put your config where the gateway expects it (next to bin/dist/build/root)
COPY conf.yaml root/conf.yaml

# Copy and setup scripts
COPY healthcheck.sh /usr/local/bin/healthcheck.sh
RUN chmod +x /usr/local/bin/healthcheck.sh

COPY tickler.sh /app/gateway/tickler.sh
RUN chmod +x /app/gateway/tickler.sh

COPY run_gateway.sh /app/gateway/run_gateway.sh
RUN chmod +x /app/gateway/run_gateway.sh

EXPOSE 5055

# Use run_gateway.sh to start both gateway and tickler
ENTRYPOINT ["/app/gateway/run_gateway.sh", "root/conf.yaml"]
