#!/bin/bash

# ========================================
# Validator 1 - Real Beta Testnet Keys
# ========================================
# Generated from actual running beta testnet
# Validator Name: Validator-beta-1 (Bootnode)
# RPC Port: 9944
# P2P Port: 30333

# BABE Keys (Block Authorship)
export BABE_SEED="state open glance maze canyon cable cargo parent blind mystery cheese foot"
export BABE_PUBLIC_KEY="0x9e7490cfe0dd32860282dd4e74b5c40c9237fb6e478066c334c931742308e008"

# GRANDPA Keys (Finality)
export GRAN_SEED="kick surge tube arrange enforce witness mouse spray disease inquiry inch stamp"
export GRAN_PUBLIC_KEY="0x16da26f049b37e9b03d14439457ac164f14f5174b1f10ddab2e0dc3ef7903675"

# PARA Keys (Parachain)
export PARA_SEED="march cancel try improve lunch phrase rebuild initial theme snap giant dry"
export PARA_PUBLIC_KEY="0xc62b764ea84411f550818a41a6abacddb9388cefbc22412f2bee335e9709a717"

# ASGN Keys (Assignment)
export ASGN_SEED="nephew dignity smoke sunny access soon breeze inch dove park fault museum"
export ASGN_PUBLIC_KEY="0xa4c75d886439ae7d764cc600051af1d2128d2a8a1cdf3d642eda76824ccaf518"

# AUDI Keys (Authority Discovery)
export AUDI_SEED="vicious mixed hour wage clog yellow elbow zoo clock better rhythm diagram"
export AUDI_PUBLIC_KEY="0x66e821a23729878d8b7d04c69ec0fed9b0f5facae48917c1b83a4ad15cf00720"

# BEEF Keys (BEEFY)
export BEEF_SEED="practice cable fog idea rigid hybrid digital snack setup right advance romance"
export BEEF_PUBLIC_KEY="0x0281ba169080b261add0cd22bfb47477eddab854caa17423b12ddeed6504b04aef"

# Validator Configuration
export VALIDATOR_NAME="Validator-beta-1"
export RPC_PORT=9944
export P2P_PORT=30333
export WS_PORT=9944
export PROMETHEUS_PORT=9615
