# Pezkuwi Validator Setup - Multi-Network Deployment v3.0.0

Complete validator setup package for Pezkuwi blockchain with support for multiple networks and distributed deployment across separate machines.

## Overview

This repository provides an automated setup system for deploying Pezkuwi blockchain validators across distributed infrastructure. Designed for multi-network deployment (beta testnet, staging, mainnet) with each validator running on its own dedicated machine.

## Architecture

**Distributed Deployment Model:**
- Each validator runs on a separate physical/virtual machine
- Each validator builds its own SDK and frontend locally
- Validators connect sequentially: V2→V1, V3→V2, V4→V3, etc.
- Bootnode information shared manually between operators
- No shared resources between validators

**Network Support:**
- **Beta Testnet**: 8 validators (fully configured with keys)
- **Staging**: 20 validators (validator1 ready, others to be added)
- **Mainnet**: 100 validators (validator1 ready, others to be added)

## Features

- ✅ **One-command setup** - Single command for complete validator deployment
- ✅ **Automatic dependency installation** - Detects and installs all required tools
- ✅ **Multi-network support** - Beta testnet, staging, and mainnet configurations
- ✅ **Distributed architecture** - Each validator on separate machine
- ✅ **User-safe builds** - All builds run as actual user (not root)
- ✅ **Pre-configured keys** - Real validator keys for beta testnet
- ✅ **Systemd integration** - Production-ready service management
- ✅ **Nginx deployment** - Frontend served via Nginx
- ✅ **First-time user friendly** - Designed for terminal beginners

## System Requirements

### Required Dependencies

The setup script automatically installs:
- **Git** - Version control
- **Rust & Cargo** - Substrate/Polkadot SDK compilation
- **Node.js & npm** - Frontend build (v20.x)
- **Build tools** - build-essential, clang, libssl-dev, pkg-config
- **Nginx** - Frontend web server
- **Systemd** - Service management (included in Ubuntu)

### Recommended Hardware

**Per Validator:**
- **OS**: Ubuntu 20.04 LTS or newer
- **CPU**: 4+ cores
- **RAM**: 8GB minimum, 16GB recommended
- **Storage**: 100GB+ SSD
- **Network**: Stable internet connection with public IP
- **Ports**: Firewall configured for P2P communication

## Repository Structure

```
pezkuwi-validator/
├── README.md                              # This file
├── .gitignore                             # Git ignore rules
├── setup.sh                               # Multi-network setup script (v3.0.0)
│
├── beta_testnet/                          # Beta Testnet (8 validators)
│   ├── validators/
│   │   ├── validator1/config/keys.sh     # Bootnode (RPC: 9944, P2P: 30333)
│   │   ├── validator2/config/keys.sh     # RPC: 9945, P2P: 30334
│   │   ├── validator3/config/keys.sh     # RPC: 9946, P2P: 30335
│   │   ├── validator4/config/keys.sh     # RPC: 9947, P2P: 30336
│   │   ├── validator5/config/keys.sh     # RPC: 9948, P2P: 30337
│   │   ├── validator6/config/keys.sh     # RPC: 9949, P2P: 30338
│   │   ├── validator7/config/keys.sh     # RPC: 9950, P2P: 30339
│   │   └── validator8/config/keys.sh     # RPC: 9951, P2P: 30340
│   └── chain-specs/                      # Network chain specifications
│
├── staging/                               # Staging Network (20 validators)
│   ├── validators/
│   │   └── validator1/config/            # More validators to be added
│   └── chain-specs/
│
└── mainnet/                               # Production Network (100 validators)
    ├── validators/
    │   └── validator1/config/            # More validators to be added
    └── chain-specs/
```

## Quick Start

### For Validator Operators

You will receive a single command via WhatsApp that looks like this:

```bash
# Example: Setting up validator 8 on beta testnet
git clone https://github.com/pezkuwichain/pezkuwi-validator-v1.0.0.git
cd pezkuwi-validator-v1.0.0
sudo ./setup.sh beta_testnet 8
```

