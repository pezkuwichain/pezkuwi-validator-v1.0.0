# Pezkuwi Validator Docker Image
FROM ubuntu:22.04

LABEL maintainer="pezkuwichain"
LABEL description="Pezkuwi blockchain validator node"
LABEL version="1.0.0"

# Install dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Create pezkuwi user
RUN useradd -m -u 1000 -U -s /bin/sh -d /pezkuwi pezkuwi

# Set working directory
WORKDIR /pezkuwi

# Download and extract binaries
ARG PEZKUWI_VERSION=v1.0.0-local-testnet-success
RUN curl -L "https://github.com/pezkuwichain/pezkuwi-sdk/releases/download/${PEZKUWI_VERSION}/pezkuwi-binaries-linux-x86_64.tar.gz" \
    | tar xz -C /usr/local/bin/ && \
    chmod +x /usr/local/bin/pezkuwi && \
    chmod +x /usr/local/bin/pezkuwi-prepare-worker && \
    chmod +x /usr/local/bin/pezkuwi-execute-worker

# Download chain spec
RUN curl -o /pezkuwi/chain-spec.json \
    https://raw.githubusercontent.com/pezkuwichain/pezkuwi-sdk/main/pezkuwi-local-raw.json

# Create data directory
RUN mkdir -p /pezkuwi/data && \
    chown -R pezkuwi:pezkuwi /pezkuwi

# Switch to pezkuwi user
USER pezkuwi

# Expose ports
EXPOSE 30333 9944 9615

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
    CMD curl -f http://localhost:9944 || exit 1

# Default command
ENTRYPOINT ["/usr/local/bin/pezkuwi"]
CMD ["--chain", "/pezkuwi/chain-spec.json", \
     "--base-path", "/pezkuwi/data", \
     "--validator", \
     "--port", "30333", \
     "--rpc-port", "9944", \
     "--rpc-cors", "all", \
     "--rpc-external", \
     "--prometheus-external"]
