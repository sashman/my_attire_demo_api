defmodule MyAttireDemoApi.Filters do
  def list_all() do
    filter_path = "hits.total,aggregations"

    {:ok, results} =
      Elasticsearch.post(
        MyAttireDemoApi.ElasticsearchCluster,
        "/attire/_search?filter_path=#{filter_path}",
        %{
          "size" => 0,
          "aggs" => %{
            "categories" => %{
              "terms" => %{
                field: "category_name.keyword",
                size: 1000
              }
            },
            "merchants" => %{
              "terms" => %{
                field: "merchant_name.keyword",
                size: 1000
              }
            }
          }
        }
      )

    results
  end
end