That's it! The script will:
1. ✅ Check and install all missing dependencies
2. ✅ Clone and build Pezkuwi SDK (~15-30 minutes)
3. ✅ Clone and build DKSweb frontend
4. ✅ Prompt for bootnode information (if validator > 1)
5. ✅ Configure validator-specific settings
6. ✅ Create systemd service
7. ✅ Setup Nginx for frontend
8. ✅ Provide clear next-step instructions

### Setup Script Usage

```bash
sudo ./setup.sh <network> <validator_number>
```

**Parameters:**
- `<network>`: Network to deploy on
  - `beta_testnet` - Beta testnet (8 validators)
  - `staging` - Staging network (20 validators)
  - `mainnet` - Production network (100 validators)

- `<validator_number>`: Your validator number (1-8 for beta, 1-20 for staging, 1-100 for mainnet)

**Examples:**
```bash
# Beta testnet validator 1 (bootnode)
sudo ./setup.sh beta_testnet 1

# Beta testnet validator 8
sudo ./setup.sh beta_testnet 8

# Staging network validator 5
sudo ./setup.sh staging 5

# Mainnet validator 42
sudo ./setup.sh mainnet 42
```

## Port Allocation

Each validator uses sequential ports:

| Validator | RPC Port | P2P Port | WebSocket | Prometheus |
|-----------|----------|----------|-----------|------------|
| 1 (Boot)  | 9944     | 30333    | 9944      | 9615       |
| 2         | 9945     | 30334    | 9945      | 9616       |
| 3         | 9946     | 30335    | 9946      | 9617       |
| 4         | 9947     | 30336    | 9947      | 9618       |
| 5         | 9948     | 30337    | 9948      | 9619       |
| 6         | 9949     | 30338    | 9949      | 9620       |
| 7         | 9950     | 30339    | 9950      | 9621       |
| 8         | 9951     | 30340    | 9951      | 9622       |

**Pattern:** Each subsequent validator increments all ports by 1.

## Validator Management

### Systemd Service Commands

The setup script creates a systemd service for each validator:

```bash
# Start your validator
sudo systemctl start pezkuwi-validator-beta_testnet-8

# Stop your validator
sudo systemctl stop pezkuwi-validator-beta_testnet-8

# Restart your validator
sudo systemctl restart pezkuwi-validator-beta_testnet-8

# Check validator status
sudo systemctl status pezkuwi-validator-beta_testnet-8

# View live logs
sudo journalctl -u pezkuwi-validator-beta_testnet-8 -f

# Enable auto-start on boot
sudo systemctl enable pezkuwi-validator-beta_testnet-8

# Disable auto-start
sudo systemctl disable pezkuwi-validator-beta_testnet-8
```

**Service Name Pattern:**
`pezkuwi-validator-<network>-<validator_number>`

Examples:
- `pezkuwi-validator-beta_testnet-1`
- `pezkuwi-validator-staging-5`
- `pezkuwi-validator-mainnet-42`

### Log Files

Logs are stored in your validator directory:

```bash
# After setup completes, logs are at:
# /home/mamostehp/pezkuwi-validator/beta_testnet/validators/validator8/logs/

# View validator log
tail -f ~/pezkuwi-validator/beta_testnet/validators/validator8/logs/validator.log

# View error log
tail -f ~/pezkuwi-validator/beta_testnet/validators/validator8/logs/validator-error.log
```

## Validator Keys

Each beta testnet validator has 6 types of pre-configured keys:

- **BABE** - Block authorship (sr25519)
- **GRANDPA** - Finality (ed25519)
- **PARA** - Parachain validation (sr25519)
- **ASGN** - Assignment (sr25519)
- **AUDI** - Authority discovery (sr25519)
- **BEEF** - BEEFY consensus (ecdsa)

