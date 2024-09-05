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
  def show(%{legal_document: legal_document}) do
    %{data: data(legal_document)}
  end

  defp data(%LegalDocument{} = legal_document) do
    %{
      id: legal_document.id,
      file_name: legal_document.file_name,
      parsed_strings: legal_document.parsed_strings
    }
  end
end
