defmodule MyAttireDemoApi.Products do
  def search(term, page, page_size) do
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
        |> exclude_merchants()
      )

    results
    |> Map.merge(%{
      "page_size" => page_size,
      "page" => page,
      "offset" => from_offset
    })
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
