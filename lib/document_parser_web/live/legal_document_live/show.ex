defmodule DocumentParserWeb.LegalDocumentLive.Show do
  use DocumentParserWeb, :live_view

  alias DocumentParser.LegalDocuments

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:legal_document, LegalDocuments.get_legal_document!(id))}
  end

  defp page_title(:show), do: "Show Legal document"
  defp page_title(:edit), do: "Edit Legal document"
end
