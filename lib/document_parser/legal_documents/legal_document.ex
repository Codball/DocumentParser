defmodule DocumentParser.LegalDocuments.LegalDocument do
  use Ecto.Schema
  import Ecto.Changeset

  schema "legal_documents" do
    field :file_name, :string
    field :parsed_strings, :string
    field :plaintiff_search_breadth, :integer
    field :defendant_search_breadth, :integer

    timestamps(type: :utc_datetime)

    has_many(:entities, DocumentParser.Entity, on_replace: :delete, on_delete: :delete_all)
    has_many(:plaintiffs, DocumentParser.Entity, where: [type: "plaintiff"], on_replace: :delete)
    has_many(:defendants, DocumentParser.Entity, where: [type: "defendant"], on_replace: :delete)
  end

  @doc false
  def changeset(legal_document, attrs) do
    legal_document
    |> cast(attrs, [
      :file_name,
      :parsed_strings,
      :plaintiff_search_breadth,
      :defendant_search_breadth
    ])
    |> validate_required([
      :file_name,
      :parsed_strings,
      :plaintiff_search_breadth,
      :defendant_search_breadth
    ])
    |> cast_assoc(:entities)
    |> cast_assoc(:plaintiffs)
    |> cast_assoc(:defendants)
  end
end
