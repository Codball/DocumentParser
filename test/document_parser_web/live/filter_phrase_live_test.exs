defmodule DocumentParserWeb.FilterPhraseLiveTest do
  use DocumentParserWeb.ConnCase

  import Phoenix.LiveViewTest
  import DocumentParser.FilterPhrasesFixtures

  @create_attrs %{enabled: true, word: "some word"}
  @update_attrs %{enabled: false, word: "some updated word"}
  @invalid_attrs %{enabled: false, word: nil}

  defp create_filter_phrase(_) do
    filter_phrase = filter_phrase_fixture()
    %{filter_phrase: filter_phrase}
  end

  describe "Index" do
    setup [:create_filter_phrase]

    test "lists all filter_phrases", %{conn: conn, filter_phrase: filter_phrase} do
      {:ok, _index_live, html} = live(conn, ~p"/filter_phrases")

      assert html =~ "Listing Filter phrases"
      assert html =~ filter_phrase.word
    end

    test "saves new filter_phrase", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/filter_phrases")

      assert index_live |> element("a", "New Filter phrase") |> render_click() =~
               "New Filter phrase"

      assert_patch(index_live, ~p"/filter_phrases/new")

      assert index_live
             |> form("#filter_phrase-form", filter_phrase: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#filter_phrase-form", filter_phrase: @create_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/filter_phrases")

      html = render(index_live)
      assert html =~ "Filter phrase created successfully"
      assert html =~ "some word"
    end

    test "updates filter_phrase in listing", %{conn: conn, filter_phrase: filter_phrase} do
      {:ok, index_live, _html} = live(conn, ~p"/filter_phrases")

      assert index_live |> element("#filter_phrases-#{filter_phrase.id} a", "Edit") |> render_click() =~
               "Edit Filter phrase"

      assert_patch(index_live, ~p"/filter_phrases/#{filter_phrase}/edit")

      assert index_live
             |> form("#filter_phrase-form", filter_phrase: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#filter_phrase-form", filter_phrase: @update_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/filter_phrases")

      html = render(index_live)
      assert html =~ "Filter phrase updated successfully"
      assert html =~ "some updated word"
    end

    test "deletes filter_phrase in listing", %{conn: conn, filter_phrase: filter_phrase} do
      {:ok, index_live, _html} = live(conn, ~p"/filter_phrases")

      assert index_live |> element("#filter_phrases-#{filter_phrase.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#filter_phrases-#{filter_phrase.id}")
    end
  end

  describe "Show" do
    setup [:create_filter_phrase]

    test "displays filter_phrase", %{conn: conn, filter_phrase: filter_phrase} do
      {:ok, _show_live, html} = live(conn, ~p"/filter_phrases/#{filter_phrase}")

      assert html =~ "Show Filter phrase"
      assert html =~ filter_phrase.word
    end

    test "updates filter_phrase within modal", %{conn: conn, filter_phrase: filter_phrase} do
      {:ok, show_live, _html} = live(conn, ~p"/filter_phrases/#{filter_phrase}")

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Filter phrase"

      assert_patch(show_live, ~p"/filter_phrases/#{filter_phrase}/show/edit")

      assert show_live
             |> form("#filter_phrase-form", filter_phrase: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert show_live
             |> form("#filter_phrase-form", filter_phrase: @update_attrs)
             |> render_submit()

      assert_patch(show_live, ~p"/filter_phrases/#{filter_phrase}")

      html = render(show_live)
      assert html =~ "Filter phrase updated successfully"
      assert html =~ "some updated word"
    end
  end
end
