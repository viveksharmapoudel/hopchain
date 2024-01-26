#!/bin/bash

source const.sh


tx_call_args_icon_common=" --uri $ICON_NODE  --nid $ICON_NETWORK_ID  --step_limit 100000000000 --key_store $ICON_WALLET --key_password $ICON_WALLET_PASSWORD "

function printDebugTrace() {
	local txHash=$1
	goloop debug trace --uri $ICON_NODE_DEBUG $txHash | jq -r .
}

function wait_for_it() {
	local txHash=$1
	echo "Txn Hash: "$1
	
	status=$(goloop rpc txresult --uri $ICON_NODE $txHash | jq -r .status)
	if [ $status == "0x1" ]; then
    	echo "Successful"
    else
    	echo $status
    	read -p "Print debug trace? [y/N]: " proceed
    	if [[ $proceed == "y" ]]; then
    		printDebugTrace $txHash
    	fi
    	exit 0
    fi
}

function openBTPNetwork() {
	echo "$ICON Opening BTP Network of type eth"

	local name=$1
	local owner=$2

	local txHash=$(goloop rpc sendtx call \
	    --to cx0000000000000000000000000000000000000001 \
	    --method openBTPNetwork \
	    --param networkTypeName=eth \
	    --param name=$name \
	    --param owner=$owner \
		$tx_call_args_icon_common | jq -r .)
	sleep 6
	wait_for_it $txHash
}

function deployIBCHandler() {
	echo "$ICON Deploy IBCHandler"

	local txHash=$(goloop rpc sendtx deploy $IBC_ICON \
			--content_type application/java \
			--to cx0000000000000000000000000000000000000000 \
			$tx_call_args_icon_common | jq -r .)


	sleep 6
	wait_for_it $txHash
	scoreAddr=$(goloop rpc txresult --uri $ICON_NODE $txHash | jq -r .scoreAddress)
	echo $scoreAddr > $ICON_IBC_CONTRACT
}


function deployICS20App() {
	echo "$ICON deploy ics20App"
	local ibcHandler=$1
    local ibcBank=$2
	local filename=$ICON_ICS20_APP_CONTRACT

	local txHash=$(goloop rpc sendtx deploy $ICS20_APP \
			--content_type application/java \
			--to cx0000000000000000000000000000000000000000 \
            --param _ibcHandler=$ibcHandler \
			--param _bank=$ibcBank \
			$tx_call_args_icon_common| jq -r .)

    sleep 6
	wait_for_it $txHash
	scoreAddr=$(goloop rpc txresult --uri $ICON_NODE $txHash | jq -r .scoreAddress)
	echo $scoreAddr > $filename
}

function deployICS20Bank(){
    echo "$ICON deploy ics20 bank"

    local filename=$ICON_ICS20_BANK_CONTRACT

    local txHash=$(goloop rpc sendtx deploy $ICS20_BANK \
		--content_type application/java \
		--to cx0000000000000000000000000000000000000000 \
		$tx_call_args_icon_common| jq -r .)
    sleep 6
	wait_for_it $txHash
	scoreAddr=$(goloop rpc txresult --uri $ICON_NODE $txHash | jq -r .scoreAddress)
	echo $scoreAddr > $filename

}


function deployLightClient() {
	echo "$ICON Deploy Tendermint Light Client"
	local filename=$ICON_LIGHT_CLIENT_CONTRACT
	local ibcHandler=$1

	local txHash=$(goloop rpc sendtx deploy $LIGHT_ICON_ICS20 \
			--content_type application/java \
			--to cx0000000000000000000000000000000000000000 \
            --param ibcHandler=$ibcHandler \
			$tx_call_args_icon_common| jq -r .)
    sleep 6
	wait_for_it $txHash
	scoreAddr=$(goloop rpc txresult --uri $ICON_NODE $txHash | jq -r .scoreAddress)
	echo $scoreAddr > $filename
}

function registerClient() {
    echo "$ICON Register Tendermint Light Client"
    local toContract=$1
    local clientAddr=$2

    local txHash=$(goloop rpc sendtx call \
	    --to $toContract\
	    --method registerClient \
	    --param clientType="ics08-tendermint" \
		--param hashType=1 \
	    --param client=$clientAddr \
		$tx_call_args_icon_common | jq -r .)
    sleep 6
    wait_for_it $txHash
}



function bindPort() {
    echo "$ICON Bind module to a port"
    local toContract=$1
    local portId=$2
    local mockAppAddr=$3

    local txHash=$(goloop rpc sendtx call \
	    --to $toContract\
	    --method bindPort \
	    --param moduleAddress=$mockAppAddr \
	    --param portId=$portId \
		$tx_call_args_icon_common | jq -r .)
    sleep 6
    wait_for_it $txHash
}


function setupICS20(){

    echo "$ICON  setup ics20 complete"

    local ibcHandler=$1

    #deploy ics20bank
    deployICS20Bank

    local ics20BankAddress=$(cat $ICON_ICS20_BANK_CONTRACT)

    echo "ics20 address is "$ics20BankAddress

    #deploy ics20App
    deployICS20App $ibcHandler $ics20BankAddress
	readyICS20App

}




