defmodule MyAttireDemoApi.DataUpload.Bulk do

  alias ElasticsearchElixirBulkProcessor.Items.Index

  def upload_bulk_data(file_path) do
    file_path
      |> File.stream!()
      |> CSV.decode(headers: true)
      |> Stream.map(fn {:ok, record} -> record end)
      |> Stream.map(fn record ->
        %Index{index: "attire", id: record["aw_product_id"], source: record}
      end)
      |> Enum.to_list()
      |> ElasticsearchElixirBulkProcessor.send_requests()
  end

end
