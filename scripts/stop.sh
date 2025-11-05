#!/bin/bash

# Stop validator script
# Usage: ./stop.sh [validator_number]

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

echo -e "${YELLOW}Stopping Validator $VALIDATOR_NUM...${NC}"
sudo systemctl stop pezkuwi-validator-$VALIDATOR_NUM

# Wait for service to stop
sleep 2

# Check status
if sudo systemctl is-active --quiet pezkuwi-validator-$VALIDATOR_NUM; then
    echo -e "${RED}✗ Failed to stop Validator $VALIDATOR_NUM${NC}"
    exit 1
else
    echo -e "${GREEN}✓ Validator $VALIDATOR_NUM stopped successfully${NC}"
fi
