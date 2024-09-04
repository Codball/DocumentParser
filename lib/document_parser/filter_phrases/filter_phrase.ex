defmodule DocumentParser.FilterPhrases.FilterPhrase do
  use Ecto.Schema
  import Ecto.Changeset

  schema "filter_phrases" do
    field :enabled, :boolean, default: false
    field :word, :string

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(filter_phrase, attrs) do
    filter_phrase
    |> cast(attrs, [:word, :enabled])
    |> validate_required([:word, :enabled])
  end
end
