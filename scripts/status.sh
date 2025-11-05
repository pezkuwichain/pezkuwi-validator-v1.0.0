#!/bin/bash

# Status checker script
# Usage: ./status.sh [validator_number]

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

if [ -z "$1" ]; then
    # Show status of all validators
    echo -e "${BLUE}=== Pezkuwi Validators Status ===${NC}\n"
    for i in {1..10}; do
        if systemctl list-units --full -all | grep -q "pezkuwi-validator-$i.service"; then
            if sudo systemctl is-active --quiet pezkuwi-validator-$i; then
                echo -e "Validator $i: ${GREEN}● Running${NC}"
            else
                echo -e "Validator $i: ${RED}○ Stopped${NC}"
            fi
        fi
    done

    echo -e "\n${BLUE}=== Frontend Status ===${NC}"
    if sudo systemctl is-active --quiet nginx; then
        echo -e "Nginx: ${GREEN}● Running${NC}"
    else
        echo -e "Nginx: ${RED}○ Stopped${NC}"
    fi
else
    VALIDATOR_NUM=$1
    echo -e "${BLUE}=== Validator $VALIDATOR_NUM Status ===${NC}\n"
    sudo systemctl status pezkuwi-validator-$VALIDATOR_NUM
fi
