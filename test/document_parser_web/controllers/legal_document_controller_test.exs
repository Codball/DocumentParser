defmodule DocumentParserWeb.LegalDocumentControllerTest do
  use DocumentParserWeb.ConnCase

  import DocumentParser.LegalDocumentsFixtures

  alias DocumentParser.LegalDocuments.LegalDocument

  @create_attrs %{
    file_name: "some file_name",
    parsed_strings: "[[25], [45]]"
  }
  @update_attrs %{
    file_name: "some updated file_name",
    parsed_strings: "[[25], [45]]"
  }
  @invalid_attrs %{file_name: nil, parsed_strings: nil}

  @fixtures_path "/test/support/fixtures/"

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
      file_path = File.cwd!() <> @fixtures_path <> "C.xml"
      conn = post(conn, ~p"/api/legal_documents", document_name: @create_attrs.file_name, file: %Plug.Upload{path: file_path}, opts: "{}")
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, ~p"/api/legal_documents/#{id}")

      assert %{
               "id" => ^id,
               "file_name" => "some file_name",
               "plaintiffs" => ["ALBA ALVARADO"],
               "defendants" => ["LAGUARDIA ENTERPRISES INC"],
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
      conn = put(conn, ~p"/api/legal_documents/#{legal_document}", document_name: @update_attrs.file_name, opts: "{}")
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, ~p"/api/legal_documents/#{id}")

      assert %{
               "id" => ^id,
               "file_name" => "some updated file_name",
               "plaintiffs" => ["ALBA ALVARADO"],
               "defendants" => ["LAGUARDIA ENTERPRISES INC"]
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, legal_document: legal_document} do
      conn = put(conn, ~p"/api/legal_documents/#{legal_document}", document_name: nil, opts: "{}")
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
    legal_document = legal_document_fixture() |> DocumentParser.Repo.preload([:plaintiffs, :defendants])
    %{legal_document: legal_document}
  end
end
