defmodule MyAttireDemoApi.Products do
  require Logger

  def search(term, page, page_size, filters) do
    page_size = page_size || 10
    page = page || 0
    from_offset = from(page_size, page)

    filter_path =
      "hits.hits._id,hits.hits._score,hits.hits.highlight,hits.hits._source,hits.total,aggregations"

    query =
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

  defp add_filters(query, nil), do: query
  defp add_filters(query, %{filters: nil}), do: query
  defp add_filters(query, %{filters: []}), do: query

  defp add_filters(query, filters) do
    filters =
      filters.filters
      |> Enum.flat_map(&filters_to_query_parts/1)
      |> IO.inspect()

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

  defp from(page_size, page), do: page * page_size

  defp filters_to_query_parts(%{type: "group_category", values: values}),
    do: values |> Enum.map(&group_category/1)

  defp filters_to_query_parts(%{type: field_name, values: values}),
    do: [%{"terms" => %{"#{field_name}.keyword" => values}}]

  defp group_category("mens"),
    do: %{
      "match" => %{
        "category_name" => "mens men's men"
      }
    }

  defp group_category("womens"),
    do: %{
      "match" => %{
        "category_name" => "womens women's women"
      }
    }

  defp group_category("kids"),
    do: %{
      "match" => %{
        "category_name" => "kid kids kid's children childrens children's child childs child's"
      }
    }
end
