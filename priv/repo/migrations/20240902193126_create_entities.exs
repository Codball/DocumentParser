defmodule DocumentParser.Repo.Migrations.CreateEntities do
  use Ecto.Migration

  def change do
    create table(:entities) do
      add :type, :string, null: false
      add :name, :string, null: false
      add :legal_document_id, references(:legal_documents, on_delete: :nothing)

      timestamps(type: :utc_datetime)
    end

    create index(:entities, [:legal_document_id])
  end
end
