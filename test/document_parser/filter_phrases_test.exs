defmodule DocumentParser.FilterPhrasesTest do
  use DocumentParser.DataCase

  alias DocumentParser.FilterPhrases

  describe "filter_phrases" do
    alias DocumentParser.FilterPhrases.FilterPhrase

    import DocumentParser.FilterPhrasesFixtures

    @invalid_attrs %{enabled: nil, word: nil}

    test "list_filter_phrases/0 returns all filter_phrases" do
      filter_phrase = filter_phrase_fixture()
      assert FilterPhrases.list_filter_phrases() == [filter_phrase]
    end

    test "get_filter_phrase!/1 returns the filter_phrase with given id" do
      filter_phrase = filter_phrase_fixture()
      assert FilterPhrases.get_filter_phrase!(filter_phrase.id) == filter_phrase
    end

    test "create_filter_phrase/1 with valid data creates a filter_phrase" do
      valid_attrs = %{enabled: true, word: "some word"}

      assert {:ok, %FilterPhrase{} = filter_phrase} = FilterPhrases.create_filter_phrase(valid_attrs)
      assert filter_phrase.enabled == true
      assert filter_phrase.word == "some word"
    end

    test "create_filter_phrase/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = FilterPhrases.create_filter_phrase(@invalid_attrs)
    end

    test "update_filter_phrase/2 with valid data updates the filter_phrase" do
      filter_phrase = filter_phrase_fixture()
      update_attrs = %{enabled: false, word: "some updated word"}

      assert {:ok, %FilterPhrase{} = filter_phrase} = FilterPhrases.update_filter_phrase(filter_phrase, update_attrs)
      assert filter_phrase.enabled == false
      assert filter_phrase.word == "some updated word"
    end

    test "update_filter_phrase/2 with invalid data returns error changeset" do
      filter_phrase = filter_phrase_fixture()
      assert {:error, %Ecto.Changeset{}} = FilterPhrases.update_filter_phrase(filter_phrase, @invalid_attrs)
      assert filter_phrase == FilterPhrases.get_filter_phrase!(filter_phrase.id)
    end

    test "delete_filter_phrase/1 deletes the filter_phrase" do
      filter_phrase = filter_phrase_fixture()
      assert {:ok, %FilterPhrase{}} = FilterPhrases.delete_filter_phrase(filter_phrase)
      assert_raise Ecto.NoResultsError, fn -> FilterPhrases.get_filter_phrase!(filter_phrase.id) end
    end

    test "change_filter_phrase/1 returns a filter_phrase changeset" do
      filter_phrase = filter_phrase_fixture()
      assert %Ecto.Changeset{} = FilterPhrases.change_filter_phrase(filter_phrase)
    end
  end
end
