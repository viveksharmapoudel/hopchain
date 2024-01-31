#!/bin/bash

source const.sh
YAML_FILE=$HOME/.relayer/config/config.yaml
BACKUP_YAML_FILE=$HOME/.relayer/config/config_backup_test.yaml

archwayIBC=$(cat $WASM_IBC_CONTRACT)
iconIBC=$(cat $ICON_IBC_CONTRACT)



lastNetworkId=$(goloop rpc --uri $ICON_NODE btpnetworktype 0x01 | jq ".openNetworkIDs| last" | sed 's/"//g' )
decimalLastNetworkId=$(printf "%d" "$lastNetworkId")
ownerLastNetworkId=$(goloop rpc --uri $ICON_NODE btpnetwork $decimalLastNetworkId | jq ".owner"  | sed 's/"//g')



if [[ "$ownerLastNetworkId" != "$iconIBC" ]]; then
    echo "Ibchandler address and last btpNetwork id doesn't match couldn't update"
    exit 1
fi

echo "Current BTP Network is: " $decimalLastNetworkId

echo "Updating relay config file "

cp $YAML_FILE $BACKUP_YAML_FILE
rm $YAML_FILE

cat <<EOF >> $YAML_FILE
global:
    api-listen-addr: :5183
    timeout: 10s
    memo: ""
    light-cache-size: 20
chains:
    centauri:
        type: cosmos
        value:
            key-directory: $HOME/.relayer/keys/$centaurid_chain_id
            key: default
            chain-id: $centaurid_chain_id
            rpc-addr: $CENTAURI_NODE
            account-prefix: centauri
            keyring-backend: test
            gas-adjustment: 1.2
            gas-prices: 0.01stake
            min-gas-amount: 1000000
            max-gas-amount: 0
            debug: false
            timeout: 20s
            block-timeout: ""
            output-format: json
            sign-mode: direct
            extra-codecs: []
            coin-type: null
            signing-algorithm: ""
            broadcast-mode: batch
            min-loop-duration: 0s
    icon:
        type: icon
        value:
            key-directory: $HOME/.relayer/keys
            chain-id: $ICON_CHAIN_ID
            rpc-addr: $ICON_NODE
            timeout: 30s
            keystore: godwallet
            password: gochain
            icon-network-id: 3
            btp-network-id: $lastNetworkId
            btp-network-type-id: 1
            start-height: 0
            ibc-handler-address: $iconIBC
            first-retry-block-after: 0
            block-interval: 1000
            revision-number: 0
    archway:
        type: wasm
        value:
            key-directory: $HOME/.relayer/keys/$WASM_CHAIN_ID
            key: $RELAY_WALLET_NAME
            chain-id: $WASM_CHAIN_ID
            rpc-addr: $WASM_NODE
            account-prefix: $WASM_TYPE
            keyring-backend: test
            gas-adjustment: 1.5
            gas-prices: 0.02$TOKEN
            min-gas-amount: 1000000000
            debug: true
            timeout: 20s
            block-timeout: ""
            output-format: json
            sign-mode: direct
            extra-codecs: []
            coin-type: 0
            broadcast-mode: batch
            ibc-handler-address: $archwayIBC
            first-retry-block-after: 0
            start-height: 0
            block-interval: 4000
paths:
    centauri-icon:
        src:
            chain-id: $centaurid_chain_id
        dst:
            chain-id: $ICON_CHAIN_ID
        src-channel-filter:
            rule: ""
            channel-list: []
    icon-archway:
        src:
            chain-id: $ICON_CHAIN_ID
        dst:
            chain-id: $WASM_CHAIN_ID
        src-channel-filter:
            rule: ""
            channel-list: []

