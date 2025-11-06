#!/bin/bash

# ========================================
# Validator 5 - Real Beta Testnet Keys
# ========================================
# Validator Name: Validator-beta-5
# RPC Port: 9948
# P2P Port: 30337

# BABE Keys (Block Authorship)
export BABE_SEED="clap screen soap once near guilt accuse hamster knife drink purity skull"
export BABE_PUBLIC_KEY="0x74270a49be316a233279af6480ac8de5479bc45426e884fbdb50c6247e62d44b"

# GRANDPA Keys (Finality)
export GRAN_SEED="innocent fix endless engine yellow smoke venture answer before dentist trend pulse"
export GRAN_PUBLIC_KEY="0x9ae1139d89f5ae5e9a56a7a7d1375c49b742315c25712128fad16c841da2dba9"

# PARA Keys (Parachain)
export PARA_SEED="peanut catch embody spy orbit design occur series cricket ski ketchup impose"
export PARA_PUBLIC_KEY="0xf49d1b0ebff5fbf31cba037085552fd78e4218a19045cdd5f2e1f73840156a75"

# ASGN Keys (Assignment)
export ASGN_SEED="orchard globe member blue install rude cement luxury grant cause exit expect"
export ASGN_PUBLIC_KEY="0xb8f786ac5db52f3713ca1ff58f8d708332f2c0556d55a62195a52d4ca1bb2e7e"

# AUDI Keys (Authority Discovery)
export AUDI_SEED="pistol focus above decade weekend matter claw drift glad worry quarter slice"
export AUDI_PUBLIC_KEY="0x3e1c338ba320b747769d2d40ece3fc3da306b90096ab381bad1be6bc5a813d57"

# BEEF Keys (BEEFY)
export BEEF_SEED="mother model label zoo mouse detail cost pet umbrella rate proud unable"
export BEEF_PUBLIC_KEY="0x033cae08ede6b1c3597dfce1f38c5ceddc4b69d045de4b51f17e2e8fce1cda27ca"

# Validator Configuration
export VALIDATOR_NAME="Validator-beta-5"
export RPC_PORT=9948
export P2P_PORT=30337
export WS_PORT=9948
export PROMETHEUS_PORT=9619
