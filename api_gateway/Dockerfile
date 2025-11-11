FROM eclipse-temurin:21
WORKDIR /app

# Install curl+unzip before using them
RUN apt-get update && apt-get install -y curl unzip && rm -rf /var/lib/apt/lists/*

# Put the gateway under /app/gateway and FLATTEN the archive so we get bin/ and root/ directly
RUN mkdir -p /app/gateway && cd /app/gateway && \
    curl -fSL -o clientportal.gw.zip https://download2.interactivebrokers.com/portal/clientportal.gw.zip && \
    unzip -q clientportal.gw.zip && \
    if [ -d clientportal.gw ]; then mv clientportal.gw/* . && rmdir clientportal.gw; fi && \
    rm clientportal.gw.zip

# Copy your config to the expected location
COPY conf.yaml /app/gateway/root/conf.yaml

# Scripts
COPY run_gateway.sh /app/run_gateway.sh
COPY healthcheck.sh /usr/local/bin/healthcheck.sh
COPY tickler.sh /app/tickler.sh
RUN chmod +x /app/run_gateway.sh /usr/local/bin/healthcheck.sh /app/tickler.sh

EXPOSE 5055

# IMPORTANT: Drop CMD; let the entrypoint call bin/run.sh itself
ENTRYPOINT ["/app/run_gateway.sh", "/app/gateway/root/conf.yaml"]
