
#!/bin/bash
# Pezkuwi Validator One-Line Installer
# Usage: curl -sSf https://raw.githubusercontent.com/pezkuwichain/pezkuwi-validator-v1.0.0/main/scripts/linux/install-validator.sh | bas
set -e

echo "🚀 Pezkuwi Validator Installer v1.0.0"
echo "======================================"
echo ""

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Configuration
PEZKUWI_VERSION="v1.0.0-local-testnet-success"
GITHUB_REPO="pezkuwichain/pezkuwi-sdk"
INSTALL_DIR="$HOME/.pezkuwi"
CHAIN_SPEC_URL="https://raw.githubusercontent.com/${GITHUB_REPO}/main/pezkuwi-local-raw.json"

# Functions
print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

print_info() {
    echo -e "${YELLOW}ℹ${NC} $1"
}

check_requirements() {
    print_info "Checking system requirements..."
    
    if [[ "$OSTYPE" != "linux-gnu"* ]]; then
        print_error "This script only supports Linux"
        exit 1
    fi
    
    CPU_CORES=$(nproc)
    if [ "$CPU_CORES" -lt 2 ]; then
        print_error "Minimum 2 CPU cores required (found: $CPU_CORES)"
        exit 1
    fi
    
    TOTAL_RAM=$(free -g | awk '/^Mem:/{print $2}')
    if [ "$TOTAL_RAM" -lt 4 ]; then
        print_error "Minimum 4GB RAM required (found: ${TOTAL_RAM}GB)"
        exit 1
    fi
    
    print_success "System requirements met"
}

install_dependencies() {
    print_info "Installing dependencies..."
    
    if command -v apt-get &> /dev/null; then
        sudo apt-get update -qq
        sudo apt-get install -y curl wget tar
    elif command -v yum &> /dev/null; then
        sudo yum install -y curl wget tar
    else
        print_error "Unsupported package manager"
        exit 1
    fi
    
    print_success "Dependencies installed"
}

download_binaries() {
    print_info "Downloading Pezkuwi binaries..."
    
    mkdir -p "$INSTALL_DIR/bin"
    
    RELEASE_URL="https://github.com/${GITHUB_REPO}/releases/download/${PEZKUWI_VERSION}"
    
    wget -q --show-progress -O "$INSTALL_DIR/bin/pezkuwi" "${RELEASE_URL}/pezkuwi" || {
        print_error "Failed to download binaries"
        print_info "Please check if release exists: ${RELEASE_URL}"
        exit 1
    }
    
    chmod +x "$INSTALL_DIR/bin/pezkuwi"
    print_success "Binaries downloaded"
}

download_chain_spec() {
    print_info "Downloading chain specification..."
    
    mkdir -p "$INSTALL_DIR/config"
    wget -q -O "$INSTALL_DIR/config/chain-spec.json" "$CHAIN_SPEC_URL" || {
        print_error "Failed to download chain spec"
        exit 1
    }
    
    print_success "Chain spec downloaded"
}

generate_keys() {
    print_info "Generating validator keys..."
    
    mkdir -p "$INSTALL_DIR/keys"
    
    "$INSTALL_DIR/bin/pezkuwi" key generate-node-key \
        --base-path "$INSTALL_DIR/data" \
        --chain "$INSTALL_DIR/config/chain-spec.json" > "$INSTALL_DIR/keys/node-id.txt"
    
    NODE_ID=$(cat "$INSTALL_DIR/keys/node-id.txt")
    print_success "Keys generated"
    print_info "Your Node ID: $NODE_ID"
}

create_systemd_service() {
    print_info "Creating systemd service..."
    
    sudo tee /etc/systemd/system/pezkuwi-validator.service > /dev/null << SERVICE
[Unit]
Description=Pezkuwi Validator Node
After=network.target

[Service]
Type=simple
User=$USER
WorkingDirectory=$INSTALL_DIR
ExecStart=$INSTALL_DIR/bin/pezkuwi \\
    --chain $INSTALL_DIR/config/chain-spec.json \\
    --base-path $INSTALL_DIR/data \\
    --validator \\
    --name "Validator-\$(hostname)" \\
    --port 30333 \\
    --rpc-port 9944 \\
    --rpc-cors all \\
    --rpc-methods=unsafe
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
SERVICE
    
    sudo systemctl daemon-reload
    sudo systemctl enable pezkuwi-validator
    print_success "Systemd service created"
}

start_validator() {
    print_info "Starting validator..."
    
    sudo systemctl start pezkuwi-validator
    sleep 3
    
    if sudo systemctl is-active --quiet pezkuwi-validator; then
        print_success "Validator started successfully!"
    else
        print_error "Failed to start validator"
        print_info "Check logs: sudo journalctl -u pezkuwi-validator -f"
        exit 1
    fi
}

print_summary() {
    echo ""
    echo "======================================"
    echo "🎉 Installation Complete!"
    echo "======================================"
    echo ""
    echo "📍 Install Directory: $INSTALL_DIR"
    echo "🔑 Node ID: $(cat $INSTALL_DIR/keys/node-id.txt)"
    echo ""
    echo "📊 Useful Commands:"
    echo "  • Check status: sudo systemctl status pezkuwi-validator"
    echo "  • View logs:    sudo journalctl -u pezkuwi-validator -f"
    echo "  • Stop node:    sudo systemctl stop pezkuwi-validator"
    echo "  • Restart node: sudo systemctl restart pezkuwi-validator"
    echo ""
    echo "🌐 RPC Endpoint: http://localhost:9944"
    echo ""
}

main() {
    check_requirements
    install_dependencies
    download_binaries
    download_chain_spec
    generate_keys
    create_systemd_service
    start_validator
    print_summary
}

main
