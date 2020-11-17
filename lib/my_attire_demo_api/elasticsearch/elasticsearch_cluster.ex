defmodule MyAttireDemoApi.ElasticsearchCluster do
  use Elasticsearch.Cluster, otp_app: :my_attire_demo_api
end
