defmodule DocumentParserWeb.LegalDocumentLive.Index do
  use DocumentParserWeb, :live_view

  alias DocumentParser.LegalDocuments
  alias DocumentParser.LegalDocuments.LegalDocument

  @impl true
  def mount(_params, _session, socket) do
    {:ok, stream(socket, :legal_documents, LegalDocuments.list_legal_documents())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Legal document")
    |> assign(:legal_document, LegalDocuments.get_legal_document!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Legal document")
    |> assign(:legal_document, %LegalDocument{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Legal documents")
    |> assign(:legal_document, nil)
  end

  @impl true
  def handle_info({DocumentParserWeb.LegalDocumentLive.FormComponent, {:saved, legal_document}}, socket) do
    {:noreply, stream_insert(socket, :legal_documents, legal_document)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    legal_document = LegalDocuments.get_legal_document!(id)
    {:ok, _} = LegalDocuments.delete_legal_document(legal_document)

    {:noreply, stream_delete(socket, :legal_documents, legal_document)}
  end
end