Keys are stored in:
```
beta_testnet/validators/validator<N>/config/keys.sh
```

**⚠️ SECURITY WARNING**:
- Beta testnet keys are for testing only
- Never use testnet keys in staging or production
- Keep production keys secure and backed up offline
- Never commit private keys to version control

## Bootnode Connection

### For Validator 1 (Bootnode)

After starting your validator, you'll need to share your bootnode information:

1. Start your validator:
   ```bash
   sudo systemctl start pezkuwi-validator-beta_testnet-1
   ```

2. Check logs for your peer ID:
   ```bash
   tail -f ~/pezkuwi-validator/beta_testnet/validators/validator1/logs/validator.log | grep "Local node identity"
   ```

3. You'll see something like:
   ```
   Local node identity is: 12D3KooWAbCdEf...
   ```

4. Share your bootnode multiaddr with validator 2:
   ```
   /ip4/YOUR_PUBLIC_IP/tcp/30333/p2p/12D3KooWAbCdEf...
   ```

### For Validators 2-8

During setup, you'll be prompted:
```
Please obtain the bootnode multiaddr from validator N-1
Enter bootnode multiaddr (or press Enter to skip):
```

Paste the multiaddr you received from the previous validator.

## Frontend Access

After setup, the DKSweb frontend is available at:

- **Local**: http://localhost
- **Network**: http://YOUR_SERVER_IP

The frontend connects to your local validator node and provides:
- Wallet management
- Token transfers
- Staking operations
- Network statistics

## Troubleshooting

### Setup Script Fails

**Check dependency installation:**
```bash
# The script should auto-install, but you can manually check:
git --version
rustc --version
cargo --version
node --version
npm --version
nginx -v
```

**Permission issues:**
```bash
# Make sure you're running with sudo:
sudo ./setup.sh beta_testnet 8
```

### Validator Won't Start

**Check service status:**
```bash
sudo systemctl status pezkuwi-validator-beta_testnet-8
```

**Check logs:**
```bash
sudo journalctl -u pezkuwi-validator-beta_testnet-8 -n 100
```

**Common issues:**
- Port already in use
- Keys not inserted properly
- Insufficient disk space
- Network connectivity issues
- Invalid bootnode address

### Port Already in Use

```bash
# Check what's using the port:
sudo lsof -i :9951

# Kill the process if needed:
sudo kill -9 <PID>

# Restart your validator:
sudo systemctl restart pezkuwi-validator-beta_testnet-8
```

### Clear Blockchain Data

If you need to reset and sync from scratch:

```bash
# Stop validator
sudo systemctl stop pezkuwi-validator-beta_testnet-8

# Clear blockchain data
rm -rf ~/pezkuwi-validator/beta_testnet/validators/validator8/data/*

# Start validator
sudo systemctl start pezkuwi-validator-beta_testnet-8
```

### Rebuild SDK

If SDK update is released:

```bash
# Navigate to SDK directory
cd ~/pezkuwi-sdk

# Pull latest changes
git pull origin main

# Clean and rebuild
cargo clean
cargo build --release

# Restart your validator
sudo systemctl restart pezkuwi-validator-beta_testnet-8
```

### Frontend Not Loading

```bash
# Check Nginx status
sudo systemctl status nginx

# Check Nginx error logs
sudo tail -f /var/log/nginx/error.log

# Restart Nginx
sudo systemctl restart nginx
```

### Re-insert Keys

If keys need to be re-inserted:

```bash
# Source your keys
cd ~/pezkuwi-validator
source beta_testnet/validators/validator8/config/keys.sh

# Insert BABE key (example)
curl -H "Content-Type: application/json" \
  -d "{\"id\":1,\"jsonrpc\":\"2.0\",\"method\":\"author_insertKey\",\"params\":[\"babe\",\"$BABE_SEED\",\"$BABE_PUBLIC_KEY\"]}" \
  http://127.0.0.1:9951

# Repeat for other key types: gran, para, asgn, audi, beef
```

