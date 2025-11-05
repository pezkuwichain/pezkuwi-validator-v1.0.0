# Pezkuwi Beta Testnet - Validator Package v2.0.0

Simplified validator setup package for Pezkuwi blockchain beta testnet with 8 validators running on a single machine.

## Features

- **One-command setup** - Automated installation and configuration
- **Automatic dependency checking** - Detects and guides installation of required tools
- **Shared SDK build** - Single Pezkuwi-SDK build shared across all validators
- **Single DKSweb frontend** - One frontend instance with auto-update from GitHub
- **Real validator keys** - Pre-configured with actual beta testnet validator keys
- **Systemd service management** - Easy start/stop/restart with systemd
- **Helper scripts** - Convenient management scripts for all validators
- **Nginx deployment** - Production-ready frontend deployment

## System Requirements

### Required Dependencies
- **Git** - Version control
- **Rust & Cargo** - Substrate/Polkadot SDK compilation
- **Node.js & npm** - Frontend build (v16+ recommended)
- **Build tools** - build-essential, cmake, clang, libssl-dev, pkg-config
- **Nginx** - Frontend web server
- **Systemd** - Service management (included in Ubuntu)

### Recommended System
- **OS**: Ubuntu 20.04 LTS or newer
- **CPU**: 4+ cores
- **RAM**: 8GB+
- **Storage**: 50GB+ SSD
- **Network**: Stable internet connection

## Directory Structure

```
beta_testnet/
├── README.md                      # This file
├── setup.sh                       # Main setup script
├── config/                        # Global configuration
├── scripts/                       # Helper scripts
│   ├── start.sh                  # Start individual validator
│   ├── stop.sh                   # Stop individual validator
│   ├── status.sh                 # Check validator status
│   └── logs.sh                   # View validator logs
├── validators/                    # Validator-specific data
│   ├── validator1/
│   │   ├── config/
│   │   │   └── keys.sh          # Validator 1 keys (RPC: 9944, Bootnode)
│   │   ├── data/                # Blockchain data
│   │   ├── keys/                # Keystore
│   │   └── logs/                # Log files
│   ├── validator2/              # RPC: 9945, P2P: 30334
│   ├── validator3/              # RPC: 9946, P2P: 30335
│   ├── validator4/              # RPC: 9947, P2P: 30336
│   ├── validator5/              # RPC: 9948, P2P: 30337
│   ├── validator6/              # RPC: 9949, P2P: 30338
│   ├── validator7/              # RPC: 9950, P2P: 30339
│   └── validator8/              # RPC: 9951, P2P: 30340
├── shared/                       # Shared resources
│   ├── pezkuwi-sdk/             # Shared SDK build
│   └── dksweb/                  # Shared frontend
└── systemd/                      # Systemd service templates

```

## Port Allocation

| Validator | RPC Port | P2P Port | WS Port | Prometheus |
|-----------|----------|----------|---------|------------|
| 1 (Boot)  | 9944     | 30333    | 9944    | 9615       |
| 2         | 9945     | 30334    | 9945    | 9616       |
| 3         | 9946     | 30335    | 9946    | 9617       |
| 4         | 9947     | 30336    | 9947    | 9618       |
| 5         | 9948     | 30337    | 9948    | 9619       |
| 6         | 9949     | 30338    | 9949    | 9620       |
| 7         | 9950     | 30339    | 9950    | 9621       |
| 8         | 9951     | 30340    | 9951    | 9622       |

## Quick Start

### 1. Initial Setup

Run the main setup script with a validator number (1-8):

```bash
cd /home/mamostehp/pezkuwi-validator-v2.0.0/beta_testnet
sudo ./setup.sh 1
```

This will:
- Check all dependencies
- Clone/update Pezkuwi-SDK (if needed)
- Build SDK in release mode (shared build)
- Clone/update DKSweb frontend (if needed)
- Build and deploy frontend with Nginx
- Insert validator keys
- Create systemd service
- Start the validator

### 2. Setup Additional Validators

```bash
sudo ./setup.sh 2
sudo ./setup.sh 3
# ... up to 8
```

### 3. Verify All Validators Are Running

```bash
./scripts/status.sh
```

## Helper Scripts Usage

### Start Validator

Start a single validator:
```bash
./scripts/start.sh 1
```

Start all validators:
```bash
for i in {1..8}; do ./scripts/start.sh $i; done
```

### Stop Validator

Stop a single validator:
```bash
./scripts/stop.sh 1
```

Stop all validators:
```bash
for i in {1..8}; do ./scripts/stop.sh $i; done
```

### Check Status

Check single validator:
```bash
./scripts/status.sh 1
```

Check all validators:
```bash
./scripts/status.sh
```

### View Logs

View logs for a validator:
```bash
./scripts/logs.sh 1
```

Follow logs in real-time:
```bash
./scripts/logs.sh 1 follow
```

## Systemd Service Management

