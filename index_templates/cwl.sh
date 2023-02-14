#!/bin/bash

es_endpoint=${es_endpoint:-nil}
shards=${shards:-4}
fields_limit=${fields_limit:-2500}


while [ $# -gt 0 ]; do

   if [[ $1 == *"--"* ]]; then
        param="${1/--/}"
        declare $param="$2"
        # echo $1 $2 // Optional to see the parameter:value result
   fi

  shift
done

echo "Creating cwl index template with $shards shards, $fields_limit fields limit, and 90d retention"
echo ''
## kube-events template
curl -H 'Content-Type: application/json' -XPUT "https://$es_endpoint/_template/cwl" -d'
{
    "index_patterns" : ["cwl-*"],
    "settings" : {
        "index.mapping.total_fields.limit" : '$fields_limit',
        "number_of_shards": '$shards'
    }
}
'