# Pezkuwi Validator - Docker Setup

Run Pezkuwi validator node using Docker and Docker Compose.

## 🚀 Quick Start

### Prerequisites

- Docker 20.10+
- Docker Compose 2.0+

**Install Docker:**
```bash
# Linux
curl -fsSL https://get.docker.com | sh
sudo usermod -aG docker $USER

# Verify
docker --version
docker-compose --version
```

### Run Validator
```bash
# Clone repository
git clone https://github.com/pezkuwichain/pezkuwi-validator-v1.0.0.git
cd pezkuwi-validator-v1.0.0/docker

# Start validator
docker-compose up -d

# Check logs
docker-compose logs -f pezkuwi-validator

# Check status
docker-compose ps
```

## 📊 Monitoring (Optional)

Start with Prometheus and Grafana:
```bash
docker-compose --profile monitoring up -d
```

**Access:**
- Prometheus: http://localhost:9090
- Grafana: http://localhost:3000 (admin/pezkuwi123)

## 🔧 Management Commands
```bash
# Stop validator
docker-compose stop

# Restart validator
docker-compose restart

# View logs
docker-compose logs -f

# Remove everything (including data)
docker-compose down -v

# Update to latest version
docker-compose pull
docker-compose up -d
```

## 📁 Data Persistence

Blockchain data is stored in Docker volume: `validator-data`

**Backup data:**
```bash
docker run --rm -v validator-data:/data -v $(pwd):/backup ubuntu tar czf /backup/validator-backup.tar.gz /data
```

**Restore data:**
```bash
docker run --rm -v validator-data:/data -v $(pwd):/backup ubuntu tar xzf /backup/validator-backup.tar.gz -C /
```

## 🔑 Validator Keys

Keys are generated automatically on first start in `/pezkuwi/data/chains/`

**Extract your Node ID:**
```bash
docker-compose exec pezkuwi-validator cat /pezkuwi/data/chains/pezkuwi_testnet/network/secret_ed25519
```

## 🌐 Network Ports

- **30333**: P2P port (required for validators)
- **9944**: RPC/WebSocket (for local access)
- **9615**: Prometheus metrics

## 🐛 Troubleshooting

### Container won't start
```bash
# Check logs
docker-compose logs pezkuwi-validator

# Rebuild image
docker-compose build --no-cache
docker-compose up -d
```

### Out of disk space
```bash
# Check disk usage
docker system df

# Prune unused data
docker system prune -a
```

### Performance issues
```bash
# Check resource usage
docker stats pezkuwi-validator

# Increase resources in Docker Desktop settings
```

## 🔄 Updates
```bash
# Pull latest image
docker-compose pull

# Restart with new image
docker-compose up -d
```

## 📝 Custom Configuration

Edit `docker-compose.yml` to customize:
- Node name
- Ports
- Resource limits
- Logging options

Example resource limits:
```yaml
services:
  pezkuwi-validator:
    # ... other config
    deploy:
      resources:
        limits:
          cpus: '2'
          memory: 4G
        reservations:
          cpus: '1'
          memory: 2G
```