Validators are managed as systemd services:

```bash
# Start validator
sudo systemctl start pezkuwi-validator-1

# Stop validator
sudo systemctl stop pezkuwi-validator-1

# Restart validator
sudo systemctl restart pezkuwi-validator-1

# Check status
sudo systemctl status pezkuwi-validator-1

# View logs
sudo journalctl -u pezkuwi-validator-1 -f

# Enable auto-start on boot
sudo systemctl enable pezkuwi-validator-1

# Disable auto-start
sudo systemctl disable pezkuwi-validator-1
```

## Validator Keys

Each validator has 6 types of keys pre-configured in `validators/validatorN/config/keys.sh`:

- **BABE** - Block authorship (sr25519)
- **GRANDPA** - Finality (ed25519)
- **PARA** - Parachain validation (sr25519)
- **ASGN** - Assignment (sr25519)
- **AUDI** - Authority discovery (sr25519)
- **BEEF** - BEEFY consensus (ecdsa)

**SECURITY WARNING**: These keys are for beta testnet only. Never use testnet keys in production!

## Frontend Access

After setup, DKSweb frontend is available at:
- **Local**: http://localhost (via Nginx)
- **Network**: http://YOUR_SERVER_IP

The frontend connects to validator 1 (bootnode) by default at `ws://127.0.0.1:9944`.

## Troubleshooting

### Validator Won't Start

Check logs:
```bash
./scripts/logs.sh 1
# or
sudo journalctl -u pezkuwi-validator-1 -n 100
```

Common issues:
- Port already in use
- Keys not inserted properly
- Insufficient permissions
- Blockchain data corruption

### Port Already in Use

Check what's using the port:
```bash
sudo lsof -i :9944
```

Kill the process:
```bash
sudo kill -9 <PID>
```

### Clear Blockchain Data

To reset a validator's blockchain data:
```bash
sudo systemctl stop pezkuwi-validator-1
rm -rf /home/mamostehp/pezkuwi-validator-v2.0.0/beta_testnet/validators/validator1/data/*
sudo systemctl start pezkuwi-validator-1
```

### Rebuild SDK

If you need to rebuild the SDK:
```bash
cd /home/mamostehp/pezkuwi-validator-v2.0.0/beta_testnet/shared/pezkuwi-sdk
cargo clean
cargo build --release
```

### Frontend Not Loading

Check Nginx status:
```bash
sudo systemctl status nginx
```

Check Nginx logs:
```bash
sudo tail -f /var/log/nginx/error.log
```

Restart Nginx:
```bash
sudo systemctl restart nginx
```

### Re-insert Keys

If keys need to be re-inserted:
```bash
cd /home/mamostehp/pezkuwi-validator-v2.0.0/beta_testnet
source validators/validator1/config/keys.sh

# Insert each key type
curl -H "Content-Type: application/json" \
  -d "{\"id\":1,\"jsonrpc\":\"2.0\",\"method\":\"author_insertKey\",\"params\":[\"babe\",\"$BABE_SEED\",\"$BABE_PUBLIC_KEY\"]}" \
  http://127.0.0.1:9944
```

## Network Information

- **Network**: Pezkuwi Beta Testnet
- **Chain Spec**: pezkuwichain-beta-testnet
- **Genesis**: Same across all validators
- **Bootnode**: Validator 1 (127.0.0.1:30333)

## Maintenance

### Update SDK

```bash
cd /home/mamostehp/pezkuwi-validator-v2.0.0/beta_testnet/shared/pezkuwi-sdk
git pull origin main
cargo build --release

# Restart all validators
for i in {1..8}; do sudo systemctl restart pezkuwi-validator-$i; done
```

### Update Frontend

```bash
cd /home/mamostehp/pezkuwi-validator-v2.0.0/beta_testnet/shared/dksweb
git pull origin main
npm install
npm run build
sudo systemctl restart nginx
```

### Backup Validator Keys

```bash
# Backup all validator keys
tar -czf validator-keys-backup.tar.gz validators/validator*/config/keys.sh

# Copy to safe location
cp validator-keys-backup.tar.gz /backup/location/
```

## Security Best Practices

1. **Never expose RPC ports to public internet** - Use firewall rules
2. **Backup validator keys securely** - Store encrypted backups offline
3. **Use different keys for production** - Never reuse testnet keys
4. **Keep system updated** - Regular security updates
5. **Monitor validator logs** - Watch for suspicious activity
6. **Restrict SSH access** - Use key-based authentication only
7. **Run validators as non-root** - Use dedicated user accounts

## Support

For issues or questions:
- Check logs first: `./scripts/logs.sh <validator_num>`
- Review this README
- Check validator status: `./scripts/status.sh`
- Consult Pezkuwi documentation

## License

This validator package is part of the Pezkuwi blockchain project.

---

**Last Updated**: 2025-11-05
**Package Version**: 2.0.0
**Network**: Beta Testnet (8 Validators)
