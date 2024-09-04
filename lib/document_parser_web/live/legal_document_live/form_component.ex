defmodule DocumentParserWeb.LegalDocumentLive.FormComponent do
  use DocumentParserWeb, :live_component

  alias DocumentParser.LegalDocuments

  @impl true
  def mount(socket) do
    {:ok,
     socket
     |> allow_upload(:file, max_entries: 1, accept: ~w(.xml))}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
        <:subtitle>Upload a file</:subtitle>
      </.header>


      <.simple_form
        for={@form}
        id="legal_document-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <%!-- <label for={@uploads.file}>File</label> --%>
        <.live_file_input upload={@uploads.file} />
        <.input field={@form[:file_name]} type="text" label="File name" />
        <:actions>
          <.button phx-disable-with="Saving...">Save Legal document</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{legal_document: legal_document} = assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign_new(:form, fn ->
       to_form(LegalDocuments.change_legal_document(legal_document))
     end)}
  end

  @impl true
  def handle_event("validate", %{"legal_document" => legal_document_params}, socket) do
    changeset = LegalDocuments.change_legal_document(socket.assigns.legal_document, legal_document_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"legal_document" => legal_document_params}, socket) do
    save_legal_document(socket, socket.assigns.action, legal_document_params)
  end

  defp save_legal_document(socket, :edit, legal_document_params) do
    case LegalDocuments.update_legal_document(socket.assigns.legal_document, legal_document_params) do
      {:ok, legal_document} ->
        notify_parent({:saved, legal_document})

        {:noreply,
         socket
         |> put_flash(:info, "Legal document updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_legal_document(socket, :new, legal_document_params) do
    Phoenix.LiveView.consume_uploaded_entries(socket, :file, fn %{path: path}, entry ->
      DocumentParser.LegalDocuments.Parser.V1.get_plaintiffs_and_defendants(path)
      {:ok, entry}
    end)

    case LegalDocuments.create_legal_document(legal_document_params) do
      {:ok, legal_document} ->
        notify_parent({:saved, legal_document})

        {:noreply,
         socket
         |> put_flash(:info, "Legal document created successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
