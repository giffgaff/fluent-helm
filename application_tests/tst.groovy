def main(graph) {
    
    git branch: "master", credentialsId: "gg-techops", url: graph.service.repo_url
    sh script: "git checkout ${graph.service.git_hash}"

    sh script: '''

es_endpoint="vpc-gg-elasticsearch-test-m4bjq2bgliivv5ponx3ulx4ibm.eu-west-1.es.amazonaws.com"

## Install 60 days retention policy with index pattern logstash-*
sh policies/60d_retention.sh --es_endpoint $es_endpoint --index_patterns '"logstash-*"'

## Install 90 days retention policy with index pattern kube-events
sh policies/90d_retention.sh --es_endpoint $es_endpoint --index_patterns '"kube-events"'

## Install 90 days retention policy with index pattern cwl
sh policies/90d_retention.sh --es_endpoint $es_endpoint --index_patterns '"cwl"'

## Install logstash template
sh index_templates/logstash.sh --es_endpoint $es_endpoint --fields_limit 2500

## Install kube-events index template
sh index_templates/kube_events.sh --es_endpoint $es_endpoint --fields_limit 1000 --shards 1

## Install cwl index template
sh index_templates/cwl.sh --es_endpoint $es_endpoint --fields_limit 1000 --shards 1

## Install ism-history-indices template
sh index_templates/ism_history_indices.sh --es_endpoint $es_endpoint
'''
}

return this
