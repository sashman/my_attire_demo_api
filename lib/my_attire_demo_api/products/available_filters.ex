defmodule MyAttireDemoApi.AvailableFilters do
  alias MyAttireDemoApi.FilterDecorator
  alias MyAttireDemoApi.Products.TermMatchQuery

  require Logger

  def list_all(filters, term) do
    filter_path = "hits.total,aggregations"

    query =
      %{
        "size" => 0,
        "aggs" => %{
          "category_name" => %{
            "terms" => %{
              field: "category_name.keyword",
              size: 1000
            },
            "aggs" => %{
              "ids" => %{
                "top_hits" => %{
                  "size" => 1,
                  "_source" => %{"includes" => "category_id"}
                }
              }
            }
          },
          "merchant_name" => %{
            "terms" => %{
              field: "merchant_name.keyword",
              size: 1000
            },
            "aggs" => %{
              "ids" => %{
                "top_hits" => %{
                  "size" => 1,
                  "_source" => %{"includes" => "merchant_id"}
                }
              }
            }
          }
        }
      }
      |> FilterDecorator.add_filters(filters)
      |> TermMatchQuery.add_match_query(term)

    Logger.info(query |> Jason.encode!())

    {:ok, results} =
      Elasticsearch.post(
        MyAttireDemoApi.ElasticsearchCluster,
        "/attire/_search?filter_path=#{filter_path}",
        query
      )

    results
  end
end
