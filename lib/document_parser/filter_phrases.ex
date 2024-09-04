defmodule DocumentParser.FilterPhrases do
  @moduledoc """
  The FilterPhrases context.
  """

  import Ecto.Query, warn: false
  alias DocumentParser.Repo

  alias DocumentParser.FilterPhrases.FilterPhrase

  @doc """
  Returns the list of filter_phrases.

  ## Examples

      iex> list_filter_phrases()
      [%FilterPhrase{}, ...]

  """
  def list_filter_phrases do
    Repo.all(FilterPhrase)
  end

  @doc """
  Returns the list of filter_phrases.

  ## Examples

      iex> list_filter_phrases()
      [%FilterPhrase{}, ...]

  """
  def list_enabled_filter_phrases do
    from(fp in FilterPhrase,
    where: fp.enabled == true,
    select: fp.word
  )
  |> Repo.all()
  end

  @doc """
  Gets a single filter_phrase.

  Raises `Ecto.NoResultsError` if the Filter phrase does not exist.

  ## Examples

      iex> get_filter_phrase!(123)
      %FilterPhrase{}

      iex> get_filter_phrase!(456)
      ** (Ecto.NoResultsError)

  """
  def get_filter_phrase!(id), do: Repo.get!(FilterPhrase, id)

  @doc """
  Creates a filter_phrase.

  ## Examples

      iex> create_filter_phrase(%{field: value})
      {:ok, %FilterPhrase{}}

      iex> create_filter_phrase(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_filter_phrase(attrs \\ %{}) do
    %FilterPhrase{}
    |> FilterPhrase.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a filter_phrase.

  ## Examples

      iex> update_filter_phrase(filter_phrase, %{field: new_value})
      {:ok, %FilterPhrase{}}

      iex> update_filter_phrase(filter_phrase, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_filter_phrase(%FilterPhrase{} = filter_phrase, attrs) do
    filter_phrase
    |> FilterPhrase.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a filter_phrase.

  ## Examples

      iex> delete_filter_phrase(filter_phrase)
      {:ok, %FilterPhrase{}}

      iex> delete_filter_phrase(filter_phrase)
      {:error, %Ecto.Changeset{}}

  """
  def delete_filter_phrase(%FilterPhrase{} = filter_phrase) do
    Repo.delete(filter_phrase)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking filter_phrase changes.

  ## Examples

      iex> change_filter_phrase(filter_phrase)
      %Ecto.Changeset{data: %FilterPhrase{}}

  """
  def change_filter_phrase(%FilterPhrase{} = filter_phrase, attrs \\ %{}) do
    FilterPhrase.changeset(filter_phrase, attrs)
  end
end
