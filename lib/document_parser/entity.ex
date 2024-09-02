defmodule DocumentParser.Entity do
  use Ecto.Schema
  import Ecto.Changeset

  schema "entities" do
    field :name, :string
    field :type, :string
    field :legal_document_id, :id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(entity, attrs) do
    entity
    |> cast(attrs, [:type, :name])
    |> validate_required([:type, :name])
  end
end
