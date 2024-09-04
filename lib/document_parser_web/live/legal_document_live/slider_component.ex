defmodule DocumentParserWeb.LegalDocumentLive.SliderComponent do
  use DocumentParserWeb, :live_component

  def render(assigns) do
    ~H"""
    <div>
      <label for="slider"><%= @title %>: <%= @value %></label>
      <.input
        field={@field}
        id="slider"
        type="range"
        min="1"
        max="20"
        value={@value}
        phx-change="update_slider"
        phx-value-value={@value}
        name={@name}
      />
    </div>
    """
  end
  # phx-target={@myself}

  def update(assigns, socket) do
    {:ok,
    socket
    |> assign(:title, assigns[:title] || "Slider")
    |> assign(:value, assigns[:value] || 10)
    |> assign(:field, assigns[:field] || "form_field")
    |> assign(:name, assigns[:name] || "name")
  }
  end
end
