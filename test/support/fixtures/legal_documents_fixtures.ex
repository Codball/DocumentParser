defmodule DocumentParser.LegalDocumentsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `DocumentParser.LegalDocuments` context.
  """

  @doc """
  Generate a legal_document.
  """
  def legal_document_fixture(attrs \\ %{}) do
    {:ok, legal_document} =
      attrs
      |> Enum.into(%{
        file_name: "some file_name",
        parsed_strings: "some parsed_strings"
      })
      |> DocumentParser.LegalDocuments.create_legal_document()

    legal_document
  end
end
