defmodule DocumentParser.FilterPhrasesFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `DocumentParser.FilterPhrases` context.
  """

  @doc """
  Generate a filter_phrase.
  """
  def filter_phrase_fixture(attrs \\ %{}) do
    {:ok, filter_phrase} =
      attrs
      |> Enum.into(%{
        enabled: true,
        word: "some word"
      })
      |> DocumentParser.FilterPhrases.create_filter_phrase()

    filter_phrase
  end
end
