defmodule MyAttireDemoApiWeb.Resolvers.Prodcuts do
  alias MyAttireDemoApi.{Products, Filters}

  def list_products(_parent, %{term: term, page: page, page_size: page_size}, _resolution) do
    products_response = Products.search(term, page, page_size)

    data =
      products_response
      |> get_in(["hits", "hits"])
      |> Enum.map(fn %{"_source" => source} ->
        %{
          category_name: source["category_name"],
          currency: source["currency"],
          deep_link: source["aw_deep_link"],
          delivery_cost: source["delivery_cost"],
          description: source["description"],
          display_price: source["display_price"],
          image_url: source["aw_image_url"],
          merchant_deep_link: source["merchant_deep_link"],
          merchant_image_url: source["merchant_image_url"],
          merchant_name: source["merchant_name"],
          product_id: source["aw_product_id"],
          product_name: source["product_name"],
          search_price: source["search_price"]
        }
      end)

    total =
      products_response
      |> get_in(["hits", "total", "value"])

    meta = %{
      total: total,
      page: products_response["page"],
      page_size: products_response["page_size"],
      page_offset: products_response["offset"]
    }

    {:ok, %{data: data, meta: meta}}
  end

  def list_available_filters(_, _, _) do
    filters_response = Filters.list_all()

    available_filters =
      filters_response["aggregations"]
      |> Enum.map(fn {filter_type, %{"buckets" => buckets}} ->
        %{
          type: filter_type,
          values:
            buckets
            |> Enum.map(fn %{"key" => key, "doc_count" => doc_count} ->
              %{value: key, count: doc_count}
            end)
        }
      end)

    {:ok, available_filters}
  end
end
