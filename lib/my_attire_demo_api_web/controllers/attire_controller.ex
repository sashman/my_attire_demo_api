defmodule MyAttireDemoApiWeb.AttireController do
  use MyAttireDemoApiWeb, :controller

  action_fallback MyAttireDemoApiWeb.FallbackController

  def bulk_upload(conn, _params) do
    conn
    |> json("ok")
  end
end
