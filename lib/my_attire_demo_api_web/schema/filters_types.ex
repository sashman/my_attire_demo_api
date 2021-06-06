defmodule MyAttireDemoApiWeb.Schema.FiltersTypes do
  use Absinthe.Schema.Notation

  object :available_filter_value do
    field(:value, :string)
    field(:id, :string)
    field(:count, :integer)
  end

  object :available_filter do
    field(:type, :filter_type_name)
    field(:values, list_of(:available_filter_value))
  end
end
