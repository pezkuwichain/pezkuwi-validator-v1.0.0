#!/bin/bash

# ========================================
# Pezkuwi Validator Setup Script v2.0.0
# ========================================
# This script automates the entire validator setup process
# Usage: ./setup.sh [validator_number]

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SHARED_DIR="$SCRIPT_DIR/shared"
VALIDATORS_DIR="$SCRIPT_DIR/validators"

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

# Get validator number from argument or prompt
get_validator_number() {
    if [ -n "$1" ]; then
        VALIDATOR_NUM=$1
    else
        read -p "Enter validator number (1-10): " VALIDATOR_NUM
    fi

    # Validate validator number
    if ! [[ "$VALIDATOR_NUM" =~ ^[1-9]$|^10$ ]]; then
        echo -e "${RED}Error: Validator number must be between 1 and 10${NC}"
        exit 1
    fi

    VALIDATOR_DIR="$VALIDATORS_DIR/validator$VALIDATOR_NUM"
    echo -e "${GREEN}Setting up Validator $VALIDATOR_NUM${NC}"
}

# Global variables for dependencies
missing_deps=()
RUST_MISSING=0
NODE_MISSING=0

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
    if ! check_dependency "rustc" "Rust" "rustc --version"; then
        RUST_MISSING=1
    else
        RUST_MISSING=0
    fi

    # Check Cargo
    if ! check_dependency "cargo" "Cargo" "cargo --version"; then
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

    # Check systemd (should be available on Ubuntu)
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
    sudo apt-get update

    # Install system packages
    if [ ${#missing_deps[@]} -gt 0 ]; then
        echo -e "\n${YELLOW}Installing system packages:${NC} ${missing_deps[*]}"
        sudo apt-get install -y "${missing_deps[@]}"
        echo -e "${GREEN}✓ System packages installed${NC}"
    fi

    # Install Rust if missing
    if [ $RUST_MISSING -eq 1 ]; then
        echo -e "\n${YELLOW}Installing Rust...${NC}"
        echo "This may take a few minutes. Please wait..."
        curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --verbose

        # Source cargo env
        if [ -f "$HOME/.cargo/env" ]; then
            source "$HOME/.cargo/env"
        fi

        echo -e "\n${YELLOW}Configuring Rust toolchain...${NC}"
        rustup default stable
        rustup update

        echo -e "\n${YELLOW}Adding WebAssembly target...${NC}"
        rustup target add wasm32-unknown-unknown

        echo -e "${GREEN}✓ Rust installed successfully${NC}"
    else
        # Ensure wasm target is installed
        echo -e "\n${YELLOW}Ensuring wasm32-unknown-unknown target...${NC}"
        rustup target add wasm32-unknown-unknown 2>/dev/null || true
    fi

    # Install Node.js if missing
    if [ $NODE_MISSING -eq 1 ]; then
        echo -e "\n${YELLOW}Installing Node.js...${NC}"
        curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
        sudo apt-get install -y nodejs
        echo -e "${GREEN}✓ Node.js installed${NC}"
    fi

    echo -e "\n${GREEN}✓ All dependencies installed!${NC}"
}

# Clone and build pezkuwi-sdk
setup_sdk() {
    print_header "Setting up pezkuwi-sdk"

    mkdir -p "$SHARED_DIR"
    cd "$SHARED_DIR"

    if [ -d "pezkuwi-sdk" ]; then
        echo -e "${YELLOW}pezkuwi-sdk already exists. Updating...${NC}"
        cd pezkuwi-sdk
        git fetch origin
        git pull origin main || git pull origin master
    else
        echo "Cloning pezkuwi-sdk from GitHub..."
        git clone --depth 1 https://github.com/pezkuwichain/pezkuwi-sdk.git
        cd pezkuwi-sdk
    fi

    echo -e "\n${YELLOW}Building pezkuwi-sdk (Release mode)...${NC}"
    echo "This may take 15-30 minutes..."

    # Build the node in release mode
    cargo build --release

    echo -e "${GREEN}✓ pezkuwi-sdk built successfully${NC}"
}

# Clone and build DKSweb frontend
setup_frontend() {
    print_header "Setting up DKSweb Frontend"

    cd "$SHARED_DIR"

    if [ -d "DKSweb" ]; then
        echo -e "${YELLOW}DKSweb already exists. Updating...${NC}"
        cd DKSweb
        git fetch origin
        git pull origin main || git pull origin master
    else
        echo "Cloning DKSweb from GitHub..."
        # TODO: Replace with actual repository URL
        git clone --depth 1 https://github.com/pezkuwichain/DKSweb.git
        cd DKSweb
    fi

    echo -e "\n${YELLOW}Installing frontend dependencies...${NC}"
    npm install

    echo -e "\n${YELLOW}Building frontend...${NC}"
    npm run build

    echo -e "${GREEN}✓ DKSweb frontend built successfully${NC}"
}

# Configure validator-specific settings
configure_validator() {
    print_header "Configuring Validator $VALIDATOR_NUM"

    # Calculate ports (each validator gets 10 ports starting from base)
    BASE_PORT=$((30333 + ($VALIDATOR_NUM - 1) * 10))
    P2P_PORT=$BASE_PORT
    RPC_PORT=$((9944 + ($VALIDATOR_NUM - 1)))
    WS_PORT=$((9945 + ($VALIDATOR_NUM - 1)))
    PROMETHEUS_PORT=$((9615 + ($VALIDATOR_NUM - 1)))

    echo "Validator $VALIDATOR_NUM ports:"
    echo "  P2P Port: $P2P_PORT"
    echo "  RPC Port: $RPC_PORT"
    echo "  WebSocket Port: $WS_PORT"
    echo "  Prometheus Port: $PROMETHEUS_PORT"

    # Create validator config file
    CONFIG_FILE="$VALIDATOR_DIR/config/validator.conf"
    mkdir -p "$(dirname "$CONFIG_FILE")"

    cat > "$CONFIG_FILE" << EOF
# Validator $VALIDATOR_NUM Configuration
VALIDATOR_NUM=$VALIDATOR_NUM
VALIDATOR_NAME="validator-$VALIDATOR_NUM"
P2P_PORT=$P2P_PORT
RPC_PORT=$RPC_PORT
WS_PORT=$WS_PORT
PROMETHEUS_PORT=$PROMETHEUS_PORT
DATA_DIR=$VALIDATOR_DIR/data
KEYS_DIR=$VALIDATOR_DIR/keys
LOGS_DIR=$VALIDATOR_DIR/logs
SDK_PATH=$SHARED_DIR/pezkuwi-sdk
FRONTEND_PATH=$SHARED_DIR/DKSweb
EOF

    echo -e "${GREEN}✓ Configuration file created${NC}"

    # Source the validator keys script if it exists
    KEYS_SCRIPT="$VALIDATOR_DIR/config/keys.sh"
    if [ -f "$KEYS_SCRIPT" ]; then
        echo -e "\n${YELLOW}Loading validator keys...${NC}"
        source "$KEYS_SCRIPT"
        echo -e "${GREEN}✓ Validator keys loaded${NC}"
    else
        echo -e "\n${YELLOW}Warning: No keys.sh found for validator $VALIDATOR_NUM${NC}"
        echo "Please create $KEYS_SCRIPT with validator keys"
    fi
}

# Setup systemd service
setup_service() {
    print_header "Setting up Systemd Service"

    SERVICE_FILE="/etc/systemd/system/pezkuwi-validator-$VALIDATOR_NUM.service"

    sudo tee "$SERVICE_FILE" > /dev/null << EOF
[Unit]
Description=Pezkuwi Validator $VALIDATOR_NUM
After=network.target

[Service]
Type=simple
User=$USER
WorkingDirectory=$VALIDATOR_DIR
EnvironmentFile=$VALIDATOR_DIR/config/validator.conf
ExecStart=$SHARED_DIR/pezkuwi-sdk/target/release/pezkuwi-node \\
    --base-path $VALIDATOR_DIR/data \\
    --chain local \\
    --validator \\
    --name validator-$VALIDATOR_NUM \\
    --port $P2P_PORT \\
    --rpc-port $RPC_PORT \\
    --ws-port $WS_PORT \\
    --prometheus-port $PROMETHEUS_PORT \\
    --rpc-cors all \\
    --ws-external \\
    --rpc-external
Restart=always
RestartSec=10
StandardOutput=append:$VALIDATOR_DIR/logs/validator.log
StandardError=append:$VALIDATOR_DIR/logs/validator-error.log

[Install]
WantedBy=multi-user.target
EOF

    # Reload systemd
    sudo systemctl daemon-reload

    echo -e "${GREEN}✓ Systemd service created${NC}"
    echo "Service name: pezkuwi-validator-$VALIDATOR_NUM"
}

# Setup nginx for frontend
setup_nginx() {
    print_header "Setting up Nginx"

    NGINX_CONF="/etc/nginx/sites-available/pezkuwi-frontend"

    if [ ! -f "$NGINX_CONF" ]; then
        sudo tee "$NGINX_CONF" > /dev/null << 'EOF'
server {
    listen 80;
    listen [::]:80;
    server_name _;

    root /home/$USER/pezkuwi-validator-v2.0.0/shared/DKSweb/dist;
    index index.html;

    location / {
        try_files $uri $uri/ /index.html;
    }

    location /api {
        proxy_pass http://localhost:9944;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host $host;
    }
}
EOF

        # Replace $USER with actual user
        sudo sed -i "s/\$USER/$USER/g" "$NGINX_CONF"

        # Enable site
        sudo ln -sf "$NGINX_CONF" /etc/nginx/sites-enabled/

        # Remove default site if exists
        sudo rm -f /etc/nginx/sites-enabled/default

        # Test nginx configuration
        sudo nginx -t

        # Restart nginx
        sudo systemctl restart nginx
        sudo systemctl enable nginx

        echo -e "${GREEN}✓ Nginx configured and restarted${NC}"
    else
        echo -e "${YELLOW}Nginx already configured${NC}"
    fi
}

# Setup automatic updates
setup_auto_update() {
    print_header "Setting up Automatic Updates"

    # Create update script
    UPDATE_SCRIPT="$SCRIPT_DIR/scripts/update.sh"
    mkdir -p "$SCRIPT_DIR/scripts"

    cat > "$UPDATE_SCRIPT" << 'EOF'
#!/bin/bash
# Automatic update script for Pezkuwi validator

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SHARED_DIR="$SCRIPT_DIR/../shared"

echo "Checking for updates..."

# Update SDK
cd "$SHARED_DIR/pezkuwi-sdk"
git fetch origin
if [ $(git rev-parse HEAD) != $(git rev-parse @{u}) ]; then
    echo "SDK updates found. Rebuilding..."
    git pull
    cargo build --release
    echo "Restarting validators..."
    sudo systemctl restart pezkuwi-validator-*.service
fi

# Update Frontend
cd "$SHARED_DIR/DKSweb"
git fetch origin
if [ $(git rev-parse HEAD) != $(git rev-parse @{u}) ]; then
    echo "Frontend updates found. Rebuilding..."
    git pull
    npm install
    npm run build
    echo "Frontend updated"
fi

echo "Update check complete"
EOF

    chmod +x "$UPDATE_SCRIPT"

    # Setup cron job for automatic updates (daily at 2 AM)
    CRON_JOB="0 2 * * * $UPDATE_SCRIPT >> $SCRIPT_DIR/logs/auto-update.log 2>&1"

    # Add to crontab if not already there
    (crontab -l 2>/dev/null | grep -v "$UPDATE_SCRIPT"; echo "$CRON_JOB") | crontab -

    echo -e "${GREEN}✓ Automatic updates configured${NC}"
    echo "Updates will run daily at 2:00 AM"
}

# Main setup function
main() {
    print_header "Pezkuwi Validator Setup v2.0.0"

    # Get validator number
    get_validator_number "$1"

    # Check dependencies
    check_dependencies || true
    local dep_count=${#missing_deps[@]}

    # Install missing dependencies if any
    if [ $dep_count -gt 0 ] || [ $RUST_MISSING -eq 1 ] || [ $NODE_MISSING -eq 1 ]; then
        echo -e "\n${YELLOW}Some dependencies are missing. Installing...${NC}"
        install_dependencies
    else
        echo -e "\n${GREEN}✓ All dependencies already installed${NC}"
    fi

    # Setup shared components (only if not already done)
    if [ ! -d "$SHARED_DIR/pezkuwi-sdk/target/release" ]; then
        setup_sdk
    else
        echo -e "\n${GREEN}✓ SDK already built${NC}"
    fi

    if [ ! -d "$SHARED_DIR/DKSweb/dist" ]; then
        setup_frontend
    else
        echo -e "\n${GREEN}✓ Frontend already built${NC}"
    fi

    # Configure validator
    configure_validator

    # Setup service
    setup_service

    # Setup nginx (only once for all validators)
    setup_nginx

    # Setup automatic updates
    setup_auto_update

    # Final instructions
    print_header "Setup Complete!"

    echo -e "${GREEN}Validator $VALIDATOR_NUM is ready!${NC}\n"
    echo "Next steps:"
    echo "1. Start the validator:"
    echo -e "   ${BLUE}sudo systemctl start pezkuwi-validator-$VALIDATOR_NUM${NC}"
    echo ""
    echo "2. Check validator status:"
    echo -e "   ${BLUE}sudo systemctl status pezkuwi-validator-$VALIDATOR_NUM${NC}"
    echo ""
    echo "3. View logs:"
    echo -e "   ${BLUE}tail -f $VALIDATOR_DIR/logs/validator.log${NC}"
    echo ""
    echo "4. Access frontend:"
    echo -e "   ${BLUE}http://YOUR_SERVER_IP${NC}"
    echo ""
    echo "5. Enable auto-start on boot:"
    echo -e "   ${BLUE}sudo systemctl enable pezkuwi-validator-$VALIDATOR_NUM${NC}"
    echo ""
    echo -e "${YELLOW}Note: Make sure to add validator keys to:${NC}"
    echo -e "${YELLOW}$VALIDATOR_DIR/config/keys.sh${NC}"
}

# Run main function
main "$@"
