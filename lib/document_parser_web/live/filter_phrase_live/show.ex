defmodule DocumentParserWeb.FilterPhraseLive.Show do
  use DocumentParserWeb, :live_view

  alias DocumentParser.FilterPhrases

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:filter_phrase, FilterPhrases.get_filter_phrase!(id))}
  end

  defp page_title(:show), do: "Show Filter phrase"
  defp page_title(:edit), do: "Edit Filter phrase"
end
