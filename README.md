# Pezkuwi Validator Installer

One-click validator installer for Pezkuwi testnet. Cross-platform scripts for automated node deployment.

## 🚀 Quick Start

### Linux / macOS (One-Line Install)
bash
curl -sSf https://raw.githubusercontent.com/pezkuwichain/pezkuwi-validator-v1.0.0/main/scripts/linux/install-validator.sh | bash


**⚠️ Note:** This will install Pezkuwi validator to `~/.pezkuwi/` directory.

### What Gets Installed?

- **Binaries**: pezkuwi, pezkuwi-prepare-worker, pezkuwi-execute-worker (67 MB)
- **Chain Spec**: Testnet configuration
- **Systemd Service**: Auto-restart on failure
- **Validator Keys**: Automatically generated

### Test Installation (Dry Run)
bash
# Download script and review it first
wget https://raw.githubusercontent.com/pezkuwichain/pezkuwi-validator-v1.0.0/main/scripts/linux/install-validator.sh
less install-validator.sh
bash install-validator.sh


### Windows (PowerShell)

**⚠️ Run as Administrator**
powershell
iwr -useb https://raw.githubusercontent.com/pezkuwichain/pezkuwi-validator-v1.0.0/main/scripts/windows/install-validator.ps1 | iex


**What Gets Installed?**

- **Binaries**: pezkuwi.exe, pezkuwi-prepare-worker.exe, pezkuwi-execute-worker.exe
- **Windows Service**: PezkuwiValidator (auto-start enabled)
- **Dependencies**: Chocolatey, NSSM (service manager)
- **Firewall**: Ports 30333 and 9944 (manual configuration may be required)

**Manual Installation (if one-liner fails):**
powershell
# Download script
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/pezkuwichain/pezkuwi-validator-v1.0.0/main/scripts/windows/install-validator.ps1" -OutFile "install-validator.ps1"

# Review script
notepad install-validator.ps1

# Run as Administrator
.\install-validator.ps1


**Check Service Status:**
powershell
Get-Service PezkuwiValidator


### Docker (Recommended for Production)

**Prerequisites:** Docker 20.10+ and Docker Compose 2.0+
bash
# Clone repository
git clone https://github.com/pezkuwichain/pezkuwi-validator-v1.0.0.git
cd pezkuwi-validator-v1.0.0/docker

# Start validator
docker-compose up -d

# View logs
docker-compose logs -f pezkuwi-validator


**With Monitoring (Prometheus + Grafana):**
bash
docker-compose --profile monitoring up -d


**Access:**
- Validator RPC: http://localhost:9944
- Prometheus: http://localhost:9090
- Grafana: http://localhost:3000 (admin/pezkuwi123)

📚 **Full Docker documentation:** [docker/README.md](./docker/README.md)

## 📋 Prerequisites

- **OS**: Linux (Ubuntu 20.04+, Debian 11+, Fedora 35+)
- **CPU**: Minimum 2 cores (4+ recommended)
- **RAM**: Minimum 4GB (8GB+ recommended)
- **Storage**: 50GB+ free space
- **Network**: Public IP with ports 30333 (P2P) and 9944 (RPC) open

## 🔧 What Does the Installer Do?

1. ✅ Checks system requirements
2. ✅ Installs dependencies
3. ✅ Downloads Pezkuwi binaries from GitHub Releases (67 MB compressed)
4. ✅ Extracts binaries to `~/.pezkuwi/bin/`
5. ✅ Downloads chain specification
6. ✅ Generates validator keys automatically
7. ✅ Creates systemd service (auto-restart enabled)
8. ✅ Starts validator node
9. ✅ Displays node ID and useful commands

## 📊 Post-Installation

### Check Node Status
bash
sudo systemctl status pezkuwi-validator


### View Live Logs
bash
sudo journalctl -u pezkuwi-validator -f


### Stop Validator
bash
sudo systemctl stop pezkuwi-validator


### Restart Validator
bash
sudo systemctl restart pezkuwi-validator


## 📁 Installation Directory

All files are installed to: `~/.pezkuwi/`

~/.pezkuwi/
├── bin/              # Binaries
├── config/           # Chain spec
├── data/             # Blockchain data
└── keys/             # Validator keys


## 🔑 Your Validator Keys

After installation, your node ID is saved in:
bash
cat ~/.pezkuwi/keys/node-id.txt


**⚠️ IMPORTANT**: Backup this file! You'll need it for testnet registration.

## 🌐 Connect to Your Node

- **RPC Endpoint**: `http://localhost:9944`
- **WebSocket**: `ws://localhost:9944`

Test connection:
bash
curl -H "Content-Type: application/json" \
     -d '{"id":1, "jsonrpc":"2.0", "method": "system_health"}' \
     http://localhost:9944


## 🆘 Troubleshooting

### Node Not Starting
bash
# Check logs
sudo journalctl -u pezkuwi-validator -n 100

# Check service status
sudo systemctl status pezkuwi-validator


### Firewall Issues
bash
# Open required ports (Ubuntu/Debian)
sudo ufw allow 30333/tcp
sudo ufw allow 9944/tcp


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
