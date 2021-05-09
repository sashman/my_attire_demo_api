defmodule MyAttireDemoApiWeb.Schema do
  use Absinthe.Schema
  import_types(MyAttireDemoApiWeb.Schema.ProdcutsTypes)

  alias MyAttireDemoApiWeb.Resolvers

  query do
    @desc "Search for products"
    field :products, :products_result do
      arg(:term, non_null(:string))
      arg(:page, :integer)
      arg(:page_size, :integer)
      resolve(&Resolvers.Prodcuts.list_products/3)
    end
  end
end
