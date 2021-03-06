#!/bin/bash

set -x

CLI=gaiacli
CHAIN=game_of_stakes_6
VAL=cosmosvaloper16vgxx4302kcpw2z98a555w5lj5etnwsjr9cj2j
ADDRESS=cosmos16vgxx4302kcpw2z98a555w5lj5etnwsjx3v8xp
ACCOUNT=qos
DELAY=15

echo "Enter your key password:"
read -s password

while true
do
    steak=$($CLI query distr commission $VAL --output json --trust-node=true|jq -r '.[]|select(.denom | contains ("stake"))|.amount/"."|.[0]')
    sequence=$($CLI query account $ADDRESS --chain-id=$CHAIN --trust-node=true --output json| jq -r '.value.BaseVestingAccount.BaseAccount.sequence')
    amount_steak=$($CLI query account $ADDRESS --chain-id=$CHAIN --trust-node=true --output json|jq -r '.value.BaseVestingAccount.BaseAccount.coins|.[]|select(.denom | contains ("stake"))|.amount/"."|.[0]')
    if [[ $amount_steak -gt 0 && $amount_steak != "null" ]]; then
       echo "About to stake ${amount_steak} steak"
       steak=`echo $amount_steak + $steak| bc`
    fi
    echo "${password}" | $CLI tx staking withdraw-delegate --from $ACCOUNT --amount ${steak}stake --chain-id $CHAIN --fees 210000photinos --memo zz --async --sequence $sequence
date
echo "--------------------------------"
sleep $DELAY
done
