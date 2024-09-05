defmodule DocumentParserWeb.LegalDocumentControllerTest do
  use DocumentParserWeb.ConnCase

  import DocumentParser.LegalDocumentsFixtures

  alias DocumentParser.LegalDocuments.LegalDocument

  @create_attrs %{
    file_name: "some file_name",
    parsed_strings: "some parsed_strings"
  }
  @update_attrs %{
    file_name: "some updated file_name",
    parsed_strings: "some updated parsed_strings"
  }
  @invalid_attrs %{file_name: nil, parsed_strings: nil}

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all legal_documents", %{conn: conn} do
      conn = get(conn, ~p"/api/legal_documents")
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create legal_document" do
    test "renders legal_document when data is valid", %{conn: conn} do
      conn = post(conn, ~p"/api/legal_documents", legal_document: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, ~p"/api/legal_documents/#{id}")

      assert %{
               "id" => ^id,
               "file_name" => "some file_name",
               "parsed_strings" => "some parsed_strings"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, ~p"/api/legal_documents", legal_document: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update legal_document" do
    setup [:create_legal_document]

    test "renders legal_document when data is valid", %{conn: conn, legal_document: %LegalDocument{id: id} = legal_document} do
      conn = put(conn, ~p"/api/legal_documents/#{legal_document}", legal_document: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, ~p"/api/legal_documents/#{id}")

      assert %{
               "id" => ^id,
               "file_name" => "some updated file_name",
               "parsed_strings" => "some updated parsed_strings"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, legal_document: legal_document} do
      conn = put(conn, ~p"/api/legal_documents/#{legal_document}", legal_document: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete legal_document" do
    setup [:create_legal_document]

    test "deletes chosen legal_document", %{conn: conn, legal_document: legal_document} do
      conn = delete(conn, ~p"/api/legal_documents/#{legal_document}")
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, ~p"/api/legal_documents/#{legal_document}")
      end
    end
  end

  defp create_legal_document(_) do
    legal_document = legal_document_fixture()
    %{legal_document: legal_document}
  end
end
