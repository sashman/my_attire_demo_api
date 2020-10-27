defmodule MyAttireDemoApiWeb.AttireController do
  use MyAttireDemoApiWeb, :controller

  action_fallback MyAttireDemoApiWeb.FallbackController

  def bulk_upload(conn, %{"attire" => file}) do

    file.path
      |> File.stream!()
      |> CSV.decode(headers: true)
      |> Stream.take(5)
      |> Enum.to_list()
      |> IO.inspect()

    conn
    |> json("ok")
  end
end