## Network Information

### Beta Testnet
- **Chain Spec**: pezkuwichain-beta-testnet
- **Validators**: 8
- **Purpose**: Testing and development
- **Bootnode**: Validator 1

### Staging
- **Chain Spec**: pezkuwichain-staging
- **Validators**: 20 (planned)
- **Purpose**: Pre-production testing
- **Status**: Under development

### Mainnet
- **Chain Spec**: pezkuwichain-mainnet
- **Validators**: 100 (planned)
- **Purpose**: Production network
- **Status**: Under development

## Maintenance

### Update SDK

```bash
cd ~/pezkuwi-sdk
git pull origin main
cargo build --release
sudo systemctl restart pezkuwi-validator-beta_testnet-8
```

### Update Frontend

```bash
cd ~/DKSweb
git pull origin main
npm install
npm run build
sudo systemctl restart nginx
```

### Backup Validator Keys

```bash
# Backup your keys (do this regularly!)
cp ~/pezkuwi-validator/beta_testnet/validators/validator8/config/keys.sh \
   ~/validator8-keys-backup-$(date +%Y%m%d).sh

# Copy to secure location (offline storage recommended)
# NEVER commit keys to git or store unencrypted online
```

### Monitor Validator

```bash
# Live logs
sudo journalctl -u pezkuwi-validator-beta_testnet-8 -f

# Check if producing blocks
tail -f ~/pezkuwi-validator/beta_testnet/validators/validator8/logs/validator.log | grep "Prepared block"

# Check peer count
tail -f ~/pezkuwi-validator/beta_testnet/validators/validator8/logs/validator.log | grep "peers"
```

## Security Best Practices

1. **🔒 Firewall Configuration**
   - Only expose P2P port (30333+) to internet
   - Block RPC/WebSocket ports from external access
   - Use SSH key-based authentication only

2. **🔑 Key Management**
   - Backup keys to offline storage
   - Never share private keys or seeds
   - Use different keys for each network
   - Rotate keys periodically

3. **🛡️ System Security**
   - Keep system updated: `sudo apt update && sudo apt upgrade`
   - Run validator as non-root user
   - Enable automatic security updates
   - Monitor logs for suspicious activity

4. **📊 Monitoring**
   - Set up monitoring alerts
   - Check validator uptime regularly
   - Monitor disk space usage
   - Watch for sync issues

5. **💾 Backups**
   - Backup validator keys regularly
   - Document your validator setup
   - Keep recovery procedures updated

## Support

### Getting Help

1. **Check logs first:**
   ```bash
   sudo journalctl -u pezkuwi-validator-beta_testnet-8 -n 200
   ```

2. **Review this README** - Most common issues are documented here

3. **Check validator status:**
   ```bash
   sudo systemctl status pezkuwi-validator-beta_testnet-8
   ```

4. **Contact the team** - Reach out via official Pezkuwi channels

### Common Questions

**Q: How long does initial sync take?**
A: Initial blockchain sync can take several hours depending on network size and your connection speed.

**Q: Can I run multiple validators on one machine?**
A: Not recommended for this deployment model. Each validator should have dedicated hardware.

**Q: What if I lose my keys?**
A: Always backup keys securely. Lost keys mean lost validator access.

**Q: Can I change my validator number?**
A: No, validator numbers are assigned and fixed per network.

## Contributing

This is a production deployment repository. Changes should be coordinated with the Pezkuwi team.

## License

This validator package is part of the Pezkuwi blockchain project.

---

**Package Version**: v3.0.0
**Last Updated**: 2025-11-06
**Architecture**: Distributed Multi-Network Deployment
**Supported Networks**: Beta Testnet (8), Staging (20), Mainnet (100)

**Repository**: https://github.com/pezkuwichain/pezkuwi-validator-v1.0.0
