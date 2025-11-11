FROM eclipse-temurin:21

# Tools the vendor script needs (bash) + unzip/curl
RUN apt-get update && apt-get install -y bash curl unzip ca-certificates && rm -rf /var/lib/apt/lists/*

# Download and unpack to /app/gateway/clientportal.gw
WORKDIR /app/gateway
RUN curl -fSL -o clientportal.gw.zip https://download2.interactivebrokers.com/portal/clientportal.gw.zip \
 && unzip -q clientportal.gw.zip \
 && rm clientportal.gw.zip \
 # Sanity checks: fail the build if vendor layout isn't present
 && test -x clientportal.gw/bin/run.sh \
 && test -d clientportal.gw/dist \
 && test -d clientportal.gw/build/lib/runtime

# Put your config where the gateway expects it
WORKDIR /app/gateway/clientportal.gw
COPY conf.yaml root/conf.yaml

# Wrapper entrypoint (starts vendor script) + healthcheck
COPY run_gateway.sh /usr/local/bin/run_gateway
COPY healthcheck.sh /usr/local/bin/healthcheck.sh
RUN chmod +x /usr/local/bin/run_gateway /usr/local/bin/healthcheck.sh

EXPOSE 5055

# Run from the vendor distribution root so relative paths work
ENTRYPOINT ["run_gateway", "root/conf.yaml"]
