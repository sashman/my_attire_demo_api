defmodule MyAttireDemoApi.DataUpload.Bulk do
  require Logger

  alias ElasticsearchElixirBulkProcessor.Items.Index

  def upload_bulk_data(file = %Plug.Upload{}) do

    file_stream_options = options(file.filename)

    file.path
      |> File.stream!(file_stream_options)
      |> CSV.decode(headers: true)
      |> Stream.map(fn {:ok, record} -> record end)
      |> Stream.map(fn record ->
        %Index{index: "attire", id: record["aw_product_id"], source: record}
      end)
      |> Stream.chunk_every(5000)
      |> Enum.reduce(0, fn chunk, total ->
        Logger.info("Sending chunk #{total}")
        chunk
        |> Enum.to_list()
        |> ElasticsearchElixirBulkProcessor.send_requests()

        total + 5000
      end)

  end

  defp options(file_path) do
    cond do
      String.ends_with? file_path, ".gz" -> [:compressed]
      true -> []
    end
  end

end
