#!/bin/bash

# ========================================
# Validator 7 - Real Beta Testnet Keys
# ========================================
# Validator Name: Validator-beta-7
# RPC Port: 9950
# P2P Port: 30339

# BABE Keys (Block Authorship)
export BABE_SEED="pave mixed faith vivid nice trust exercise public kind afford fury army"
export BABE_PUBLIC_KEY="0x6898b08fe0c6dfe79750598765efe06cbfaef01da9b110599d05a5b4824ddf38"

# GRANDPA Keys (Finality)
export GRAN_SEED="cliff entire pause adjust parent tissue enhance weasel east pink art meat"
export GRAN_PUBLIC_KEY="0x57f18c1620086209773c6d8243af3eae873a63cda0c64cc3bcb02ff3ee41a863"

# PARA Keys (Parachain)
export PARA_SEED="return diet teach excess under warm veteran pride exotic talk exhaust mobile"
export PARA_PUBLIC_KEY="0x1e0ee1b33614379148cd69bb79fb2d21c98a8837bab912e96b72e5a2bbb46d01"

# ASGN Keys (Assignment)
export ASGN_SEED="gown differ atom rebuild observe museum word nest upset large boring exact"
export ASGN_PUBLIC_KEY="0x48f66d8b963b576da719b2350a0242c624b720439ed764c206107647d8a6d872"

# AUDI Keys (Authority Discovery)
export AUDI_SEED="artwork town pyramid stumble sugar neither clutch void soon wine slab slide"
export AUDI_PUBLIC_KEY="0xe462edbb26c14d1772570ce751ace21b271b0f0f472fc434c84f708b9bb42309"

# BEEF Keys (BEEFY)
export BEEF_SEED="curious abstract home session famous canvas spin forest wing appear warm install"
export BEEF_PUBLIC_KEY="0x03e783496d6ff583a60ec44ef9fe7ea375c9e31841a1f7fe48a8eaec0093826d78"

# Validator Configuration
export VALIDATOR_NAME="Validator-beta-7"
export RPC_PORT=9950
export P2P_PORT=30339
export WS_PORT=9950
export PROMETHEUS_PORT=9621
