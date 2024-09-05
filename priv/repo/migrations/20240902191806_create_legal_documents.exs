defmodule DocumentParser.Repo.Migrations.CreateLegalDocuments do
  use Ecto.Migration

  def change do
    create table(:legal_documents) do
      add :file_name, :string
      add :parsed_strings, :text

      timestamps(type: :utc_datetime)
    end
  end
end
