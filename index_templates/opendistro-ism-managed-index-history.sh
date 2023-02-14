#!/bin/bash

es_endpoint=${es_endpoint:-nil}
shards=${shards:-1}
replicas=${replicas:-1}
policy_id=${policy_id:-90d_retention}


while [ $# -gt 0 ]; do

   if [[ $1 == *"--"* ]]; then
        param="${1/--/}"
        declare $param="$2"
        # echo $1 $2 // Optional to see the parameter:value result
   fi

  shift
done

echo "Creating jaeger-span index template with $shards shards, $replicas replicas and policy_id $policy_id"
echo ''

## jaeger-span index template
curl -H 'Content-Type: application/json' -XPUT "https://$es_endpoint/_template/jaeger-span" -d'
{
    "index_patterns" : [
      "*jaeger-span-*"
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
        "number_of_replicas": '$replicas',
        "opendistro.index_state_management.policy_id": "'"$policy_id"'"
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
        "traceID" : {
          "ignore_above" : 256,
          "type" : "keyword"
        },
        "process" : {
          "properties" : {
            "tag" : {
              "type" : "object"
            },
            "serviceName" : {
              "ignore_above" : 256,
              "type" : "keyword"
            },
            "tags" : {
              "dynamic" : false,
              "type" : "nested",
              "properties" : {
                "tagType" : {
                  "ignore_above" : 256,
                  "type" : "keyword"
                },
                "value" : {
                  "ignore_above" : 256,
                  "type" : "keyword"
                },
                "key" : {
                  "ignore_above" : 256,
                  "type" : "keyword"
                }
              }
            }
          }
        },
        "startTimeMillis" : {
          "format" : "epoch_millis",
          "type" : "date"
        },
        "references" : {
          "dynamic" : false,
          "type" : "nested",
          "properties" : {
            "traceID" : {
              "ignore_above" : 256,
              "type" : "keyword"
            },
            "spanID" : {
              "ignore_above" : 256,
              "type" : "keyword"
            },
            "refType" : {
              "ignore_above" : 256,
              "type" : "keyword"
            }
          }
        },
        "flags" : {
          "type" : "integer"
        },
        "operationName" : {
          "ignore_above" : 256,
          "type" : "keyword"
        },
        "parentSpanID" : {
          "ignore_above" : 256,
          "type" : "keyword"
        },
        "tags" : {
          "dynamic" : false,
          "type" : "nested",
          "properties" : {
            "tagType" : {
              "ignore_above" : 256,
              "type" : "keyword"
            },
            "value" : {
              "ignore_above" : 256,
              "type" : "keyword"
            },
            "key" : {
              "ignore_above" : 256,
              "type" : "keyword"
            }
          }
        },
        "spanID" : {
          "ignore_above" : 256,
          "type" : "keyword"
        },
        "duration" : {
          "type" : "long"
        },
        "startTime" : {
          "type" : "long"
        },
        "tag" : {
          "type" : "object"
        },
        "logs" : {
          "dynamic" : false,
          "type" : "nested",
          "properties" : {
            "fields" : {
              "dynamic" : false,
              "type" : "nested",
              "properties" : {
                "tagType" : {
                  "ignore_above" : 256,
                  "type" : "keyword"
                },
                "value" : {
                  "ignore_above" : 256,
                  "type" : "keyword"
                },
                "key" : {
                  "ignore_above" : 256,
                  "type" : "keyword"
                }
              }
            },
            "timestamp" : {
              "type" : "long"
            }
          }
        }
      }
    },
    "aliases" : { }
}
'