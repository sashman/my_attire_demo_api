defmodule MyAttireDemoApiWeb.Schema.FiltersTypesTypes do
  use Absinthe.Schema.Notation

  enum :filter_type_name do
    value(:group_category, as: "group_category", description: "Mens/Womens/Kids groups")
    value(:product_ids, as: "product_ids", description: "ID of individual products")
    value(:category_ids, as: "category_ids", description: "Category by ID")
    value(:category_name, as: "category_name", description: "Category by name")
    value(:merchant_ids, as: "merchant_ids", description: "Merchant by id")
    value(:merchant_name, as: "merchant_name", description: "Merchant by name")
  end
end
