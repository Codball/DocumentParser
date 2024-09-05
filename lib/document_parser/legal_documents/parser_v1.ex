defmodule DocumentParser.LegalDocuments.Parser.V1 do
  import SweetXml

  @opponent_delimiters [
    ~c"vs.",
    ~c"vs",
    ~c"v."
  ]

  @max_search_breadth 21

  @moduledoc """
  Provides functions to extract and identify plaintiffs and defendants from a list of character lists or a file.

  This module defines a function, `get_plaintiffs_and_defendants/2`, which takes either a list of character lists
  or a .xml file path as input and a map containing options, and returns a map containing plaintiffs and defendants extracted from the input. The input
  is analyzed to determine the midpoint separating plaintiffs from defendants, and the results are returned as a
  structured map. The parsed charlists are returned for persistance purposes.

  Currently supported options:
  %{
    plaintiff_search_breadth_override: :integer
    defendant_search_breadth_override: :integer
  }

  The search_breadth_override options are provided to tell the parser there are more defendants or plaintiffs than it picked up, otherwise it will just find the first detected and return it.

  ## Functions

    * `get_plaintiffs_and_defendants/2` - Processes either a list of character lists or a file path to extract
      plaintiffs and defendants, returning the result as a map.

  ## Examples

      iex> DocumentParser.LegalDocuments.Parser.V1.get_plaintiffs_and_defendants(["MOLLY SMITH", "vs", "COMPANY LLC"], %{search_breadth_override: 5})
      %{plaintiffs: ["MOLLY SMITH"], defendants: ["COMPANY LLC"], charlists: ["MOLLY SMITH", "vs", "COMPANY LLC"]}

      iex> DocumentParser.LegalDocuments.Parser.V1.get_plaintiffs_and_defendants("path/to/file.txt", %{})
      %{plaintiffs: ["Plaintiff A"], defendants: ["Defendant B"], charlists: ["Plaintiff A", "Defendant B"]}
  """

  @spec get_plaintiffs_and_defendants(list(char()) | String.t(), map()) :: %{
          charlists: list(char()),
          plaintiffs: list(String.t()),
          defendants: list(String.t()),
          plaintiff_search_breadth: integer(),
          defendant_search_breadth: integer()
        }
  def get_plaintiffs_and_defendants(charlists_or_filepath, opts \\ %{})

  def get_plaintiffs_and_defendants(charlists, opts) when is_list(charlists),
    do: process_charlists(charlists, opts)

  def get_plaintiffs_and_defendants(filepath, opts)
      when is_binary(filepath) do
    charlists = read_file(filepath)
    process_charlists(charlists, opts)
  end

  defp process_charlists(charlists, opts) do
    midpoint_index = find_opponent_midpoint_index(charlists)

    find_plaintiffs_and_defendants(charlists, midpoint_index, opts)
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

  defp find_plaintiffs_and_defendants(charlists, midpoint_index, opts) do
    filter_phrases = DocumentParser.FilterPhrases.list_enabled_filter_phrases() ++ Map.get(opts, :filter_phrases, [])

    plaintiff_search_breadth = Map.get(opts, :plaintiff_search_breadth_override, 1)

    {plaintiffs, attempted_plaintiff_search_breadth} =
      find_opponents(
        charlists,
        midpoint_index,
        filter_phrases,
        :plaintiff,
        plaintiff_search_breadth
      )

    defendant_search_breadth = Map.get(opts, :defendant_search_breadth_override, 1)

    {defendants, attempted_defendant_search_breadth} =
      find_opponents(
        charlists,
        midpoint_index,
        filter_phrases,
        :defendant,
        defendant_search_breadth
      )

    %{
      charlists: charlists,
      plaintiffs: plaintiffs,
      defendants: defendants,
      plaintiff_search_breadth: attempted_plaintiff_search_breadth,
      defendant_search_breadth: attempted_defendant_search_breadth
    }
  end

  defp find_opponents(
         _charlists,
         _midpoint_index,
         _filter_phrases,
         _opponent_type,
         search_breadth
       )
       when search_breadth >= @max_search_breadth,
       do: {[], search_breadth}

  defp find_opponents(charlists, midpoint_index, filter_phrases, opponent_type, search_breadth) do
    range = get_opponent_range(opponent_type, midpoint_index, search_breadth)

    charlists
    |> Enum.slice(range)
    |> Enum.map(fn charlist ->
      Regex.scan(~r/\b[A-Z-]{3,}\b/, to_string(charlist))
    end)
    |> filter_scans(filter_phrases)
    |> case do
      [] ->
        find_opponents(
          charlists,
          midpoint_index,
          filter_phrases,
          opponent_type,
          search_breadth + 1
        )

      matches ->
        {matches, search_breadth}
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
