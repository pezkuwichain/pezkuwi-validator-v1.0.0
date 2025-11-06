#!/bin/bash

# ========================================
# Validator 3 - Real Beta Testnet Keys
# ========================================
# Validator Name: Validator-beta-3
# RPC Port: 9946
# P2P Port: 30335

# BABE Keys (Block Authorship)
export BABE_SEED="cycle judge gentle cute spirit crunch build flee popular cube wagon void"
export BABE_PUBLIC_KEY="0x2825cb78cb345b078a189e6a280916f7771df991113e587b9a0694df33abe909"

# GRANDPA Keys (Finality)
export GRAN_SEED="prefer sugar friend wagon about love blouse coast table future lonely slice"
export GRAN_PUBLIC_KEY="0xcf2862bbfabf42dfc361e2fd0ee860e55e80f093ad767679d9687e822a04c7a4"

# PARA Keys (Parachain)
export PARA_SEED="where reject camp tail clock plate library apple draw once float ranch"
export PARA_PUBLIC_KEY="0x4cdb404f66b7409a6e7fee2eab92aa738c8cbd37d1343b0e0818deb4637d3e0e"

# ASGN Keys (Assignment)
export ASGN_SEED="craft hill receive alarm inner use cereal assume boost castle enhance culture"
export ASGN_PUBLIC_KEY="0xf054e7834c042696fbbf56d17247924836a6957cc6ec8366455c9b459b51fa4d"

# AUDI Keys (Authority Discovery)
export AUDI_SEED="fatal hazard federal cushion cousin spend weapon script boil vicious delay fire"
export AUDI_PUBLIC_KEY="0xd2c4ffc56fd8504f5fde789d3ba895f65c0c7200f68cfe789a4316e68277e72f"

# BEEF Keys (BEEFY)
export BEEF_SEED="kiss foil assist bind duty concert van fold reveal weird design rescue"
export BEEF_PUBLIC_KEY="0x023792b160a004c98d56afc29843ee9aa567a80129794373df9b3f4d883cfd4dfc"

# Validator Configuration
export VALIDATOR_NAME="Validator-beta-3"
export RPC_PORT=9946
export P2P_PORT=30335
export WS_PORT=9946
export PROMETHEUS_PORT=9617
