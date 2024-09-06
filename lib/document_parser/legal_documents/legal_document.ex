defmodule DocumentParser.LegalDocuments.LegalDocument do
  use Ecto.Schema
  import Ecto.Changeset

  schema "legal_documents" do
    field :file_name, :string
    field :parsed_strings, :string

    timestamps(type: :utc_datetime)

    has_many(:entities, DocumentParser.Entity, on_replace: :delete)
    has_many(:plaintiffs, DocumentParser.Entity, where: [type: "plaintiff"])
    has_many(:defendants, DocumentParser.Entity, where: [type: "defendant"])
  end

  @doc false
  def changeset(legal_document, attrs) do
    legal_document
    |> cast(attrs, [:file_name, :parsed_strings])
    |> cast_assoc(:entities)
    |> validate_required([:file_name, :parsed_strings])
  end
end
