defmodule MyAttireDemoApi.AvailableFilters do
  alias MyAttireDemoApi.FilterDecorator

  def list_all(filters) do
    filter_path = "hits.total,aggregations"

    {:ok, results} =
      Elasticsearch.post(
        MyAttireDemoApi.ElasticsearchCluster,
        "/attire/_search?filter_path=#{filter_path}",
        %{
          "size" => 0,
          "aggs" => %{
            "category_name" => %{
              "terms" => %{
                field: "category_name.keyword",
                size: 1000
              }
            },
            "merchant_name" => %{
              "terms" => %{
                field: "merchant_name.keyword",
                size: 1000
              }
            }
          }
        }
        |> FilterDecorator.add_filters(filters)
      )

    results
  end
end