function readyICS20App(){

    local ics20BankAddress=$(cat $ICON_ICS20_BANK_CONTRACT)
	local ics20AppAddress=$(cat $ICON_ICS20_APP_CONTRACT)

	echo "setupOperator Ics20App"
	local txHash=$(goloop rpc sendtx call \
	    --to $ics20BankAddress\
	    --method setupOperator \
	    --raw "{\"params\":{\"account\":\"$ics20AppAddress\"}}" \
		$tx_call_args_icon_common | jq -r .)
    sleep 2
    wait_for_it $txHash


	local minterAddress=$(cat $MINTER_WALLET | jq -r ' .address')

	local godWalletAddress=$(cat $ICON_WALLET | jq -r ' .address')

	echo "setupOperator minterWallet"
	local txHash=$(goloop rpc sendtx call \
	    --to $ics20BankAddress\
	    --method setupOperator \
	    --raw "{\"params\":{\"account\":\"$minterAddress\"}}" \
		$tx_call_args_icon_common | jq -r .)
    sleep 2
    wait_for_it $txHash



	# balance transfer the minterWallet 
	echo "mint to godWallet"
	local txHash=$(goloop rpc sendtx call \
	    --to $ics20BankAddress\
		--method mint \
        --param account=$godWalletAddress \
        --param denom=$DENOM \
        --param amount="10000000000000000" \
		--uri $ICON_NODE  --nid $ICON_NETWORK_ID  --step_limit 1000000000 --key_store $MINTER_WALLET --key_password $MINTER_WALLET_PASSWORD | jq -r .)

    sleep 4
    wait_for_it $txHash


	echo "mint to ics20App"
		local txHash=$(goloop rpc sendtx call \
	    --to $ics20BankAddress\
		--method mint \
        --param account=$ics20AppAddress \
        --param denom=$DENOM \
        --param amount="10000000000000000" \
		--uri $ICON_NODE  --nid $ICON_NETWORK_ID  --step_limit 1000000000 --key_store $MINTER_WALLET --key_password $MINTER_WALLET_PASSWORD | jq -r .)
    sleep 4
    wait_for_it $txHash
}


function callSendToken(){

	local ics20AppAddress=$(cat $ICON_ICS20_APP_CONTRACT)

	local centauriKeyAddress=$(centaurid keys list --output json | jq -r '.[] | select(.name == "mykey") | .address')

	local txHash=$(goloop rpc sendtx call \
	    --to $ics20AppAddress \
		--method sendTransfer \
		--param denom=$DENOM \
        --param receiver=$centauriKeyAddress \
        --param amount="950000000000" \
        --param sourcePort="transfer" \
        --param sourceChannel="channel-0" \
        --param timeoutHeight=5000000 \
        --param timeoutRevisionNumber=1 \
		--uri $ICON_NODE  --nid $ICON_NETWORK_ID  --step_limit 100000000000 --key_store $ICON_WALLET --key_password $ICON_WALLET_PASSWORD | jq -r .)

	# echo $query
	# local txHash=$($query)
    sleep 2
    wait_for_it $txHash

}

function deployCosmwasmLightClient(){

	echo "$ICON Deploy Tendermint Light Client"
	local filename=$ICON_LIGHT_CLIENT_CONTRACT_COSMWASM
	local ibcHandler=$(cat $ICON_IBC_CONTRACT)

	local txHash=$(goloop rpc sendtx deploy $LIGHT_ICON_ICS20 \
			--content_type application/java \
			--to cx0000000000000000000000000000000000000000 \
            --param ibcHandler=$ibcHandler \
			$tx_call_args_icon_common| jq -r .)
    sleep 6
	wait_for_it $txHash
	scoreAddr=$(goloop rpc txresult --uri $ICON_NODE $txHash | jq -r .scoreAddress)
	echo $scoreAddr > $filename


    separator
	local txHash=$(goloop rpc sendtx call \
	    --to $ibcHandler\
	    --method registerClient \
	    --param clientType="ics08-tendermint" \
	    --param client=$scoreAddr \
		--param hashType=1 \
		$tx_call_args_icon_common | jq -r .)
    sleep 6
    wait_for_it $txHash
    separator

}

########## ENTRYPOINTS ###############

usage() {
    echo "Usage: $0 []"
    exit 1
}

if [ $# -ge 1 ]; then
	# create folder if not exists
	if [ ! -d $CONTRACT_ADDRESSES_FOLDER/icon ]; then
		mkdir -p env/icon
	fi

    CMD=$1
	shift
else
    usage
fi


function setup() {
    log

    deployIBCHandler
    echo "$ICON IBC Contract deployed at address:"
    local ibcHandler=$(cat $ICON_IBC_CONTRACT)
    echo $ibcHandler

    separator
    openBTPNetwork eth $ibcHandler

    separator
    deployLightClient $ibcHandler
    echo "$ICON TM client deployed at address:"
    local tmClient=$(cat $ICON_LIGHT_CLIENT_CONTRACT)
    echo $tmClient   

    separator
    registerClient $ibcHandler $tmClient

    separator

	setupICS20 $ibcHandler 
    
	separator
	local port_id=$(cat $CURRENT_PORT_ID)
	local ics20_addr=$(cat $ICON_ICS20_APP_CONTRACT)
	bindPort $ibcHandler $port_id $ics20_addr
	separator
	log

}


case "$CMD" in
  setup )
    setup
  ;;
  ready-ics20 ) 
   readyICS20App
  ;;
  deploy-cosmwasm-light-client ) 
	deployCosmwasmLightClient
  ;;
  send-token )
	callSendToken
  ;;

  * )
    echo "Error: unknown command: $CMD"
    usage
esac




