defmodule DocumentParserWeb.Components.Common.Opponents do
  use Phoenix.Component
  import DocumentParserWeb.CoreComponents, only: [list: 1]

  alias DocumentParser.Entity

  def opponents(assigns) do
    ~H"""
    <div class="space-y-0">
      <.list>
        <:item title={@title}>
        <%= for opponent <- map_opponents(@opponents) do %>
          <p><%= opponent %></p>
        <% end %>
        </:item>
      </.list>
    </div>
    """
  end

  def map_opponents(opponents) do
    Enum.map(opponents, fn
      %Entity{name: name} -> name
      opponent -> opponent
    end)
  end
end
