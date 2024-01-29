#!/bin/bash



#-------------------common constants---------------#
ENV_FOLDER=env


#----------------CENTAURI constants----------------#
CENTAURI=">>>> CENTAURI:"
CENTAURI_CHAIN_DIRECTORY=/Users/viveksharmapoudel/my_work_bench/ibriz/common-repo/composable-cosmos

centaurid_key="mykey"
centaurid_chain_id="centauri-testnet-1"
centaurid_gas_prices="0.1stake"
centaurid_gas_adjustment="1.5"
centaurid_gas="auto"
CENTAURI_NODE="http://127.0.0.1:50001"
WASM_LIGHT_CLIENT_ICS20=./cw_wasm_light_client_icon.wasm


#----------------ICON constants----------------#
ICON=">>> ICON: "
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



IBC_ICON=$CONTRACTS_DIR/$JAVA/ibc/$LIB/ibc-0.1.0-optimized.jar
LIGHT_ICON_COSMWASM=$CONTRACTS_DIR/$JAVA/lightclients/tendermint/$LIB/tendermint-0.1.0-optimized.jar
LIGHT_ICON_ICS20=$CONTRACTS_DIR/$JAVA/lightclients/ics-08-tendermint/$LIB/ics-08-tendermint-0.1.0-optimized.jar
ICS20_APP=$CONTRACTS_DIR_ICS20/$JAVA/modules/ics20app/$LIB/ics20app-0.1.0-optimized.jar
ICS20_BANK=$CONTRACTS_DIR_ICS20/$JAVA/modules/ics20bank/$LIB/ics20bank-0.1.0-optimized.jar
MOCK_ICON=$CONTRACTS_DIR/$JAVA/modules/mockapp/$LIB/mockapp-0.1.0-optimized.jar



# all the contract addresses
ICON_IBC_CONTRACT=./$ICON_CONTRACT_ADDRESS/.ibcHandler
ICON_LIGHT_CLIENT_CONTRACT_ICS20=./$ICON_CONTRACT_ADDRESS/.lightclientIcs20
ICON_LIGHT_CLIENT_CONTRACT_COSMWASM=./$ICON_CONTRACT_ADDRESS/.lightclientCosmwasm
ICON_ICS20_APP_CONTRACT=./$ICON_CONTRACT_ADDRESS/.ics20App
ICON_ICS20_BANK_CONTRACT=./$ICON_CONTRACT_ADDRESS/.ics20Bank
ICON_MOCK_APP_CONTRACT=./$ICON_CONTRACT_ADDRESS/.mockApp

ICON_CHAIN_ID="ibc-icon"


##-------------------------- CosmWasm constants------------##
##---------------------------------------------------------##
WASM_TYPE=archway
WASM_BINARY=archwayd
WASM_NAME=Archway
WASM_FOLDER=archway
WASM_NETWORK_EXTRA="--keyring-backend=test"
WASM_CHAIN_ID=localnet-1
TOKEN=stake
WASM_NODE=http://localhost:26657
WASM_WALLET=localnetWallet
WASM_SLEEP_TIME=5
RELAY_WALLET_NAME=localnetWallet

# cosmwasm contracts
IBC_WASM=$CONTRACTS_DIR/artifacts/archway/cw_ibc_core_latest.wasm
LIGHT_WASM=$CONTRACTS_DIR/artifacts/archway/cw_icon_light_client_latest.wasm
MOCK_WASM=$CONTRACTS_DIR/artifacts/archway/cw_mock_ibc_dapp.wasm

WASM_CONTRACT_FOLDER=$ENV_FOLDER/$WASM_FOLDER
WASM_IBC_CONTRACT=./$WASM_CONTRACT_FOLDER/.ibcHandler
WASM_LIGHT_CLIENT_CONTRACT=./$WASM_CONTRACT_FOLDER/.lightclient
WASM_MOCK_APP_CONTRACT=./$WASM_CONTRACT_FOLDER/.mockapp


##-------------------------- CosmWasm constants------------##
##---------------------------------------------------------##
PORT_ID_ICS20=transfer
DENOM=vsp

PORT_ID_MOCK=mock


function log() {
    echo "=============================================="
}

function separator() {
    echo "----------------------------------------------"
}