#!/bin/bash

# Start validator script
# Usage: ./start.sh [validator_number]

set -e

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

if [ -z "$1" ]; then
    echo -e "${RED}Error: Validator number required${NC}"
    echo "Usage: $0 [validator_number]"
    exit 1
fi

VALIDATOR_NUM=$1

echo -e "${YELLOW}Starting Validator $VALIDATOR_NUM...${NC}"
sudo systemctl start pezkuwi-validator-$VALIDATOR_NUM

# Wait for service to start
sleep 2

# Check status
if sudo systemctl is-active --quiet pezkuwi-validator-$VALIDATOR_NUM; then
    echo -e "${GREEN}✓ Validator $VALIDATOR_NUM started successfully${NC}"
else
    echo -e "${RED}✗ Failed to start Validator $VALIDATOR_NUM${NC}"
    echo "Check logs with: ./scripts/logs.sh $VALIDATOR_NUM"
    exit 1
fi
