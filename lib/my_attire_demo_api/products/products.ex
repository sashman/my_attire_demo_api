defmodule MyAttireDemoApi.Products do
  require Logger

  alias MyAttireDemoApi.FilterDecorator

  def search(term, page, page_size, filters) do
    page_size = page_size || 10
    page = page || 0
    from_offset = from(page_size, page)

    filter_path =
      "hits.hits._id,hits.hits._score,hits.hits.highlight,hits.hits._source,hits.total,aggregations"

    query =
      %{
        "size" => page_size,
        "from" => from_offset
      }
      |> add_match_query(term)
      |> FilterDecorator.add_filters(filters)
      |> exclude_merchants()

    Logger.info(query |> Jason.encode!())

    {:ok, results} =
      Elasticsearch.post(
        MyAttireDemoApi.ElasticsearchCluster,
        "/attire/_search?track_total_hits=true&filter_path=#{filter_path}",
        query
      )

    results
    |> Map.merge(%{
      "page_size" => page_size,
      "page" => page,
      "offset" => from_offset
    })
  end

  defp add_match_query(query, ""), do: query

  defp add_match_query(query, term) do
    condition = %{
      "query" => %{
        "bool" => %{
          "must" => %{
            "multi_match" => %{
              "query" => term,
              "type" => "most_fields",
              "fields" => [
                "product_name^3",
                "description^2",
                "category_name",
                "merchant_name"
              ]
            }
          }
        }
      }
    }

    query
    |> Map.merge(condition)
  end

  defp exclude_merchants(query) do
    exclusion = [
      %{
        "bool" => %{
          "filter" => [
            %{
              "term" => %{
                "merchant_name.keyword": "boohoo.com UK & IE"
              }
            }
          ]
        }
      }
    ]

    query
    |> create_or_put_in(["query", "bool", "must_not"], exclusion)
  end

  defp from(page_size, page), do: page * page_size

  defp create_or_put_in(map, path, value) do
    put_in(map, Enum.map(path, &Access.key(&1, %{})), value)
  end
end
