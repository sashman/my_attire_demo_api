defmodule MyAttireDemoApiWeb.AttireController do
  use MyAttireDemoApiWeb, :controller
  alias ElasticsearchElixirBulkProcessor.Items.Index

  action_fallback MyAttireDemoApiWeb.FallbackController

  def bulk_upload(conn, %{"attire" => file}) do

    file.path
      |> File.stream!()
      |> CSV.decode(headers: true)
      |> Stream.map(fn {:ok, record} -> record end)
      |> Stream.map(fn record ->
        %Index{index: "attire", source: record}
      end)
      |> Enum.to_list()
      |> ElasticsearchElixirBulkProcessor.send_requests()

    conn
    |> json("ok")
  end
end
