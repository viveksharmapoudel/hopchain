#!/bin/bash


#----------------CENTAURI constants----------------#
CENTAURI_CHAIN_DIRECTORY=/Users/viveksharmapoudel/my_work_bench/ibriz/common-repo/composable-cosmos

centaurid_key="mykey"
centaurid_chain_id="centauri-testnet-1"
centaurid_gas_prices="0.1stake"
centaurid_gas_adjustment="1.5"
centaurid_gas="auto"
CENTAURI_NODE="http://127.0.0.1:50001"


#--------------------------------------------------#





#-----------------ARCHWAY constants-------------#


WASM_LIGHT_CLIENT=./cw_wasm_light_client_icon.wasm
# WASM_LIGHT_CLIENT=/Users/viveksharmapoudel/my_work_bench/ibriz/common-repo/notional-lab-ibc-go/modules/light-clients/08-wasm/types/test_data/ics07_tendermint_cw.wasm.gz




#--------ICON constant--------#

ICON=">>> ICON: "
ENV_FOLDER=env
ICON_CONTRACT_ADDRESS=$ENV_FOLDER/icon
CONTRACTS_DIR_ICS20=/Users/viveksharmapoudel/my_work_bench/ibriz/ibc-related/sudeep-fork/IBC-Integration
CONTRACTS_DIR=/Users/viveksharmapoudel/my_work_bench/ibriz/ibc-related/ibc-integration
JAVA=contracts/javascore
LIB=build/libs



ICON_WALLET=icon_godWallet.json
ICON_WALLET_PASSWORD=gochain
MINTER_WALLET=icon_minter.json
MINTER_WALLET_PASSWORD=gochain
ICON_NETWORK_ID=0x3
# BTP enabled node must be started.
ICON_NODE=http://localhost:9082/api/v3/
ICON_NODE_DEBUG=http://localhost:9082/api/v3d

ICON_DOCKER_PATH=$HOME/gochain-btp


IBC_ICON=$CONTRACTS_DIR/$JAVA/ibc/$LIB/ibc-0.1.0-optimized.jar
LIGHT_ICON=$CONTRACTS_DIR/$JAVA/lightclients/tendermint/$LIB/tendermint-0.1.0-optimized.jar
LIGHT_ICON_ICS20=$CONTRACTS_DIR/$JAVA/lightclients/ics-08-tendermint/$LIB/ics-08-tendermint-0.1.0-optimized.jar
ICS20_APP=$CONTRACTS_DIR_ICS20/$JAVA/modules/ics20app/$LIB/ics20app-0.1.0-optimized.jar
ICS20_BANK=$CONTRACTS_DIR_ICS20/$JAVA/modules/ics20bank/$LIB/ics20bank-0.1.0-optimized.jar


#other
# BTP_NETWORK_ID_FILE=./$ENV_FOLDER/.btpNetworkId
# BTP_NETWORK_ID=$(cat $BTP_NETWORK_ID_FILE)

# all the contract addresses
ICON_IBC_CONTRACT=./$ICON_CONTRACT_ADDRESS/.ibcHandler
ICON_LIGHT_CLIENT_CONTRACT=./$ICON_CONTRACT_ADDRESS/.lightclient
ICON_LIGHT_CLIENT_CONTRACT_COSMWASM=./$ICON_CONTRACT_ADDRESS/.lightclientcosmwasm
ICON_ICS20_APP_CONTRACT=./$ICON_CONTRACT_ADDRESS/.ics20App
ICON_ICS20_BANK_CONTRACT=./$ICON_CONTRACT_ADDRESS/.ics20Bank



export ICON_NODE_FILE=/Users/viveksharmapoudel/my_work_bench/ibriz/btp-related/gochain-btp
ICON_CHAIN_ID="ibc-icon"

#common env 
CURRENT_PORT_ID=./$ENV_FOLDER/.portId
DENOM=vsp



function log() {
    echo "=============================================="
}

function separator() {
    echo "----------------------------------------------"
}