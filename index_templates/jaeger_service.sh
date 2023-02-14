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

echo "Creating jaeger-service index template with $shards shards, $replicas replicas and policy_id $policy_id"
echo ''

## jaeger-service template
curl -H 'Content-Type: application/json' -XPUT "https://$es_endpoint/_template/jaeger-service" -d'
{
    "index_patterns" : [
      "jaeger-service-*"
    ],
    "settings" : {
      "index" : {
        "mapping" : {
          "nested_fields" : {
            "limit" : "50"
          }
        },
        "requests" : {
          "cache" : {
            "enable" : "true"
          }
        },
        "number_of_shards": '$shards',
        "number_of_replicas": '$replicas'
      }
    },
    "mappings" : {
      "dynamic_templates" : [
        {
          "span_tags_map" : {
            "path_match" : "tag.*",
            "mapping" : {
              "ignore_above" : 256,
              "type" : "keyword"
            }
          }
        },
        {
          "process_tags_map" : {
            "path_match" : "process.tag.*",
            "mapping" : {
              "ignore_above" : 256,
              "type" : "keyword"
            }
          }
        }
      ],
      "properties" : {
        "operationName" : {
          "ignore_above" : 256,
          "type" : "keyword"
        },
        "serviceName" : {
          "ignore_above" : 256,
          "type" : "keyword"
        }
      }
    },
    "aliases" : { }
}
'
