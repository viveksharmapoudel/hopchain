#!/bin/bash

source const.sh



fee_price=0.02$TOKEN
case $WASM_TYPE in 
    "archway" )
    fee_price=$($WASM_BINARY q rewards estimate-fees 1 --node $WASM_NODE --output json | jq -r '.gas_unit_price | (.amount + .denom)')
    tx_call_args="--from $WASM_WALLET  --node $WASM_NODE --chain-id $WASM_CHAIN_ID $WASM_NETWORK_EXTRA --gas-prices $fee_price --gas auto --gas-adjustment 1.5 "
    ;;
    "neutron" )
    tx_call_args="--from $WASM_WALLET  --node $WASM_NODE --chain-id $WASM_CHAIN_ID $WASM_NETWORK_EXTRA --gas-prices $fee_price --gas auto --gas-adjustment 1.5 "
    ;;
esac


function deployContract() {

    local contactFile=$1
    local init=$2
    local contractAddr=$3
    echo "$WASM Deploying" $contactFile " and save to " $contractAddr

    local op="$WASM_BINARY tx wasm store $contactFile $tx_call_args   -y --output json "
    local txHash=$($op | jq -r ".txhash")
    sleep $WASM_SLEEP_TIME

    local code_id=$($WASM_BINARY query tx $txHash --node $WASM_NODE  --output json | jq -r '.logs[0].events[] | select(.type=="store_code") | .attributes[] | select(.key=="code_id") | .value')
    echo "code id: " $code_id

    local addr=$($WASM_BINARY keys show $WASM_WALLET $WASM_NETWORK_EXTRA --output=json | jq -r .address)

    op="$WASM_BINARY tx wasm instantiate $code_id $init $tx_call_args --label "archway-contract" --admin $addr -y"
    echo "tx wasm inntantiate command is " $op

    local res=$($op)
    log

    echo "sleep for $WASM_SLEEP_TIME seconds"
    log
    sleep $WASM_SLEEP_TIME

    CONTRACT=$($WASM_BINARY query wasm list-contract-by-code $code_id --node $WASM_NODE --output json | jq -r '.contracts[-1]')
    echo "$WASM IBC Contract Deployed at address"
    echo $CONTRACT
    echo $CONTRACT >$contractAddr
}


function migrateContract() {

    local contactFile=$1
    local contractAddr=$2
    local migrate_arg=$3

    echo "$WASM Migrating" $contactFile "to " $contractAddr " with args " $migrate_arg

    local res=$($WASM_BINARY tx wasm store $contactFile $tx_call_args -y --output json -b block)


    local code_id=$(echo $res | jq -r '.logs[0].events[] | select(.type=="store_code") | .attributes[] | select(.key=="code_id") | .value')
    echo "code id: " $code_id


    local res=$($WASM_BINARY tx wasm migrate $contractAddr $code_id $migrate_arg $tx_call_args -y)

    sleep $WASM_SLEEP_TIME
    echo "this is the result" $res
    log

}


function deployMock() {
    local ibc_addr=$1
    local mock_addr_filename=$2
    local port_id=$3
    local init="{\"ibc_host\":\"$ibc_addr\"}"

    # sleep 5
    deployContract $MOCK_WASM $init $mock_addr_filename
    separator
    

    local mock_app_address=$(cat $mock_addr_filename)

    local bind_port_args="{\"bind_port\":{\"port_id\":\"$port_id\",\"address\":\"$mock_app_address\"}}"
    local res=$($WASM_BINARY tx wasm execute $ibc_addr $bind_port_args $tx_call_args -y)

    sleep 2
    echo $res
    separator

}


function deployIBC(){
    echo "deploy IBC contract "
    init="{}"
    deployContract $IBC_WASM $init $WASM_IBC_CONTRACT

}

function deployLightClient() {
    echo "To deploy light client"
    local ibcAddress=$(cat $WASM_IBC_CONTRACT)
    local init="{\"ibc_host\":\"$ibcAddress\"}"
    deployContract $LIGHT_WASM $init $WASM_LIGHT_CLIENT_CONTRACT

    local lightClientAddress=$(cat $WASM_LIGHT_CLIENT_CONTRACT)
    local ibcContract=$1
    separator

    echo "$WASM Register iconclient to IBC Contract"

    registerClient="{\"register_client\":{\"client_type\":\"iconclient\",\"client_address\":\"$lightClientAddress\"}}"
    local res=$($WASM_BINARY tx wasm execute $ibcContract $registerClient $tx_call_args -y)

    sleep 5
    echo $res
    separator
}

function buildContracts() {
    cd $CONTRACTS_DIR
    ./optimize_build.sh
    cp -r $CONTRACTS_DIR/artifacts/cw_ibc_core.wasm $SCRIPTS_DIR/artifacts
    cp -r $CONTRACTS_DIR/artifacts/cw_icon_light_client.wasm $SCRIPTS_DIR/artifacts
}



function callMockContract(){

    local addr=$(cat $WASM_MOCK_APP_CONTRACT)

    local wallet=$1

    local sendMessage="{\"send_message\":{\"timeout_height\":100000000,\"msg\":[123,100,95,112,97]}}"
    local tx_call="$WASM_BINARY tx wasm execute $addr $sendMessage --from $wallet  --node $WASM_NODE --chain-id $WASM_CHAIN_ID $WASM_NETWORK_EXTRA --gas-prices $fee_price --gas auto --gas-adjustment 1.5  -y"
    echo "call command: " $tx_call

    local res=$($tx_call)

    # sleep 2
    echo $res
    separator
}




function updateContract() {
    local contract_type=$1
    echo  $WASM "updating: " $1
    separator

    local params="{}"

    echo "contract type " $contract_type

    case $contract_type in 

        ibc )
            params="{\"clear_store\":false}"
            migrateContract $IBC_WASM $(cat $WASM_IBC_CONTRACT) $params
        ;;

        light )
            migrateContract $LIGHT_WASM $(cat $WASM_LIGHT_CLIENT_CONTRACT) $params
        ;;

        mock )
            migrateContract $MOCK_WASM $(cat $WASM_MOCK_APP_CONTRACT) $params
        ;;

        * )
            echo "Error: unknown contract:" $contract_type
        ;;
esac

}

function setup() {

    deployIBC
    local ibcContract=$(cat $WASM_IBC_CONTRACT)
    deployLightClient $ibcContract
    echo "$WASM_TYPE the mock id is " $PORT_ID_MOCK
    deployMock $ibcContract $WASM_MOCK_APP_CONTRACT $PORT_ID_MOCK
}

########## ENTRYPOINTS ###############

usage() {
    echo "Usage: $0 []"
    exit 1
}

if [ $# -ge 1 ]; then
	# create folder if not exists
	if [ ! -d $WASM_CONTRACT_FOLDER ]; then
		mkdir -p $WASM_CONTRACT_FOLDER
	fi

    CMD=$1
	shift
else
    usage
fi


case "$CMD" in
setup)
    setup
    ;;
update )
    updateContract $1
    ;;
test-call ) 
    callMockContract $WASM_WALLET
    ;;

*)
    echo "Error: unknown command: $CMD"
    usage
    ;;
esac