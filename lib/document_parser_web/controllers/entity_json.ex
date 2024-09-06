defmodule DocumentParserWeb.EntityJSON do
  @doc """
  Renders a list of entities.
  """
  def list(entities) do
    for(entity <- entities, do: entity.name)
  end
end
