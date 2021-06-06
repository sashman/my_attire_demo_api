defmodule MyAttireDemoApi.Products.TermMatchQuery do
  def add_match_query(query, ""), do: query

  def add_match_query(query, term) do
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
end
