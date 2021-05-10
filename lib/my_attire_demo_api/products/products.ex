defmodule MyAttireDemoApi.Products do
  def search(term, page, page_size, filters) do
    page_size = page_size || 10
    page = page || 0
    from_offset = from(page_size, page)

    filter_path =
      "hits.hits._id,hits.hits._score,hits.hits.highlight,hits.hits._source,hits.total,aggregations"

    {:ok, results} =
      Elasticsearch.post(
        MyAttireDemoApi.ElasticsearchCluster,
        "/attire/_search?track_total_hits=true&filter_path=#{filter_path}",
        %{
          "size" => page_size,
          "from" => from_offset,
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
        |> add_filters(filters)
        |> exclude_merchants()
        |> IO.inspect()
      )

    results
    |> Map.merge(%{
      "page_size" => page_size,
      "page" => page,
      "offset" => from_offset
    })
  end

  defp add_filters(query, nil), do: query
  defp add_filters(query, %{}), do: query
  defp add_filters(query, %{filters: nil}), do: query
  defp add_filters(query, %{filters: []}), do: query

  defp add_filters(query, filters) do
    IO.inspect(filters)

    filters =
      filters.filters
      |> Enum.map(fn %{type: field_name, values: values} ->
        %{"terms" => %{"#{field_name}.keyword" => values}}
      end)

    current_query = get_in(query, ["query", "bool", "must"])

    query
    |> put_in(["query", "bool", "must"], [current_query] ++ filters)
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
    |> put_in(["query", "bool", "must_not"], exclusion)
  end

  defp from(page_size, page) do
    page * page_size
  end
end
