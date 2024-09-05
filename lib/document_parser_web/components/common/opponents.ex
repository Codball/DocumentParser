defmodule DocumentParserWeb.Components.Common.Opponents do
  use Phoenix.Component
  import DocumentParserWeb.CoreComponents, only: [list: 1]

  def opponents(assigns) do
    ~H"""
      <div class="space-y-0">
        <.list>
          <:item title={@title}>
            <%= for opponent <- @opponents do %>
              <p><%= opponent %></p>
            <% end %>
          </:item>
        </.list>
      </div>
    """
  end
end
