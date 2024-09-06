defmodule DocumentParser.LegalDocumentsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `DocumentParser.LegalDocuments` context.
  """

  @fixtures_path "/test/support/fixtures/"

  @doc """
  Generate a legal_document.
  """
  def legal_document_fixture(attrs \\ %{}) do
    filepath = File.cwd!() <> @fixtures_path <> "C.xml"

    charlists = DocumentParser.LegalDocuments.Parser.V1.read_file(filepath)

    parsed_charlists = Jason.encode!(charlists)

    {:ok, legal_document} =
      attrs
      |> Enum.into(%{
        file_name: "some file_name",
        parsed_strings: parsed_charlists,
        plaintiff_search_breadth: 1,
        defendant_search_breadth: 1
      })
      |> DocumentParser.LegalDocuments.create_legal_document()

    legal_document
    |> DocumentParser.Repo.preload([:entities, :plaintiffs, :defendants])
  end
end
