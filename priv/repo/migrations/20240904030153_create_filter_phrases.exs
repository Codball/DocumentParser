defmodule DocumentParser.Repo.Migrations.CreateFilterPhrases do
  use Ecto.Migration

  def change do
    create table(:filter_phrases) do
      add :word, :string, null: false
      add :enabled, :boolean, default: true, null: false

      timestamps(type: :utc_datetime)
    end
  end
end
