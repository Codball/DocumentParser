defmodule DocumentParserWeb.LegalDocumentJSON do
  alias DocumentParser.LegalDocuments.LegalDocument

  @doc """
  Renders a list of legal_documents.
  """
  def index(%{legal_documents: legal_documents}) do
    %{data: for(legal_document <- legal_documents, do: data(legal_document))}
  end

  @doc """
  Renders a single legal_document.
  """
  def show(%{
        legal_document: legal_document,
        attempted_plaintiff_search_breadth: attempted_plaintiff_search_breadth,
        attempted_defendant_search_breadth: attempted_defendant_search_breadth
      }) do
    %{
      data:
        data(
          legal_document,
          attempted_plaintiff_search_breadth,
          attempted_defendant_search_breadth
        )
    }
  end

  def show(%{legal_document: legal_document}) do
    %{data: data(legal_document)}
  end

  defp data(%LegalDocument{} = legal_document) do
    %{
      id: legal_document.id,
      file_name: legal_document.file_name,
      plaintiffs: DocumentParserWeb.EntityJSON.list(legal_document.plaintiffs),
      defendants: DocumentParserWeb.EntityJSON.list(legal_document.defendants),
    }
  end

  defp data(
         %LegalDocument{} = legal_document,
         attempted_plaintiff_search_breadth,
         attempted_defendant_search_breadth
       ) do
    %{
      id: legal_document.id,
      file_name: legal_document.file_name,
      plaintiffs: DocumentParserWeb.EntityJSON.list(legal_document.plaintiffs),
      defendants: DocumentParserWeb.EntityJSON.list(legal_document.defendants),
      attempted_plaintiff_search_breadth: attempted_plaintiff_search_breadth,
      attempted_defendant_search_breadth: attempted_defendant_search_breadth
    }
  end
end
