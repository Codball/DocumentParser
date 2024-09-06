defmodule DocumentParserWeb.Components.Common.Slider do
  use Phoenix.Component
  import DocumentParserWeb.CoreComponents, only: [input: 1]

  def slider(assigns) do
    ~H"""
    <div>
      <label for="slider"><%= @title %>: <%= @value %></label>
      <.input
        id={@title}
        type="range"
        min={0}
        max={20}
        value={@value}
        phx-change="update_slider"
        phx-value-value={@value}
        name={@name}
      />
    </div>
    """
  end
end
