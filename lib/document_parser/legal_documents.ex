defmodule DocumentParser.LegalDocuments do
  @moduledoc """
  The LegalDocuments context.
  """

  import Ecto.Query, warn: false
  alias DocumentParser.Repo

  alias DocumentParser.LegalDocuments.LegalDocument

  @doc """
  Returns the list of legal_documents.

  ## Examples

      iex> list_legal_documents()
      [%LegalDocument{}, ...]

  """
  def list_legal_documents do
    LegalDocument
    |> preload([ld], [:plaintiffs, :defendants])
    |> Repo.all()
  end

  @doc """
  Gets a single legal_document.

  Raises `Ecto.NoResultsError` if the Legal document does not exist.

  ## Examples

      iex> get_legal_document!(123)
      %LegalDocument{}

      iex> get_legal_document!(456)
      ** (Ecto.NoResultsError)

  """
  def get_legal_document!(id) do
    LegalDocument
    |> where([ld], ld.id == ^id)
    |> preload([ld], [:plaintiffs, :defendants])
    |> Repo.one!()
  end

  @doc """
  Creates a legal_document.

  ## Examples

      iex> create_legal_document(%{field: value})
      {:ok, %LegalDocument{}}

      iex> create_legal_document(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_legal_document(attrs \\ %{}) do
    %LegalDocument{}
    |> LegalDocument.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a legal_document.

  ## Examples

      iex> update_legal_document(legal_document, %{field: new_value})
      {:ok, %LegalDocument{}}

      iex> update_legal_document(legal_document, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_legal_document(%LegalDocument{} = legal_document, attrs) do
    legal_document
    |> LegalDocument.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a legal_document.

  ## Examples

      iex> delete_legal_document(legal_document)
      {:ok, %LegalDocument{}}

      iex> delete_legal_document(legal_document)
      {:error, %Ecto.Changeset{}}

  """
  def delete_legal_document(%LegalDocument{} = legal_document) do
    Repo.delete(legal_document)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking legal_document changes.

  ## Examples

      iex> change_legal_document(legal_document)
      %Ecto.Changeset{data: %LegalDocument{}}

  """
  def change_legal_document(%LegalDocument{} = legal_document, attrs \\ %{}) do
    LegalDocument.changeset(legal_document, attrs)
  end
end
