defmodule MyAttireDemoApiWeb.AttireController do
  use MyAttireDemoApiWeb, :controller

  alias MyAttireDemoApi.DataUpload.Bulk

  action_fallback MyAttireDemoApiWeb.FallbackController

  def bulk_upload(conn, %{"attire" => file}) do

    file.path
      |> Bulk.upload_bulk_data()

    conn
    |> json("ok")
  end
end
