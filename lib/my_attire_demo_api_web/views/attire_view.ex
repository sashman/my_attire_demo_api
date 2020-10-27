defmodule MyAttireDemoApiWeb.AttireView do
  use MyAttireDemoApiWeb, :view
  alias MyAttireDemoApiWeb.AttireView

  def render("index.json", %{attires: attires}) do
    %{data: render_many(attires, AttireView, "attire.json")}
  end

  def render("show.json", %{attire: attire}) do
    %{data: render_one(attire, AttireView, "attire.json")}
  end

  def render("attire.json", %{attire: attire}) do
    %{id: attire.id}
  end
end
