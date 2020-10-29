defmodule MyAttireDemoApiWeb.AttireController do
  use MyAttireDemoApiWeb, :controller

  alias MyAttireDemoApi.DataUpload.Bulk

  action_fallback MyAttireDemoApiWeb.FallbackController

  def bulk_upload(conn, %{"attire" => file}) do
    Bulk.upload_bulk_data(file)

    conn
    |> json("ok")
  end
end
