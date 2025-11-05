#!/bin/bash

# ========================================
# Validator 4 - Real Beta Testnet Keys
# ========================================
# Validator Name: Validator-beta-4
# RPC Port: 9947
# P2P Port: 30336

# BABE Keys (Block Authorship)
export BABE_SEED="evoke second recipe turn salad warfare mix sense cry impact demise avocado"
export BABE_PUBLIC_KEY="0x9236bf5cde2e1ce44cd2eceece98b876750cb39a8887bcc1d7c0b72c186b4f6c"

# GRANDPA Keys (Finality)
export GRAN_SEED="sea resemble monitor fetch quit cotton amused settle limit venue frequent electric"
export GRAN_PUBLIC_KEY="0x4d7787f6d6b189b64286efdf524a5d73be1eaf4a4b1d245529090b698285a0d4"

# PARA Keys (Parachain)
export PARA_SEED="rubber decorate coyote grass solar butter melt ginger smile flush dash monitor"
export PARA_PUBLIC_KEY="0xb27fea579fdc321ebac8975717c17a7b4036bb06549c41ac803c888b9104a256"

# ASGN Keys (Assignment)
export ASGN_SEED="tomato glad flower miracle duty hundred filter gain clay butter twist chronic"
export ASGN_PUBLIC_KEY="0x9ef9bf97dfc3d22cd4e17a331165afbf0a562a9a86e776592c64ba87c4162d0a"

# AUDI Keys (Authority Discovery)
export AUDI_SEED="group trial problem lesson angle grief agent harvest pattern identify approve security"
export AUDI_PUBLIC_KEY="0x6abffb32a990117c3d8c74f090b287d5888af97b61a3964a2c54cddc614e4d71"

# BEEF Keys (BEEFY)
export BEEF_SEED="ridge way rhythm renew mix city element obtain prepare glass exist hope"
export BEEF_PUBLIC_KEY="0x02ca2cac4bd7d21c1c3f7b256233827d8546471d83e1eeb37408767adc66bac7d0"

# Validator Configuration
export VALIDATOR_NAME="Validator-beta-4"
export RPC_PORT=9947
export P2P_PORT=30336
export WS_PORT=9947
export PROMETHEUS_PORT=9618
