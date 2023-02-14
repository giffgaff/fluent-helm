#!/bin/bash

es_endpoint=${es_endpoint:-nil}

while [ $# -gt 0 ]; do

   if [[ $1 == *"--"* ]]; then
        param="${1/--/}"
        declare $param="$2"
        # echo $1 $2 // Optional to see the parameter:value result
   fi

  shift
done

echo "Creating 90d_retention policy"
echo ''

## 90 days retention policy
curl -H 'Content-Type: application/json' -XDELETE "https://$es_endpoint/_opendistro/_ism/policies/90d_retention"

curl -H 'Content-Type: application/json' -XPUT "https://$es_endpoint/_opendistro/_ism/policies/90d_retention" -d'
{
  "policy": {
    "description": "90d retention policy",
    "default_state": "hot",
    "ism_template": {
      "index_patterns": ['$index_patterns'],
      "priority": 100
    },
    "states": [
      {
        "name": "hot",
        "actions": [],
        "transitions": [
          {
            "state_name": "delete",
            "conditions": {
              "min_index_age": "90d"
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