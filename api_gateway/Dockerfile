FROM eclipse-temurin:21

WORKDIR /app
RUN apt-get update && apt-get install -y curl unzip && rm -rf /var/lib/apt/lists/*

# Download and unpack to /app/gateway/clientportal.gw
RUN mkdir -p /app/gateway && cd /app/gateway && \
    curl -fSL -o clientportal.gw.zip https://download2.interactivebrokers.com/portal/clientportal.gw.zip && \
    unzip -q clientportal.gw.zip && rm clientportal.gw.zip

# Point at the actual distribution root
WORKDIR /app/gateway/clientportal.gw

# Put your config where the gateway expects it
COPY conf.yaml root/conf.yaml

# Scripts
COPY run_gateway.sh /app/run_gateway.sh
COPY healthcheck.sh /usr/local/bin/healthcheck.sh
RUN chmod +x /app/run_gateway.sh /usr/local/bin/healthcheck.sh

EXPOSE 5055
ENTRYPOINT ["/app/run_gateway.sh", "/app/gateway/clientportal.gw/root/conf.yaml"]
