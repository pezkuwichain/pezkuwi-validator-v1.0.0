#!/bin/bash

# ========================================
# Pezkuwi Validator Setup Script v3.0.0
# ========================================
# Multi-network validator setup for distributed deployment
# Usage: sudo ./setup.sh <network> <validator_number>
# Example: sudo ./setup.sh beta_testnet 8

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Function to print section headers
print_header() {
    echo -e "\n${BLUE}========================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}========================================${NC}\n"
}

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to check dependency and display status
check_dependency() {
    local cmd=$1
    local name=$2
    local version_cmd=$3

    if command_exists "$cmd"; then
        local version=$($version_cmd 2>&1 | head -n 1 || echo "unknown")
        echo -e "${GREEN}✓${NC} $name: ${GREEN}Installed${NC} ($version)"
        return 0
    else
        echo -e "${RED}✗${NC} $name: ${RED}Not installed${NC}"
        return 1
    fi
}

# Global variables for dependencies
missing_deps=()
RUST_MISSING=0
NODE_MISSING=0

# Parse and validate arguments
parse_arguments() {
    print_header "Pezkuwi Validator Setup v3.0.0"

    # Check if running with sudo
    if [ "$EUID" -ne 0 ]; then
        echo -e "${RED}Error: This script must be run with sudo${NC}"
        echo "Usage: sudo ./setup.sh <network> <validator_number>"
        exit 1
    fi

    # Check arguments
    if [ $# -lt 2 ]; then
        echo -e "${RED}Error: Missing arguments${NC}"
        echo ""
        echo "Usage: sudo ./setup.sh <network> <validator_number>"
        echo ""
        echo "Networks:"
        echo "  beta_testnet  - Beta testnet (8 validators)"
        echo "  staging       - Staging network (20 validators)"
        echo "  mainnet       - Production network (100 validators)"
        echo ""
        echo "Example: sudo ./setup.sh beta_testnet 8"
        exit 1
    fi

    NETWORK=$1
    VALIDATOR_NUM=$2

    # Validate network
    case "$NETWORK" in
        beta_testnet)
            MAX_VALIDATORS=8
            CHAIN_SPEC="pezkuwichain-beta-testnet"
            ;;
        staging)
            MAX_VALIDATORS=20
            CHAIN_SPEC="pezkuwichain-staging"
            ;;
        mainnet)
            MAX_VALIDATORS=100
            CHAIN_SPEC="pezkuwichain-mainnet"
            ;;
        *)
            echo -e "${RED}Error: Invalid network '$NETWORK'${NC}"
            echo "Valid networks: beta_testnet, staging, mainnet"
            exit 1
            ;;
    esac

    # Validate validator number
    if ! [[ "$VALIDATOR_NUM" =~ ^[0-9]+$ ]]; then
        echo -e "${RED}Error: Validator number must be a positive integer${NC}"
        exit 1
    fi

    if [ "$VALIDATOR_NUM" -lt 1 ] || [ "$VALIDATOR_NUM" -gt "$MAX_VALIDATORS" ]; then
        echo -e "${RED}Error: Validator number must be between 1 and $MAX_VALIDATORS for $NETWORK${NC}"
        exit 1
    fi

    # Detect actual user (not root)
    ACTUAL_USER=${SUDO_USER:-$USER}
    ACTUAL_HOME=$(eval echo ~$ACTUAL_USER)

    # Set paths
    NETWORK_DIR="$SCRIPT_DIR/$NETWORK"
    VALIDATOR_DIR="$NETWORK_DIR/validators/validator$VALIDATOR_NUM"
    SDK_DIR="$ACTUAL_HOME/pezkuwi-sdk"
    FRONTEND_DIR="$ACTUAL_HOME/DKSweb"

    echo -e "${GREEN}Network:${NC} $NETWORK"
    echo -e "${GREEN}Validator:${NC} $VALIDATOR_NUM / $MAX_VALIDATORS"
    echo -e "${GREEN}User:${NC} $ACTUAL_USER"
    echo -e "${GREEN}Home:${NC} $ACTUAL_HOME"
}

