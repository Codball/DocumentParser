defmodule DocumentParserWeb.FilterPhraseLive.FormComponent do
  use DocumentParserWeb, :live_component

  alias DocumentParser.FilterPhrases

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
        <:subtitle>Use this form to manage filter_phrase records in your database.</:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="filter_phrase-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:word]} type="text" label="Word" />
        <.input field={@form[:enabled]} type="checkbox" label="Enabled" />
        <:actions>
          <.button phx-disable-with="Saving...">Save Filter phrase</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{filter_phrase: filter_phrase} = assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign_new(:form, fn ->
       to_form(FilterPhrases.change_filter_phrase(filter_phrase))
     end)}
  end

  @impl true
  def handle_event("validate", %{"filter_phrase" => filter_phrase_params}, socket) do
    changeset = FilterPhrases.change_filter_phrase(socket.assigns.filter_phrase, filter_phrase_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"filter_phrase" => filter_phrase_params}, socket) do
    save_filter_phrase(socket, socket.assigns.action, filter_phrase_params)
  end

  defp save_filter_phrase(socket, :edit, filter_phrase_params) do
    case FilterPhrases.update_filter_phrase(socket.assigns.filter_phrase, filter_phrase_params) do
      {:ok, filter_phrase} ->
        notify_parent({:saved, filter_phrase})

        {:noreply,
         socket
         |> put_flash(:info, "Filter phrase updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_filter_phrase(socket, :new, filter_phrase_params) do
    case FilterPhrases.create_filter_phrase(filter_phrase_params) do
      {:ok, filter_phrase} ->
        notify_parent({:saved, filter_phrase})

        {:noreply,
         socket
         |> put_flash(:info, "Filter phrase created successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
