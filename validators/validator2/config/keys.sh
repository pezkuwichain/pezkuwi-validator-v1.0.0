#!/bin/bash

# ========================================
# Validator 2 - Real Beta Testnet Keys
# ========================================
# Validator Name: Validator-beta-2
# RPC Port: 9945
# P2P Port: 30334

# BABE Keys (Block Authorship)
export BABE_SEED="nature pink baby physical hotel dirt soon meadow coin employ enroll remind"
export BABE_PUBLIC_KEY="0xbef3df377441fe6ad64b81e84c8d201bc5c0bc2bb2e1a85f1e84927c62c5572b"

# GRANDPA Keys (Finality)
export GRAN_SEED="rent little raven auction error goat error water twice defy hard slab"
export GRAN_PUBLIC_KEY="0x806cfed7a6d025bc2e7a195bcd5ac50317f824ce6971cf30f95c6a621d6e55bf"

# PARA Keys (Parachain)
export PARA_SEED="mystery rescue elbow update effort path sleep rather deer undo school size"
export PARA_PUBLIC_KEY="0xfca6fd2976ae3ea397b15cdc5b0b044fe90a2094328edfa013db80cf04ba1a67"

# ASGN Keys (Assignment)
export ASGN_SEED="curious step vast scan couch episode maid trap crazy swap junior slab"
export ASGN_PUBLIC_KEY="0xfaad0803c450bf084ca3035bd1d69481db58444b32dd0eaa55de69a5314b0559"

# AUDI Keys (Authority Discovery)
export AUDI_SEED="race frequent goose clean labor differ credit lawn lab risk ocean black"
export AUDI_PUBLIC_KEY="0x7aeed77ed10108ead6c58dd45dd987aba28ea6e9cdf90f8893112c08bb0d4251"

# BEEF Keys (BEEFY)
export BEEF_SEED="industry flush stairs zoo world width dentist special life retire suffer myth"
export BEEF_PUBLIC_KEY="0x020177ca58f45047c737e6e02adba1ac3520eb881ea38ad39751d32d7c89d5efaa"

# Validator Configuration
export VALIDATOR_NAME="Validator-beta-2"
export RPC_PORT=9945
export P2P_PORT=30334
export WS_PORT=9945
export PROMETHEUS_PORT=9616