# Check system dependencies
check_dependencies() {
    print_header "Checking System Dependencies"

    missing_deps=()

    # Essential build tools
    if ! check_dependency "git" "Git" "git --version"; then
        missing_deps+=("git")
    fi

    if ! check_dependency "curl" "Curl" "curl --version"; then
        missing_deps+=("curl")
    fi

    if ! check_dependency "wget" "Wget" "wget --version"; then
        missing_deps+=("wget")
    fi

    # Build essentials
    if ! check_dependency "gcc" "GCC" "gcc --version"; then
        missing_deps+=("build-essential")
    fi

    if ! check_dependency "make" "Make" "make --version"; then
        missing_deps+=("build-essential")
    fi

    # Check pkg-config
    if ! check_dependency "pkg-config" "pkg-config" "pkg-config --version"; then
        missing_deps+=("pkg-config")
    fi

    # Check libssl-dev
    if ! dpkg -l | grep -q libssl-dev; then
        echo -e "${RED}✗${NC} libssl-dev: ${RED}Not installed${NC}"
        missing_deps+=("libssl-dev")
    else
        echo -e "${GREEN}✓${NC} libssl-dev: ${GREEN}Installed${NC}"
    fi

    # Check clang
    if ! check_dependency "clang" "Clang" "clang --version"; then
        missing_deps+=("clang")
    fi

    # Check Rust
    if ! su - $ACTUAL_USER -c 'command -v rustc' >/dev/null 2>&1; then
        echo -e "${RED}✗${NC} Rust: ${RED}Not installed${NC}"
        RUST_MISSING=1
    else
        local rust_version=$(su - $ACTUAL_USER -c 'rustc --version' 2>&1 | head -n 1)
        echo -e "${GREEN}✓${NC} Rust: ${GREEN}Installed${NC} ($rust_version)"
        RUST_MISSING=0
    fi

    # Check Cargo
    if ! su - $ACTUAL_USER -c 'command -v cargo' >/dev/null 2>&1; then
        RUST_MISSING=1
    fi

    # Check Node.js
    if ! check_dependency "node" "Node.js" "node --version"; then
        NODE_MISSING=1
    else
        NODE_MISSING=0
    fi

    # Check npm
    if ! check_dependency "npm" "npm" "npm --version"; then
        NODE_MISSING=1
    fi

    # Check systemd
    if ! check_dependency "systemctl" "systemd" "systemctl --version"; then
        echo -e "${YELLOW}Warning: systemd not found. Service management may not work.${NC}"
    fi

    # Check nginx
    if ! check_dependency "nginx" "Nginx" "nginx -v"; then
        missing_deps+=("nginx")
    fi
}

