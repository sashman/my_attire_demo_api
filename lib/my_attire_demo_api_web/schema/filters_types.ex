defmodule MyAttireDemoApiWeb.Schema.FiltersTypes do
  use Absinthe.Schema.Notation

  object :available_filter_value do
    field(:value, :string)
    field(:count, :integer)
  end

  object :available_filter do
    field(:type, :string)
    field(:values, list_of(:available_filter_value))
  end
end
