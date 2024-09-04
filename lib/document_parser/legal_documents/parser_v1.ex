defmodule DocumentParser.LegalDocuments.Parser.V1 do
  import SweetXml

  @opponent_delimiters [
    ~c"vs.",
    ~c"vs",
    ~c"v."
  ]

  def get_plaintiffs_and_defendants(filepath) do
    charlists = read_file(filepath)
    midpoint_index = find_opponent_midpoint_index(charlists)

    %{plaintiffs: _plaintiff, defendants: _defendant} =
      find_plaintiffs_and_defendants(charlists, midpoint_index)
  end

  defp read_file(filepath) do
    filepath
    |> File.read!()
    |> xpath(~x"//block/text//formatting/text()"l)
  end

  defp find_opponent_midpoint_index(charlists) do
    Enum.find_index(charlists, fn charlist ->
      Enum.any?(@opponent_delimiters, fn delimiter ->
        :lists.prefix(delimiter, charlist)
      end)
    end)
  end

  defp find_plaintiffs_and_defendants(charlists, midpoint_index) do
    filter_phrases = DocumentParser.FilterPhrases.list_enabled_filter_phrases()

    plaintiffs = find_opponents(charlists, midpoint_index, filter_phrases, :plaintiff)
    defendants = find_opponents(charlists, midpoint_index, filter_phrases, :defendant)

    %{plaintiffs: plaintiffs, defendants: defendants}
  end

  defp find_opponents(charlists, midpoint_index, filter_phrases, opponent_type, search_breadth \\ 1)

  defp find_opponents(_charlists, _midpoint_index, _filter_phrases, _opponent_type, 15), do: []

  defp find_opponents(charlists, midpoint_index, filter_phrases, opponent_type, search_breadth) do
    range = get_opponent_range(opponent_type, midpoint_index, search_breadth)

    charlists
    |> Enum.slice(range)
    |> Enum.map(fn charlist ->
      Regex.scan(~r/\b[A-Z-]{3,}\b/, to_string(charlist))
    end)
    |> filter_scans(filter_phrases)
    |> case do
      [] -> find_opponents(charlists, midpoint_index, filter_phrases, opponent_type, search_breadth + 1)
      matches -> matches
    end
  end

  defp get_opponent_range(:plaintiff, midpoint_index, search_breadth),
    do: (midpoint_index - search_breadth)..(midpoint_index - 1)

  defp get_opponent_range(:defendant, midpoint_index, search_breadth),
    do: (midpoint_index + 1)..(midpoint_index + search_breadth)

  def filter_scans(scans, filter_phrases) do
    scans
    |> Enum.map(fn scan ->
      scan
      |> List.flatten()
      |> Enum.filter(fn match ->
        match not in filter_phrases
      end)
      |> Enum.join(" ")
    end)
    |> Enum.reject(fn opponent ->
      opponent == [] || opponent == ""
    end)
  end
end
