defmodule DocumentParserWeb.LegalDocumentLiveTest do
  use DocumentParserWeb.ConnCase

  import Phoenix.LiveViewTest
  import DocumentParser.LegalDocumentsFixtures

  @create_attrs %{file_name: "some file_name"}
  @invalid_attrs %{file_name: nil}
  # @update_attrs %{file_name: "some updated file_name"}

  @fixtures_path "/test/support/fixtures/"

  defp create_legal_document(_) do
    legal_document = legal_document_fixture()
    %{legal_document: legal_document}
  end

  describe "Index" do
    setup [:create_legal_document]

    test "lists all legal_documents", %{conn: conn, legal_document: legal_document} do
      {:ok, _index_live, html} = live(conn, ~p"/legal_documents")

      assert html =~ "Listing Legal documents"
      assert html =~ legal_document.file_name
    end

    test "saves new legal_document", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/legal_documents")

      assert index_live |> element("a", "New Legal document") |> render_click() =~
               "New Legal document"

      assert_patch(index_live, ~p"/legal_documents/new")

      assert index_live
             |> form("#legal_document-form", legal_document: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      file_path = File.cwd!() <> @fixtures_path <> "C.xml"

      index_live
      |> file_input("#legal_document-form", :file, [%{
        name: "C.xml",
        content: File.read!(file_path),
        type: "text/xml"
      }])
      |> render_upload("C.xml")

      assert index_live
             |> form("#legal_document-form", legal_document: @create_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/legal_documents")

      html = render(index_live)
      assert html =~ "Legal document created successfully"
      assert html =~ "some file_name"
      assert html =~ "ALBA ALVARADO"
      assert html =~ "LAGUARDIA ENTERPRISES INC"
    end

    # Editing a Legal Document is not supported yet
    # test "updates legal_document in listing", %{conn: conn, legal_document: legal_document} do
    #   {:ok, index_live, _html} = live(conn, ~p"/legal_documents")

    #   assert index_live |> element("#legal_documents-#{legal_document.id} a", "Edit") |> render_click() =~
    #            "Edit Legal document"

    #   assert_patch(index_live, ~p"/legal_documents/#{legal_document}/edit")

    #   assert index_live
    #          |> form("#legal_document-form", legal_document: @invalid_attrs)
    #          |> render_change() =~ "can&#39;t be blank"

    #   assert index_live
    #          |> form("#legal_document-form", legal_document: @update_attrs)
    #          |> render_submit()

    #   assert_patch(index_live, ~p"/legal_documents")

    #   html = render(index_live)
    #   assert html =~ "Legal document updated successfully"
    #   assert html =~ "some updated file_name"
    # end

    test "deletes legal_document in listing", %{conn: conn, legal_document: legal_document} do
      {:ok, index_live, _html} = live(conn, ~p"/legal_documents")

      assert index_live |> element("#legal_documents-#{legal_document.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#legal_documents-#{legal_document.id}")
    end
  end

  describe "Show" do
    setup [:create_legal_document]

    test "displays legal_document", %{conn: conn, legal_document: legal_document} do
      {:ok, _show_live, html} = live(conn, ~p"/legal_documents/#{legal_document}")

      assert html =~ "Show Legal document"
      assert html =~ legal_document.file_name
    end

    # Editing a Legal Document is not supported yet
    # test "updates legal_document within modal", %{conn: conn, legal_document: legal_document} do
    #   {:ok, show_live, _html} = live(conn, ~p"/legal_documents/#{legal_document}")

    #   assert show_live |> element("a", "Edit") |> render_click() =~
    #            "Edit Legal document"

    #   assert_patch(show_live, ~p"/legal_documents/#{legal_document}/show/edit")

    #   assert show_live
    #          |> form("#legal_document-form", legal_document: @invalid_attrs)
    #          |> render_change() =~ "can&#39;t be blank"

    #   assert show_live
    #          |> form("#legal_document-form", legal_document: @update_attrs)
    #          |> render_submit()

    #   assert_patch(show_live, ~p"/legal_documents/#{legal_document}")

    #   html = render(show_live)
    #   assert html =~ "Legal document updated successfully"
    #   assert html =~ "some updated file_name"
    # end
  end
end
