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

  local tx="centaurid tx 08-wasm push-wasm $WASM_LIGHT_CLIENT \
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
    * )
    echo "invalid cmd" $CMD
esac





