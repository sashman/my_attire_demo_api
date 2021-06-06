defmodule MyAttireDemoApi.FilterDecorator do
  require Logger

  def add_filters(query, nil), do: query
  def add_filters(query, %{filters: nil}), do: query
  def add_filters(query, %{filters: []}), do: query

  def add_filters(query, filters) do
    filters =
      filters.filters
      |> Enum.flat_map(&filters_to_query_parts/1)

    new_filters =
      get_in(query, ["query", "bool", "must"])
      |> case do
        nil ->
          filters

        current_query ->
          [current_query] ++ filters
      end

    query
    |> create_or_put_in(["query", "bool", "must"], new_filters)
  end

  defp filters_to_query_parts(%{type: "group_category", values: values}),
    do: values |> Enum.map(&group_category/1)

  defp filters_to_query_parts(%{type: "product_ids", values: values}),
    do: [%{"terms" => %{"aw_product_id" => values}}]

  defp filters_to_query_parts(%{type: "category_ids", values: values}),
    do: [%{"terms" => %{"category_id" => values}}]

  defp filters_to_query_parts(%{type: "merchant_ids", values: values}),
    do: [%{"terms" => %{"merchant_id" => values}}]

  defp filters_to_query_parts(%{type: field_name, values: values})
       when field_name in ["category_name", "merchant_name"],
       do: [%{"terms" => %{"#{field_name}.keyword" => values}}]

  defp filters_to_query_parts(%{type: type}) do
    Logger.warn("Unknown filter type #{type}")
    []
  end

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

  defp create_or_put_in(map, path, value) do
    put_in(map, Enum.map(path, &Access.key(&1, %{})), value)
  end
end