# Install missing dependencies
install_dependencies() {
    print_header "Installing Missing Dependencies"

    echo "Updating package list..."
    apt-get update

    # Install system packages
    if [ ${#missing_deps[@]} -gt 0 ]; then
        echo -e "\n${YELLOW}Installing system packages:${NC} ${missing_deps[*]}"
        apt-get install -y "${missing_deps[@]}"
        echo -e "${GREEN}✓ System packages installed${NC}"
    fi

    # Install Rust if missing
    if [ $RUST_MISSING -eq 1 ]; then
        echo -e "\n${YELLOW}Installing Rust for user: $ACTUAL_USER${NC}"
        echo "This may take a few minutes. Please wait..."

        # Install Rust as the actual user
        su - $ACTUAL_USER -c 'curl --proto "=https" --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --verbose'

        # Configure Rust toolchain
        echo -e "\n${YELLOW}Configuring Rust toolchain...${NC}"
        su - $ACTUAL_USER -c 'source $HOME/.cargo/env && rustup default stable'
        su - $ACTUAL_USER -c 'source $HOME/.cargo/env && rustup update'

        echo -e "\n${YELLOW}Adding WebAssembly target...${NC}"
        su - $ACTUAL_USER -c 'source $HOME/.cargo/env && rustup target add wasm32-unknown-unknown'

        echo -e "${GREEN}✓ Rust installed successfully for $ACTUAL_USER${NC}"
    else
        # Ensure wasm target is installed
        echo -e "\n${YELLOW}Ensuring wasm32-unknown-unknown target...${NC}"
        su - $ACTUAL_USER -c 'source $HOME/.cargo/env && rustup target add wasm32-unknown-unknown 2>/dev/null' || true
        echo -e "${GREEN}✓ WebAssembly target verified${NC}"
    fi

    # Install Node.js if missing
    if [ $NODE_MISSING -eq 1 ]; then
        echo -e "\n${YELLOW}Installing Node.js...${NC}"
        curl -fsSL https://deb.nodesource.com/setup_20.x | bash -
        apt-get install -y nodejs
        echo -e "${GREEN}✓ Node.js installed${NC}"
    fi

    echo -e "\n${GREEN}✓ All dependencies installed!${NC}"
}

# Clone and build Pezkuwi SDK
setup_sdk() {
    print_header "Setting up Pezkuwi SDK"

    if [ -d "$SDK_DIR" ]; then
        echo -e "${YELLOW}SDK directory already exists at $SDK_DIR${NC}"
        echo -e "${YELLOW}Updating from GitHub...${NC}"
        su - $ACTUAL_USER -c "cd $SDK_DIR && git fetch origin && git pull origin main"
    else
        echo "Cloning Pezkuwi SDK from GitHub..."
        echo "This may take several minutes for initial clone..."
        su - $ACTUAL_USER -c "cd $ACTUAL_HOME && git clone --depth 1 https://github.com/pezkuwichain/pezkuwi-sdk.git"
    fi

    echo -e "\n${YELLOW}Building Pezkuwi SDK (Release mode)...${NC}"
    echo "This will take 15-30 minutes. Please be patient..."
    echo ""

    # Build as actual user with proper environment
    su - $ACTUAL_USER -c "cd $SDK_DIR && source \$HOME/.cargo/env && cargo build --release"

    echo -e "\n${GREEN}✓ Pezkuwi SDK built successfully${NC}"
    echo "Binary location: $SDK_DIR/target/release/pezkuwi-node"
}

# Clone and build DKSweb frontend
setup_frontend() {
    print_header "Setting up DKSweb Frontend"

    if [ -d "$FRONTEND_DIR" ]; then
        echo -e "${YELLOW}Frontend directory already exists at $FRONTEND_DIR${NC}"
        echo -e "${YELLOW}Updating from GitHub...${NC}"
        su - $ACTUAL_USER -c "cd $FRONTEND_DIR && git fetch origin && git pull origin main"
    else
        echo "Cloning DKSweb from GitHub..."
        su - $ACTUAL_USER -c "cd $ACTUAL_HOME && git clone --depth 1 https://github.com/pezkuwichain/DKSweb.git"
    fi

    echo -e "\n${YELLOW}Installing frontend dependencies...${NC}"
    su - $ACTUAL_USER -c "cd $FRONTEND_DIR && npm install"

    echo -e "\n${YELLOW}Building frontend...${NC}"
    su - $ACTUAL_USER -c "cd $FRONTEND_DIR && npm run build"

    echo -e "\n${GREEN}✓ DKSweb frontend built successfully${NC}"
    echo "Frontend build: $FRONTEND_DIR/dist"
}

# Get bootnode information for validators > 1
get_bootnode_info() {
    if [ "$VALIDATOR_NUM" -eq 1 ]; then
        echo -e "${GREEN}This is validator 1 (bootnode)${NC}"
        BOOTNODE_ARG=""
        return
    fi

    print_header "Bootnode Configuration"

    echo -e "${YELLOW}This validator needs to connect to validator $((VALIDATOR_NUM - 1))${NC}"
    echo ""
    echo "Please obtain the bootnode multiaddr from validator $((VALIDATOR_NUM - 1))"
    echo "The multiaddr format looks like:"
    echo "/ip4/192.168.1.100/tcp/30333/p2p/12D3KooWAbCdEf..."
    echo ""

    read -p "Enter bootnode multiaddr (or press Enter to skip): " BOOTNODE_ADDR

    if [ -n "$BOOTNODE_ADDR" ]; then
        BOOTNODE_ARG="--bootnodes $BOOTNODE_ADDR"
        echo -e "${GREEN}✓ Bootnode configured${NC}"
    else
        echo -e "${YELLOW}Warning: No bootnode specified. Node will run in isolation.${NC}"
        BOOTNODE_ARG=""
    fi
}

# Configure validator settings
configure_validator() {
    print_header "Configuring Validator $VALIDATOR_NUM"

    # Calculate ports
    P2P_PORT=$((30333 + ($VALIDATOR_NUM - 1)))
    RPC_PORT=$((9944 + ($VALIDATOR_NUM - 1)))
    WS_PORT=$((9944 + ($VALIDATOR_NUM - 1)))
    PROMETHEUS_PORT=$((9615 + ($VALIDATOR_NUM - 1)))

    echo "Validator $VALIDATOR_NUM ports:"
    echo "  P2P Port: $P2P_PORT"
    echo "  RPC Port: $RPC_PORT"
    echo "  WebSocket Port: $WS_PORT"
    echo "  Prometheus Port: $PROMETHEUS_PORT"

    # Create validator directories
    mkdir -p "$VALIDATOR_DIR"/{config,data,keys,logs}

    # Create validator config file
    CONFIG_FILE="$VALIDATOR_DIR/config/validator.conf"

    cat > "$CONFIG_FILE" << EOF
# Validator $VALIDATOR_NUM Configuration
# Network: $NETWORK
# Generated: $(date)

VALIDATOR_NUM=$VALIDATOR_NUM
VALIDATOR_NAME="validator-$VALIDATOR_NUM"
NETWORK=$NETWORK
CHAIN_SPEC=$CHAIN_SPEC
P2P_PORT=$P2P_PORT
RPC_PORT=$RPC_PORT
WS_PORT=$WS_PORT
PROMETHEUS_PORT=$PROMETHEUS_PORT
DATA_DIR=$VALIDATOR_DIR/data
KEYS_DIR=$VALIDATOR_DIR/keys
LOGS_DIR=$VALIDATOR_DIR/logs
SDK_PATH=$SDK_DIR
FRONTEND_PATH=$FRONTEND_DIR
ACTUAL_USER=$ACTUAL_USER
EOF

    chown -R $ACTUAL_USER:$ACTUAL_USER "$VALIDATOR_DIR"
    echo -e "${GREEN}✓ Configuration file created${NC}"

    # Check for validator keys
    KEYS_SCRIPT="$VALIDATOR_DIR/config/keys.sh"
    if [ -f "$KEYS_SCRIPT" ]; then
        echo -e "\n${GREEN}✓ Validator keys found${NC}"
        echo "Keys file: $KEYS_SCRIPT"
    else
        echo -e "\n${YELLOW}Warning: No keys.sh found${NC}"
        echo "You will need to add validator keys to: $KEYS_SCRIPT"
    fi
}

# Setup systemd service
setup_service() {
    print_header "Setting up Systemd Service"

    SERVICE_NAME="pezkuwi-validator-$NETWORK-$VALIDATOR_NUM"
    SERVICE_FILE="/etc/systemd/system/$SERVICE_NAME.service"

    # Build node arguments
    NODE_ARGS="--base-path $VALIDATOR_DIR/data"
    NODE_ARGS="$NODE_ARGS --chain $CHAIN_SPEC"
    NODE_ARGS="$NODE_ARGS --validator"
    NODE_ARGS="$NODE_ARGS --name validator-$VALIDATOR_NUM"
    NODE_ARGS="$NODE_ARGS --port $P2P_PORT"
    NODE_ARGS="$NODE_ARGS --rpc-port $RPC_PORT"
    NODE_ARGS="$NODE_ARGS --prometheus-port $PROMETHEUS_PORT"
    NODE_ARGS="$NODE_ARGS --rpc-cors all"
    NODE_ARGS="$NODE_ARGS --rpc-external"

    if [ -n "$BOOTNODE_ARG" ]; then
        NODE_ARGS="$NODE_ARGS $BOOTNODE_ARG"
    fi

    tee "$SERVICE_FILE" > /dev/null << EOF
[Unit]
Description=Pezkuwi Validator $VALIDATOR_NUM ($NETWORK)
After=network.target

[Service]
Type=simple
User=$ACTUAL_USER
WorkingDirectory=$VALIDATOR_DIR
EnvironmentFile=$VALIDATOR_DIR/config/validator.conf
ExecStart=$SDK_DIR/target/release/pezkuwi-node $NODE_ARGS
Restart=always
RestartSec=10
StandardOutput=append:$VALIDATOR_DIR/logs/validator.log
StandardError=append:$VALIDATOR_DIR/logs/validator-error.log

[Install]
WantedBy=multi-user.target
EOF

    # Reload systemd
    systemctl daemon-reload

    echo -e "${GREEN}✓ Systemd service created${NC}"
    echo "Service name: $SERVICE_NAME"
}

# Setup nginx for frontend
setup_nginx() {
    print_header "Setting up Nginx"

    NGINX_CONF="/etc/nginx/sites-available/pezkuwi-frontend"

    if [ -f "$NGINX_CONF" ]; then
        echo -e "${YELLOW}Nginx already configured${NC}"
        echo "Skipping nginx setup..."
        return
    fi

    tee "$NGINX_CONF" > /dev/null << EOF
server {
    listen 80;
    listen [::]:80;
    server_name _;

    root $FRONTEND_DIR/dist;
    index index.html;

    location / {
        try_files \$uri \$uri/ /index.html;
    }

    location /api {
        proxy_pass http://localhost:$RPC_PORT;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host \$host;
    }
}
EOF

    # Enable site
    ln -sf "$NGINX_CONF" /etc/nginx/sites-enabled/

    # Remove default site if exists
    rm -f /etc/nginx/sites-enabled/default

    # Test nginx configuration
    nginx -t

    # Restart nginx
    systemctl restart nginx
    systemctl enable nginx

    echo -e "${GREEN}✓ Nginx configured and restarted${NC}"
}

# Insert validator keys
insert_keys() {
    KEYS_SCRIPT="$VALIDATOR_DIR/config/keys.sh"

    if [ ! -f "$KEYS_SCRIPT" ]; then
        echo -e "\n${YELLOW}Skipping key insertion - no keys.sh file found${NC}"
        return
    fi

    print_header "Inserting Validator Keys"

    # Source the keys
    source "$KEYS_SCRIPT"

    echo "Waiting for node to start..."
    sleep 5

    # Insert each key type
    echo "Inserting BABE keys..."
    curl -s -H "Content-Type: application/json" \
      -d "{\"id\":1,\"jsonrpc\":\"2.0\",\"method\":\"author_insertKey\",\"params\":[\"babe\",\"$BABE_SEED\",\"$BABE_PUBLIC_KEY\"]}" \
      http://127.0.0.1:$RPC_PORT > /dev/null

    echo "Inserting GRANDPA keys..."
    curl -s -H "Content-Type: application/json" \
      -d "{\"id\":1,\"jsonrpc\":\"2.0\",\"method\":\"author_insertKey\",\"params\":[\"gran\",\"$GRAN_SEED\",\"$GRAN_PUBLIC_KEY\"]}" \
      http://127.0.0.1:$RPC_PORT > /dev/null

    echo "Inserting PARA keys..."
    curl -s -H "Content-Type: application/json" \
      -d "{\"id\":1,\"jsonrpc\":\"2.0\",\"method\":\"author_insertKey\",\"params\":[\"para\",\"$PARA_SEED\",\"$PARA_PUBLIC_KEY\"]}" \
      http://127.0.0.1:$RPC_PORT > /dev/null

    echo "Inserting ASGN keys..."
    curl -s -H "Content-Type: application/json" \
      -d "{\"id\":1,\"jsonrpc\":\"2.0\",\"method\":\"author_insertKey\",\"params\":[\"asgn\",\"$ASGN_SEED\",\"$ASGN_PUBLIC_KEY\"]}" \
      http://127.0.0.1:$RPC_PORT > /dev/null

    echo "Inserting AUDI keys..."
    curl -s -H "Content-Type: application/json" \
      -d "{\"id\":1,\"jsonrpc\":\"2.0\",\"method\":\"author_insertKey\",\"params\":[\"audi\",\"$AUDI_SEED\",\"$AUDI_PUBLIC_KEY\"]}" \
      http://127.0.0.1:$RPC_PORT > /dev/null

    echo "Inserting BEEF keys..."
    curl -s -H "Content-Type: application/json" \
      -d "{\"id\":1,\"jsonrpc\":\"2.0\",\"method\":\"author_insertKey\",\"params\":[\"beef\",\"$BEEF_SEED\",\"$BEEF_PUBLIC_KEY\"]}" \
      http://127.0.0.1:$RPC_PORT > /dev/null

    echo -e "${GREEN}✓ All keys inserted${NC}"
}

# Get peer ID for bootnode
get_peer_id() {
    if [ "$VALIDATOR_NUM" -ne 1 ]; then
        return
    fi

    print_header "Bootnode Information"

    echo "Waiting for node to generate peer ID..."
    sleep 10

    echo -e "\n${GREEN}This is validator 1 (bootnode)${NC}"
    echo "Other validators will need this information to connect."
    echo ""
    echo "To get your peer ID, check the validator logs:"
    echo -e "${BLUE}tail -f $VALIDATOR_DIR/logs/validator.log${NC}"
    echo ""
    echo "Look for a line containing: 'Local node identity is: <PEER_ID>'"
    echo ""
    echo "Your bootnode multiaddr will be:"
    echo "/ip4/<YOUR_IP>/tcp/$P2P_PORT/p2p/<PEER_ID>"
}

# Final instructions
show_final_instructions() {
    print_header "Setup Complete!"

    echo -e "${GREEN}Validator $VALIDATOR_NUM is ready!${NC}\n"
    echo "Next steps:"
    echo ""
    echo "1. Start the validator:"
    echo -e "   ${BLUE}sudo systemctl start pezkuwi-validator-$NETWORK-$VALIDATOR_NUM${NC}"
    echo ""
    echo "2. Check validator status:"
    echo -e "   ${BLUE}sudo systemctl status pezkuwi-validator-$NETWORK-$VALIDATOR_NUM${NC}"
    echo ""
    echo "3. View logs:"
    echo -e "   ${BLUE}tail -f $VALIDATOR_DIR/logs/validator.log${NC}"
    echo ""
    echo "4. Enable auto-start on boot:"
    echo -e "   ${BLUE}sudo systemctl enable pezkuwi-validator-$NETWORK-$VALIDATOR_NUM${NC}"
    echo ""

    if [ "$VALIDATOR_NUM" -eq 1 ]; then
        echo "5. Get bootnode peer ID:"
        echo -e "   ${BLUE}After starting, check logs for 'Local node identity'${NC}"
        echo -e "   ${BLUE}Share this with other validators${NC}"
        echo ""
    fi

    echo "6. Access frontend:"
    echo -e "   ${BLUE}http://localhost${NC} (local)"
    echo -e "   ${BLUE}http://YOUR_SERVER_IP${NC} (network)"
    echo ""

    if [ ! -f "$VALIDATOR_DIR/config/keys.sh" ]; then
        echo -e "${YELLOW}IMPORTANT: Add validator keys to:${NC}"
        echo -e "${YELLOW}$VALIDATOR_DIR/config/keys.sh${NC}"
        echo ""
    fi

    echo -e "${GREEN}Installation completed successfully!${NC}"
}

# Main function
main() {
    # Parse and validate arguments
    parse_arguments "$@"

    # Check dependencies
    check_dependencies || true

    # Install missing dependencies
    if [ ${#missing_deps[@]} -gt 0 ] || [ $RUST_MISSING -eq 1 ] || [ $NODE_MISSING -eq 1 ]; then
        echo -e "\n${YELLOW}Installing missing dependencies...${NC}"
        install_dependencies
    else
        echo -e "\n${GREEN}✓ All dependencies already installed${NC}"
    fi

    # Setup SDK
    setup_sdk

    # Setup frontend
    setup_frontend

    # Get bootnode info (for validators > 1)
    get_bootnode_info

    # Configure validator
    configure_validator

    # Setup systemd service
    setup_service

    # Setup nginx
    setup_nginx

    # Show final instructions
    show_final_instructions

    echo -e "\n${BLUE}========================================${NC}"
    echo -e "${BLUE}Setup script completed${NC}"
    echo -e "${BLUE}========================================${NC}\n"
}

# Run main function
main "$@"
