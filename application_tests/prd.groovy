def main(graph) {
            
    git branch: "master", credentialsId: "gg-techops", url: graph.service.repo_url
    sh script: "git checkout ${graph.service.git_hash}"

    sh script: '''

es_endpoint="vpc-gg-elasticsearch-live-yywbunb3uoo6yv5phcekpym5re.eu-west-1.es.amazonaws.com"

## Install hot_warm_delete policy with index pattern logstash-*
sh policies/hot_warm_delete.sh --es_endpoint $es_endpoint --index_patterns '"logstash-*"'

## Install 90 days retention policy with index pattern kube-events
sh policies/90d_retention.sh --es_endpoint $es_endpoint --index_patterns '"kube-events"'

## Install 90 days retention policy with index pattern cwl
sh policies/90d_retention.sh --es_endpoint $es_endpoint --index_patterns '"cwl-*"'

## Install logstash template
sh index_templates/logstash.sh --es_endpoint $es_endpoint --fields_limit 5000 --shards 5

## Install cwl index template
sh index_templates/cwl.sh --es_endpoint $es_endpoint --fields_limit 1000 --shards 1

## Install kube-events index template
sh index_templates/kube_events.sh --es_endpoint $es_endpoint --fields_limit 5000 --shards 1
'''
}

return this
