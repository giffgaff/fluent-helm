#!/bin/bash

es_endpoint=${es_endpoint:-nil}
index_patterns=${index_patterns}

while [ $# -gt 0 ]; do

   if [[ $1 == *"--"* ]]; then
        param="${1/--/}"
        declare $param="$2"
        # echo $1 $2 // Optional to see the parameter:value result
   fi

  shift
done

echo "Creating 30d_retention policy"
echo ''

## 30 days retention policy
curl -H 'Content-Type: application/json' -XDELETE "https://$es_endpoint/_opendistro/_ism/policies/30d_retention"

curl -H 'Content-Type: application/json' -XPUT "https://$es_endpoint/_opendistro/_ism/policies/30d_retention" -d'
{
  "policy": {
    "description": "30d retention policy",
    "default_state": "hot",
    "states": [
      {
        "name": "hot",
        "actions": [],
        "transitions": [
          {
            "state_name": "delete",
            "conditions": {
              "min_index_age": "30d"
            }
          }
        ]
      },
      {
        "name": "delete",
        "actions": [
          {
            "delete": {}
          }
        ]
      }
    ]
  }
}
'