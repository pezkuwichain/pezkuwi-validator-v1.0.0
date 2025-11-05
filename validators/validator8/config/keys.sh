#!/bin/bash

# ========================================
# Validator 8 - Real Beta Testnet Keys
# ========================================
# Validator Name: Validator-beta-8
# RPC Port: 9951
# P2P Port: 30340

# BABE Keys (Block Authorship)
export BABE_SEED="clinic father over industry blame coast trophy walnut panel giant barely aunt"
export BABE_PUBLIC_KEY="0x520e1de89062667c8980666fd8cc83914d43ce5dd69fa4db2bec7a23bec16e61"

# GRANDPA Keys (Finality)
export GRAN_SEED="invite mule belt fix risk piece grant benefit type park best aisle"
export GRAN_PUBLIC_KEY="0x7bab34ff06d0e24da37e861bc9683381934e390febe05cec2060b5d4b9c8d746"

# PARA Keys (Parachain)
export PARA_SEED="close render flip cable sail drop job drum kiss brief corn wild"
export PARA_PUBLIC_KEY="0x4e169330a7089ffc0be8f85edb9b5c35556bee1a0111f14dc7ee00cd43478232"

# ASGN Keys (Assignment)
export ASGN_SEED="pipe crack swing minimum supply divide tenant solution foil prevent depend wedding"
export ASGN_PUBLIC_KEY="0xdc8556675a56246d3227c4544e58a602df65b154e09086c0b2b0aa879dfab249"

# AUDI Keys (Authority Discovery)
export AUDI_SEED="faint tunnel east jeans raise bundle grief unaware gospel solar dish number"
export AUDI_PUBLIC_KEY="0x1ec224f7441c0f95d817ccbf0cce3d1cdbd0ffb0f8169654672570dbd6e66608"

# BEEF Keys (BEEFY)
export BEEF_SEED="live impact struggle furnace sentence sail true spin waste museum symbol able"
export BEEF_PUBLIC_KEY="0x030bd33780a8a632630c3dd75624c4e6d1ff3fdfa58d88ddebe087e237cc0cd11d"

# Validator Configuration
export VALIDATOR_NAME="Validator-beta-8"
export RPC_PORT=9951
export P2P_PORT=30340
export WS_PORT=9951
export PROMETHEUS_PORT=9622
