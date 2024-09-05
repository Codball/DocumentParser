defmodule DocumentParserWeb.LegalDocumentController do
  use DocumentParserWeb, :controller

  alias DocumentParser.LegalDocuments
  alias DocumentParser.LegalDocuments.LegalDocument
  alias DocumentParser.LegalDocuments.Parser

  action_fallback DocumentParserWeb.FallbackController

  def index(conn, _params) do
    legal_documents = LegalDocuments.list_legal_documents()
    render(conn, :index, legal_documents: legal_documents)
  end

  def create(conn, %{"legal_document" => legal_document_params}) do
    with {:ok, %LegalDocument{} = legal_document} <- LegalDocuments.create_legal_document(legal_document_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", ~p"/api/legal_documents/#{legal_document}")
      |> render(:show, legal_document: legal_document)
    end
  end

  def show(conn, %{"id" => id}) do
    legal_document = LegalDocuments.get_legal_document!(id)
    render(conn, :show, legal_document: legal_document)
  end

  def update(conn, %{"id" => id, "legal_document" => legal_document_params}) do
    legal_document = LegalDocuments.get_legal_document!(id)

    with {:ok, %LegalDocument{} = legal_document} <- LegalDocuments.update_legal_document(legal_document, legal_document_params) do
      render(conn, :show, legal_document: legal_document)
    end
  end

  def delete(conn, %{"id" => id}) do
    legal_document = LegalDocuments.get_legal_document!(id)

    with {:ok, %LegalDocument{}} <- LegalDocuments.delete_legal_document(legal_document) do
      send_resp(conn, :no_content, "")
    end
  end
end
