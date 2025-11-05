#!/bin/bash

# Logs viewer script
# Usage: ./logs.sh [validator_number] [lines]

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VALIDATORS_DIR="$SCRIPT_DIR/../validators"

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

if [ -z "$1" ]; then
    echo -e "${RED}Error: Validator number required${NC}"
    echo "Usage: $0 [validator_number] [lines (default: 50)]"
    exit 1
fi

VALIDATOR_NUM=$1
LINES=${2:-50}
VALIDATOR_DIR="$VALIDATORS_DIR/validator$VALIDATOR_NUM"

echo -e "${BLUE}=== Validator $VALIDATOR_NUM Logs (last $LINES lines) ===${NC}\n"

if [ -f "$VALIDATOR_DIR/logs/validator.log" ]; then
    tail -n "$LINES" "$VALIDATOR_DIR/logs/validator.log"
    echo -e "\n${YELLOW}To follow logs in real-time, use:${NC}"
    echo "tail -f $VALIDATOR_DIR/logs/validator.log"
else
    echo -e "${YELLOW}No logs found. Service may not have started yet.${NC}"
    echo -e "\nTry viewing with journalctl:"
    echo "sudo journalctl -u pezkuwi-validator-$VALIDATOR_NUM -n $LINES"
fi

echo -e "\n${BLUE}=== Error Logs ===${NC}\n"
if [ -f "$VALIDATOR_DIR/logs/validator-error.log" ]; then
    tail -n "$LINES" "$VALIDATOR_DIR/logs/validator-error.log"
else
    echo -e "${GREEN}No errors${NC}"
fi
