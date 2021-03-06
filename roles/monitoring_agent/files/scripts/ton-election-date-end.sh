#!/bin/bash -eE

# export ton environments
. ton-env.sh

ton-check-env.sh TON_CLI
ton-check-env.sh TON_CLI_CONFIG



# get elector address
ELECTOR_ADDR="-1:$($TON_CLI -c $TON_CLI_CONFIG  getconfig 1 | grep 'p1:' | sed 's/Config p1:[[:space:]]*//g' | tr -d \")"

# get elector start (unixtime)
ELECTIONS_START=$($TON_CLI -c $TON_CLI_CONFIG runget $ELECTOR_ADDR active_election_id  | grep 'Result:' | sed 's/Result:[[:space:]]*//g' | tr -d \"[])
## hotfix try to use new solidity contract for rustnet.ton.dev
if [ -z $ELECTIONS_START ]; then

   ELECTION_RESULT=`$TON_CLI -c $TON_CLI_CONFIG run $ELECTOR_ADDR active_election_id {} --abi $TON_CONTRACT_ELECTOR_ABI`
   ELECTIONS_START=$(echo $ELECTION_RESULT | awk -F'Result: ' '{print $2}' | jq -r '.value0'  )
fi


if (( $ELECTIONS_START == 0 ));then
   echo "-1";
   exit 0;
fi

ELECTOR_CONFIG=`$TON_CLI -c $TON_CLI_CONFIG getconfig 15` 
ELECTOR_CONFIG_JSON=$(echo $ELECTOR_CONFIG | awk '{split($0, a, "p15:"); print a[2]}')
ELECTOR_CONFIG_ELECTIONS_END_BEFORE=`echo "$ELECTOR_CONFIG_JSON" | jq ".elections_end_before"`

echo $(($ELECTIONS_START - $ELECTOR_CONFIG_ELECTIONS_END_BEFORE))

