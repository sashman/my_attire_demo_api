defmodule MyAttireDemoApiWeb.Schema.ProdcutsTypes do
  use Absinthe.Schema.Notation

  input_object :filters do
    field(:filters, list_of(:filter))
  end

  input_object :filter do
    field(:type, :string)
    field(:values, list_of(:string))
  end

  object :products_result do
    field(:data, list_of(:product))
    field(:meta, :products_meta)
  end

  object :products_meta do
    field(:total, :integer)
    field(:page, :integer)
    field(:page_size, :integer)
    field(:page_offset, :integer)
  end

  object :product do
    field(:category_name, :string)
    field(:currency, :string)
    field(:deep_link, :string)
    field(:delivery_cost, :string)
    field(:description, :string)
    field(:display_price, :string)
    field(:image_url, :string)
    field(:merchant_deep_link, :string)
    field(:merchant_image_url, :string)
    field(:merchant_name, :string)
    field(:product_id, :string)
    field(:product_name, :string)
    field(:search_price, :float)
  end
end
