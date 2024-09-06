defmodule DocumentParserWeb.LegalDocumentLive.FormComponent do
  alias DocumentParser.Entity
  use DocumentParserWeb, :live_component

  alias DocumentParser.LegalDocuments

  @impl true
  def mount(socket) do
    {:ok,
     socket
     |> allow_upload(:file,
       max_entries: 1,
       accept: ~w(.xml),
       progress: &handle_progress/3,
       auto_upload: true
     )
     |> assign(:plaintiff_search_breadth, "0")
     |> assign(:defendant_search_breadth, "0")
     |> assign(:filter_phrases, "")}
  end

  @impl true
  def render(assigns) do
    if Map.get(assigns, :uploaded, false) do
      parsed_form(assigns)
    else
      upload_form(assigns)
    end
  end

  def upload_form(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
      </.header>

      <.simple_form for={@form} id="legal_document-form" phx-target={@myself} phx-change="validate">
        <.input field={@form[:file_name]} type="text" label="Document Name" />
        <.slider value={@plaintiff_search_breadth} title="Plaintiff Search Breadth" name="plaintiff" />
        <.slider value={@defendant_search_breadth} title="Defendant Search Breadth" name="defendant" />
        <.live_file_input upload={@uploads.file} />
      </.simple_form>
    </div>
    """
  end

  def parsed_form(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
      </.header>

      <.simple_form
        for={@form}
        id="legal_document-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:file_name]} type="text" label="Document Name" />
        <.slider value={@plaintiff_search_breadth} title="Plaintiff Search Breadth" name="plaintiff" />
        <.slider value={@defendant_search_breadth} title="Defendant Search Breadth" name="defendant" />
        <.opponents
          opponents={@plaintiffs}
          title={"Plaintiff(s) -------> (search breadth: #{@attempted_plaintiff_search_breadth})"}
        />
        <.opponents
          opponents={@defendants}
          title={"Defendant(s) -------> (search breadth: #{@attempted_defendant_search_breadth})"}
        />
        <div>
          <p>
            If you are getting false positives, you can filter out characters for this document using the input below.
          </p>
          <p>
            If you want to add or enable/disable global filters, visit
            <.link navigate={~p"/filter_phrases"} class="text-blue-500 hover:text-blue-700">
              Filter Phrases
            </.link>
            .
          </p>
        </div>
        <.input
          type="text"
          label="Filter Phrases"
          name="filter_phrases"
          value={@filter_phrases}
          phx-change="filter_phrases"
          placeholder="Case, SENSITIVE, words, separated, by, commas"
        />
        <:actions>
          <.button phx-disable-with="Retrying..." phx-click="retry" phx-target={@myself}>
            Retry
          </.button>
          <.button phx-disable-with="Saving...">Save Legal Document</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{legal_document: legal_document, action: :edit} = assigns, socket) do
    charlists = Jason.decode!(legal_document.parsed_strings)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:uploaded, true)
     |> assign(:charlists, charlists)
     |> assign(:plaintiffs, legal_document.plaintiffs)
     |> assign(:defendants, legal_document.defendants)
     |> assign(:attempted_plaintiff_search_breadth, legal_document.plaintiff_search_breadth)
     |> assign(:attempted_defendant_search_breadth, legal_document.defendant_search_breadth)
     |> assign_new(:form, fn ->
       to_form(LegalDocuments.change_legal_document(legal_document))
     end)}
  end

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
    changeset =
      LegalDocuments.change_legal_document(socket.assigns.legal_document, legal_document_params)

    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"legal_document" => legal_document}, socket) do
    plaintiffs =
      Enum.map(socket.assigns.plaintiffs, fn
        %Entity{id: id, name: name} -> %{id: id, name: name, type: "plaintiff"}
        plaintiff -> %{name: plaintiff, type: "plaintiff"}
      end)

    defendants =
      Enum.map(socket.assigns.defendants, fn
        %Entity{id: id, name: name} -> %{id: id, name: name, type: "defendant"}
        defendant -> %{name: defendant, type: "defendant"}
      end)

    legal_document_params =
      legal_document
      |> Map.put("plaintiffs", plaintiffs)
      |> Map.put("defendants", defendants)
      |> Map.put("parsed_strings", Jason.encode!(socket.assigns.charlists))
      |> Map.put(
        "plaintiff_search_breadth",
        socket.assigns.attempted_plaintiff_search_breadth
      )
      |> Map.put(
        "defendant_search_breadth",
        socket.assigns.attempted_defendant_search_breadth
      )

    save_legal_document(socket, socket.assigns.action, legal_document_params)
  end

  def handle_event("retry", _params, socket) do
    opts = get_opts_for_parser(socket.assigns)
    charlists = socket.assigns.charlists

    %{
      plaintiffs: plaintiffs,
      defendants: defendants,
      plaintiff_search_breadth: attempted_plaintiff_search_breadth,
      defendant_search_breadth: attempted_defendant_search_breadth
    } = DocumentParser.LegalDocuments.Parser.V1.get_plaintiffs_and_defendants(charlists, opts)

    {:noreply,
     socket
     |> assign(:attempted_plaintiff_search_breadth, attempted_plaintiff_search_breadth)
     |> assign(:attempted_defendant_search_breadth, attempted_defendant_search_breadth)
     |> assign(:plaintiffs, plaintiffs)
     |> assign(:defendants, defendants)
     |> assign(:uploaded, true)}
  end

  def handle_event("update_slider", %{"plaintiff" => search_breadth}, socket) do
    {:noreply, assign(socket, :plaintiff_search_breadth, search_breadth)}
  end

  def handle_event("update_slider", %{"defendant" => search_breadth}, socket) do
    {:noreply, assign(socket, :defendant_search_breadth, search_breadth)}
  end

  def handle_event("filter_phrases", %{"filter_phrases" => filter_phrases}, socket) do
    {:noreply, assign(socket, :filter_phrases, filter_phrases)}
  end

  def handle_progress(:file, entry, socket) do
    if entry.done? do
      %{
        charlists: charlists,
        plaintiffs: plaintiffs,
        defendants: defendants,
        plaintiff_search_breadth: attempted_plaintiff_search_breadth,
        defendant_search_breadth: attempted_defendant_search_breadth
      } =
        consume_uploaded_entry(socket, entry, fn %{path: path} ->
          opts = get_opts_for_parser(socket.assigns)

          opponents =
            DocumentParser.LegalDocuments.Parser.V1.get_plaintiffs_and_defendants(path, opts)

          {:ok, opponents}
        end)

      {:noreply,
       socket
       |> put_flash(:info, "file upload complete")
       |> assign(:uploaded, true)
       |> assign(:charlists, charlists)
       |> assign(:attempted_plaintiff_search_breadth, attempted_plaintiff_search_breadth)
       |> assign(:attempted_defendant_search_breadth, attempted_defendant_search_breadth)
       |> assign(:plaintiffs, plaintiffs)
       |> assign(:defendants, defendants)}
    else
      {:noreply, socket}
    end
  end

  defp get_opts_for_parser(assigns) do
    filter_phrases =
      String.split(assigns.filter_phrases, ", ", trim: true)

    plaintiff_search_breadth_override =
      String.to_integer(assigns.plaintiff_search_breadth)

    defendant_search_breadth_override =
      String.to_integer(assigns.defendant_search_breadth)

    %{
      filter_phrases: filter_phrases,
      plaintiff_search_breadth_override: plaintiff_search_breadth_override,
      defendant_search_breadth_override: defendant_search_breadth_override
    }
  end

  defp save_legal_document(socket, :edit, legal_document_params) do
    case LegalDocuments.update_legal_document(
           socket.assigns.legal_document,
           legal_document_params
         ) do
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
