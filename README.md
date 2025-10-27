# Pezkuwi Validator Installer

One-click validator installer for Pezkuwi testnet. Cross-platform scripts for automated node deployment.

## 🚀 Quick Start

### Linux / macOS (One-Line Install)
```bash
curl -sSf https://raw.githubusercontent.com/pezkuwichain/pezkuwi-validator-v1.0.0/main/scripts/linux/install-validator.sh | bash
```

### Windows (PowerShell)
```powershell
# Coming soon
```

## 📋 Prerequisites

- **OS**: Linux (Ubuntu 20.04+, Debian 11+, Fedora 35+)
- **CPU**: Minimum 2 cores (4+ recommended)
- **RAM**: Minimum 4GB (8GB+ recommended)
- **Storage**: 50GB+ free space
- **Network**: Public IP with ports 30333 (P2P) and 9944 (RPC) open

## 🔧 What Does the Installer Do?

1. ✅ Checks system requirements
2. ✅ Installs dependencies
3. ✅ Downloads Pezkuwi binaries from GitHub Releases
4. ✅ Downloads chain specification
5. ✅ Generates validator keys
6. ✅ Creates systemd service
7. ✅ Starts validator node

## 📊 Post-Installation

### Check Node Status
```bash
sudo systemctl status pezkuwi-validator
```

### View Live Logs
```bash
sudo journalctl -u pezkuwi-validator -f
```

### Stop Validator
```bash
sudo systemctl stop pezkuwi-validator
```

### Restart Validator
```bash
sudo systemctl restart pezkuwi-validator
```

## 📁 Installation Directory

All files are installed to: `~/.pezkuwi/`
```
~/.pezkuwi/
├── bin/              # Binaries
├── config/           # Chain spec
├── data/             # Blockchain data
└── keys/             # Validator keys
```

## 🔑 Your Validator Keys

After installation, your node ID is saved in:
```bash
cat ~/.pezkuwi/keys/node-id.txt
```

**⚠️ IMPORTANT**: Backup this file! You'll need it for testnet registration.

## 🌐 Connect to Your Node

- **RPC Endpoint**: `http://localhost:9944`
- **WebSocket**: `ws://localhost:9944`

Test connection:
```bash
curl -H "Content-Type: application/json" \
     -d '{"id":1, "jsonrpc":"2.0", "method": "system_health"}' \
     http://localhost:9944
```

## 🆘 Troubleshooting

### Node Not Starting
```bash
# Check logs
sudo journalctl -u pezkuwi-validator -n 100

# Check service status
sudo systemctl status pezkuwi-validator
```

### Firewall Issues
```bash
# Open required ports (Ubuntu/Debian)
sudo ufw allow 30333/tcp
sudo ufw allow 9944/tcp
```

## 📚 Documentation

- [Validator Guide](./docs/VALIDATOR-GUIDE.md)
- [Troubleshooting](./docs/TROUBLESHOOTING.md)
- [FAQ](./docs/FAQ.md)

## 🤝 Support

- GitHub Issues: https://github.com/pezkuwichain/pezkuwi-validator-v1.0.0/issues
- Telegram: https://t.me/pezkuwichain
- Discord: Coming soon

## 📜 License

GNU General Public License v3.0

---

**Made with ❤️ by Kurdistan Tech Ministry**
