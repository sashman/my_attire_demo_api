defmodule MyAttireDemoApiWeb.AttireControllerTest do
  use MyAttireDemoApiWeb.ConnCase

  alias MyAttireDemoApi.Attires
  alias MyAttireDemoApi.Attires.Attire

  @create_attrs %{

  }
  @update_attrs %{

  }
  @invalid_attrs %{}

  def fixture(:attire) do
    {:ok, attire} = Attires.create_attire(@create_attrs)
    attire
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all attires", %{conn: conn} do
      conn = get(conn, Routes.attire_path(conn, :index))
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create attire" do
    test "renders attire when data is valid", %{conn: conn} do
      conn = post(conn, Routes.attire_path(conn, :create), attire: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, Routes.attire_path(conn, :show, id))

      assert %{
               "id" => id
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.attire_path(conn, :create), attire: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update attire" do
    setup [:create_attire]

    test "renders attire when data is valid", %{conn: conn, attire: %Attire{id: id} = attire} do
      conn = put(conn, Routes.attire_path(conn, :update, attire), attire: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, Routes.attire_path(conn, :show, id))

      assert %{
               "id" => id
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, attire: attire} do
      conn = put(conn, Routes.attire_path(conn, :update, attire), attire: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete attire" do
    setup [:create_attire]

    test "deletes chosen attire", %{conn: conn, attire: attire} do
      conn = delete(conn, Routes.attire_path(conn, :delete, attire))
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, Routes.attire_path(conn, :show, attire))
      end
    end
  end

  defp create_attire(_) do
    attire = fixture(:attire)
    %{attire: attire}
  end
end
