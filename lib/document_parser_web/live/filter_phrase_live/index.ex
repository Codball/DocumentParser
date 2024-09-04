defmodule DocumentParserWeb.FilterPhraseLive.Index do
  use DocumentParserWeb, :live_view

  alias DocumentParser.FilterPhrases
  alias DocumentParser.FilterPhrases.FilterPhrase

  @impl true
  def mount(_params, _session, socket) do
    {:ok, stream(socket, :filter_phrases, FilterPhrases.list_filter_phrases())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Filter phrase")
    |> assign(:filter_phrase, FilterPhrases.get_filter_phrase!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Filter phrase")
    |> assign(:filter_phrase, %FilterPhrase{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Filter phrases")
    |> assign(:filter_phrase, nil)
  end

  @impl true
  def handle_info({DocumentParserWeb.FilterPhraseLive.FormComponent, {:saved, filter_phrase}}, socket) do
    {:noreply, stream_insert(socket, :filter_phrases, filter_phrase)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    filter_phrase = FilterPhrases.get_filter_phrase!(id)
    {:ok, _} = FilterPhrases.delete_filter_phrase(filter_phrase)

    {:noreply, stream_delete(socket, :filter_phrases, filter_phrase)}
  end
end
