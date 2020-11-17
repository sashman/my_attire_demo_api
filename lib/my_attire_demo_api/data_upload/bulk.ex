defmodule MyAttireDemoApi.DataUpload.Bulk do
  require Logger
  use Retry

  alias ElasticsearchElixirBulkProcessor.Items.Index

  @chunk_size 5_000

  def upload_bulk_data(file = %Plug.Upload{}) do
    ElasticsearchElixirBulkProcessor.set_event_count_threshold(7000)
    ElasticsearchElixirBulkProcessor.set_byte_threshold(5_242_880)

    file_stream_options = options(file.filename)

    file.path
    |> File.stream!(file_stream_options)
    |> CSV.decode(headers: true)
    |> Stream.map(fn {:ok, record} ->
      record |> Enum.reject(fn {_, v} -> v == nil || v == "" end) |> Enum.into(%{})
    end)
    |> Stream.map(fn record ->
      %Index{index: "attire", id: record["aw_product_id"], source: record}
    end)
    |> Stream.chunk_every(@chunk_size)
    |> Enum.reduce(0, fn chunk, total ->
      Logger.info("Sending chunk #{total}")

      chunk
      |> Enum.to_list()
      |> ElasticsearchElixirBulkProcessor.send_requests()

      total + @chunk_size
    end)
  end

  defp options(file_path) do
    cond do
      String.ends_with?(file_path, ".gz") -> [:compressed]
      true -> []
    end
  end

  def on_success({:ok, %{"items" => items, "took" => took}}) do
    count =
      items
      |> Enum.count()

    Logger.info("Uploaded #{count}, took #{took}")
  end

  def on_error(%{data: _, error: {_, error}}) do
    error
    |> inspect
    |> Logger.error()
  end

  def on_error(%{data: data, error: {_, %HTTPoison.Error{id: nil, reason: :timeout}}}) do
    data
    |> inspect
    |> Logger.error(label: "HTTP TIMEOUT")
  end

  def retry() do
    exponential_backoff() |> randomize |> expiry(10_000)
  end
end
