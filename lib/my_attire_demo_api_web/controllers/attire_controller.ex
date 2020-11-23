defmodule MyAttireDemoApiWeb.AttireController do
  use MyAttireDemoApiWeb, :controller

  alias MyAttireDemoApi.DataUpload.Bulk

  action_fallback MyAttireDemoApiWeb.FallbackController

  def bulk_upload(conn, %{"attire" => file}) do
    Bulk.upload_bulk_data(file)

    conn
    |> json("ok")
  end

  def search(conn, %{"term" => term}) do
    filter_path =
      "hits.hits._id,hits.hits._score,hits.hits.highlight,hits.hits._source,hits.total,aggregations"

    {:ok, results} =
      Elasticsearch.post(
        MyAttireDemoApi.ElasticsearchCluster,
        "/attire/_search?track_total_hits=true&filter_path=#{filter_path}",
        %{
          "query" => %{
            "bool" => %{
              "must" => %{
                "multi_match" => %{
                  "query" => term,
                  "type" => "most_fields",
                  "fields" => [
                    "product_name^3",
                    "description^2",
                    "category_name",
                    "merchant_name"
                  ]
                }
              }
            }
          }
        }
      )

    results =
      results
      |> Map.get("hits")

    conn
    |> json(results)
  end

  def mens(conn, _params) do
    filter_path =
      "hits.hits._id,hits.hits._score,hits.hits.highlight,hits.hits._source,hits.total,aggregations"

    {:ok, results} =
      Elasticsearch.post(
        MyAttireDemoApi.ElasticsearchCluster,
        "/attire/_search?track_total_hits=true&filter_path=#{filter_path}",
        gendered_query("men's")
      )

    results =
      results
      |> Map.get("hits")

    conn
    |> json(results)
  end

  def womens(conn, _params) do
    filter_path =
      "hits.hits._id,hits.hits._score,hits.hits.highlight,hits.hits._source,hits.total,aggregations"

    {:ok, results} =
      Elasticsearch.post(
        MyAttireDemoApi.ElasticsearchCluster,
        "/attire/_search?track_total_hits=true&filter_path=#{filter_path}",
        gendered_query("women's")
      )

    results =
      results
      |> Map.get("hits")

    conn
    |> json(results)
  end

  defp gendered_query(term) do
    %{
      "query" => %{
        "bool" => %{
          "must" => [
            %{
              "match" => %{
                "category_name" => term
              }
            }
          ]
        }
      }
    }
  end
end
