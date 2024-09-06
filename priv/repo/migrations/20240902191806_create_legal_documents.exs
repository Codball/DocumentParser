defmodule DocumentParser.Repo.Migrations.CreateLegalDocuments do
  use Ecto.Migration

  def change do
    create table(:legal_documents) do
      add :file_name, :string, null: false
      add :parsed_strings, :text, null: false
      add :plaintiff_search_breadth, :integer, null: false
      add :defendant_search_breadth, :integer, null: false

      timestamps(type: :utc_datetime)
    end
  end
end
