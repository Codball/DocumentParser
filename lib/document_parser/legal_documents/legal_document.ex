defmodule DocumentParser.LegalDocuments.LegalDocument do
  use Ecto.Schema
  import Ecto.Changeset

  schema "legal_documents" do
    field :file_name, :string
    field :parsed_strings, :string

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(legal_document, attrs) do
    legal_document
    |> cast(attrs, [:file_name, :parsed_strings])
    |> validate_required([:file_name, :parsed_strings])
  end
end
