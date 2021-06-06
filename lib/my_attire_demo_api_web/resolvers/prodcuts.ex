defmodule MyAttireDemoApiWeb.Resolvers.Prodcuts do
  alias MyAttireDemoApi.{Products, AvailableFilters}

  @id_field_map %{
    "category_name" => "category_id",
    "merchant_name" => "merchant_id"
  }

  def list_products(
        _parent,
        args,
        _resolution
      ) do
    term = args[:term] || ""
    page = args[:page]
    page_size = args[:page_size]
    filters = args[:filters]

    products_response = Products.search(term, page, page_size, filters)

    data =
      products_response
      |> case do
        %{"hits" => %{"hits" => hits}} -> hits
        _ -> []
      end
      |> Enum.map(fn %{"_source" => source} ->
        %{
          category_name: source["category_name"],
          category_id: source["category_id"],
          currency: source["currency"],
          deep_link: source["aw_deep_link"],
          delivery_cost: source["delivery_cost"],
          description: source["description"],
          display_price: source["display_price"],
          image_url: source["aw_image_url"],
          merchant_deep_link: source["merchant_deep_link"],
          merchant_image_url: source["merchant_image_url"],
          merchant_name: source["merchant_name"],
          merchant_id: source["merchant_id"],
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

  def list_available_filters(_, args, _) do
    filters = args[:filters]
    term = args[:term] || ""
    filters_response = AvailableFilters.list_all(filters, term)

    available_filters =
      filters_response["aggregations"]
      |> Enum.map(fn {filter_type, %{"buckets" => buckets}} ->
        %{
          type: filter_type,
          values:
            buckets
            |> Enum.map(fn %{
                             "key" => key,
                             "doc_count" => doc_count,
                             "ids" => %{"hits" => %{"hits" => id_hits}}
                           } ->
              id =
                id_hits
                |> List.first()
                |> get_in(["_source", @id_field_map[filter_type]])

              %{value: key, id: id, count: doc_count}
            end)
        }
      end)
      |> add_hardcoded_filters()

    {:ok, available_filters}
  end

  defp add_hardcoded_filters(available_filters) do
    available_filters ++
      [
        %{
          type: "group_category",
          values: [%{value: "mens"}, %{value: "womens"}, %{value: "kids"}]
        },
        %{
          type: "product_ids",
          values: []
        }
      ]
  end
end
