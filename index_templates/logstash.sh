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

echo "Creating logstash index template with $shards shards, $fields_limit fields limit, and 60d_retention"
echo ''
## logstash template
curl -H 'Content-Type: application/json' -XPUT "https://$es_endpoint/_template/logstash" -d'
{
    "index_patterns" : ["logstash-*"],
    "mappings" : { 
      "properties": {
        "code": {
          "type":  "text"
        },
        "duration": {
          "type":  "float"
        },
        "exception": {
          "type":  "text"
        },
        "input": {
          "type":  "text"
        },
        "level": {
          "type":  "text"
        },
        "location": {
          "type": "geo_point"
        },
        "message": {
          "type": "text"
        },
        "pid": {
          "type":  "text"
        },
        "version": {
          "type":  "text"
        },
        "response_status": {
          "type":  "text"
        },
        "result": {
          "type":  "text"
        },
        "size": {
          "type":  "long"
        },
        "status": {
          "type":  "text"
        },
        "token_key": {
          "type":  "text"
        },
        "context.status": {
          "type":  "text"
        },
        "context.result": {
          "type":  "text"
        },
        "context.code": {
          "type":  "text"
        },
        "context.response_status": {
          "type":  "long"
        },
        "context.exception": {
          "type":  "text"
        },
        "ts": {
          "type":  "date"
        },
        "response_code": {
          "type": "long"
        },
        "bytes_sent": {
          "type": "long"
        },
        "bytes_received": {
          "type": "long"
        },
        "latency_microseconds": {
          "type": "long"
        },
        "latencyInMs": {
          "type": "long"
        }
      }
    },
    "settings" : {
        "index.mapping.total_fields.limit" : '$fields_limit',
        "number_of_shards": '$shards',
        "index.search.slowlog.threshold.query.warn": "10s",
        "index.search.slowlog.threshold.query.info": "5s",
        "index.search.slowlog.threshold.query.debug": "2s",
        "index.search.slowlog.threshold.query.trace": "500ms",
        "index.search.slowlog.threshold.fetch.warn": "1s",
        "index.search.slowlog.threshold.fetch.info": "800ms",
        "index.search.slowlog.threshold.fetch.debug": "500ms",
        "index.search.slowlog.threshold.fetch.trace": "200ms",
        "index.search.slowlog.level": "info",
        "index.indexing.slowlog.threshold.index.warn": "10s",
        "index.indexing.slowlog.threshold.index.info": "5s",
        "index.indexing.slowlog.threshold.index.debug": "2s",
        "index.indexing.slowlog.threshold.index.trace": "500ms",
        "index.indexing.slowlog.level": "info",
        "index.indexing.slowlog.source": "1000"
    }
}
'
