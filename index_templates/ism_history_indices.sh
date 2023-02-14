


#!/bin/bash

es_endpoint=${es_endpoint:-nil}
shards=${shards:-1}
replicas=${replicas:-1}
policy_id=${policy_id:-30d_retention}


while [ $# -gt 0 ]; do

   if [[ $1 == *"--"* ]]; then
        param="${1/--/}"
        declare $param="$2"
        # echo $1 $2 // Optional to see the parameter:value result
   fi

  shift
done

echo "Creating ism-history-indices index template with $shards shards, $replicas replicas and policy_id $policy_id"
echo ''

## ism-history-indices template
curl -H 'Content-Type: application/json' -XPUT "https://$es_endpoint/_template/ism-history-indices" -d'
{
    "index_patterns" : [
      ".opendistro-ism-managed-index-history-*"
    ],
    "settings" : {
      "number_of_shards": '$shards',
      "number_of_replicas": '$replicas'
    }
}
'
