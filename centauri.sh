#!/bin/bash


source const.sh

centaurid_key="mykey"
centaurid_chain_id="centauri-testnet-1"
centaurid_gas_prices="0.1stake"
centaurid_gas_adjustment="1.5"
centaurid_gas="auto"
CENTAURI_NODE="http://127.0.0.1:50001"



function chainStart(){
    
    # make install
    ./centauri-testnode.sh    
}


function deployWasm() {

  local tx="centaurid tx 08-wasm push-wasm $WASM_LIGHT_CLIENT_ICS20 \
--chain-id $centaurid_chain_id  \
--from $centaurid_key \
--node $CENTAURI_NODE \
--gas-prices $centaurid_gas_prices \
--gas-adjustment $centaurid_gas_adjustment \
--gas $centaurid_gas -y"
  echo $tx
  local output=$($tx)
  echo $output
  sleep 4


  #just for when running locally 
  local key_address=$(centaurid keys list --output json | jq -r '.[] | select(.name == "mykey") | .address')
  tx="centaurid tx transmiddleware  add-rly \
    $key_address --from $centaurid_key \
    --node $CENTAURI_NODE \
    --chain-id $centaurid_chain_id -y"
  output=$($tx)
  echo $output
  sleep 2
}


function transferToken (){

local transaction="centaurid tx ibc-transfer transfer transfer channel-1 hxb6b5791be0b5ef67063b3c10b840fb81514db2fd 95000000ibc/7B5CC83B4CDF78974694E6000E3C5C07AFA7C32CDB98FA365E5C9E4F9B59CEAA \
--packet-timeout-height 1-500000 \
--packet-timeout-timestamp 0 \
--chain-id $centaurid_chain_id  \
--from $centaurid_key \
--gas-prices 0.1stake \
--gas-adjustment 1.5 \
--gas auto --output json -y"
op=$($transaction)
echo $op

local txHash=$(op | .jq ".txhash")
sleep 4
echo $txHash
local op=$(centaurid query tx $txHash --node $centaurid_chain_id )


}

function submitProposal(){

  centaurid tx gov submit-proposal draft_proposal_wasm_add.json \
--chain-id centauri-testnet-1  \
--from mykey \
--node http://127.0.0.1:50001 \
--gas-prices 0.1stake  \
--gas-adjustment 1.5 \
--gas auto -y
}


function voteProposal(){

centaurid tx gov vote 1 yes  \
--chain-id centauri-testnet-1  \
--from mykey \
--node http://127.0.0.1:50001 \
--gas-prices 0.1stake  \
--gas-adjustment 1.5 \
--gas auto -y


}

# function depositProposal(){

#   centauri tx gov deposit 1 10000010stake \
# --chain-id centauri-testnet-1  \
# --from mykey \
# --node http://127.0.0.1:50001 \
# --gas-prices 0.1stake  \
# --gas-adjustment 1.5 \
# --gas auto -y

# }



if [ $# -ge 1 ]; then
    CMD=$1
    shift
else
    echo "invalid arguments"
fi


case "$CMD" in 

    chain-start )
    chainStart
    ;;
    deploy-wasm ) 
    deployWasm
    ;;
    
    transfer-token ) 
     transferToken
    ;;

    * )
    echo "invalid cmd" $CMD
esac





