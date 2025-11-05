#!/bin/bash

# ========================================
# Validator 6 - Real Beta Testnet Keys
# ========================================
# Validator Name: Validator-beta-6
# RPC Port: 9949
# P2P Port: 30338

# BABE Keys (Block Authorship)
export BABE_SEED="tired youth educate hover cross plastic gate giraffe gorilla rescue section idle"
export BABE_PUBLIC_KEY="0xf4fc5deb49aa9178f622e711a9d453d967507231a6e2d62d726ce7279316970a"

# GRANDPA Keys (Finality)
export GRAN_SEED="hedgehog isolate jump safe march fame year mosquito smooth lunch portion solution"
export GRAN_PUBLIC_KEY="0x7eb7cfb7ac00f11ed7f63697cdb5d0562bba6b90c1901fa00365db075bab05e9"

# PARA Keys (Parachain)
export PARA_SEED="industry thank parade tiger reunion usual kidney high beef divide jaguar smile"
export PARA_PUBLIC_KEY="0x5a3fa17b77d3afc3dd1e0b7bf1d2faf95ba14eb2ee370476e5f2f78a8175a957"

# ASGN Keys (Assignment)
export ASGN_SEED="cluster outdoor denial disorder donor rich senior glance display barrel theory pupil"
export ASGN_PUBLIC_KEY="0x4e232e6efb3be2c4f638fac57330f606fc54bbc3b8d490a5bb520c67c0d7f248"

# AUDI Keys (Authority Discovery)
export AUDI_SEED="supreme warfare trust assault where model grain advice broccoli nothing key embody"
export AUDI_PUBLIC_KEY="0x244d0ea5c6b4a4f4e23912aab77498689e9f355edb63a82ebfc9b9bb08176f0d"

# BEEF Keys (BEEFY)
export BEEF_SEED="cloth lock grocery actor trend patch grace salad fun mass plate notice"
export BEEF_PUBLIC_KEY="0x0338f2ef200a5048b35fcfae936a2dd5dffdabc77eb61d707de35f9eba8b3d37e3"

# Validator Configuration
export VALIDATOR_NAME="Validator-beta-6"
export RPC_PORT=9949
export P2P_PORT=30338
export WS_PORT=9949
export PROMETHEUS_PORT=9620
