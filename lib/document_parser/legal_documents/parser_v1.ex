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

      iex> DocumentParser.LegalDocuments.Parser.V1.get_plaintiffs_and_defendants(["MOLLY SMITH", "vs", "COMPANY LLC"], %{plaintiff_search_breadth_override: 5})
      %{plaintiffs: ["MOLLY SMITH"], defendants: ["COMPANY LLC"], charlists: ["MOLLY SMITH", "vs", "COMPANY LLC"]}

      iex> DocumentParser.LegalDocuments.Parser.V1.get_plaintiffs_and_defendants("path/to/file.txt", %{})
      %{plaintiffs: ["Plaintiff A"], defendants: ["Defendant B"], charlists: ["Plaintiff A", "v.", "Defendant B"]}
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

  def read_file(filepath) do
    filepath
    |> File.read!()
    |> xpath(~x"//block/text//formatting/text()"l)
  end


  defp process_charlists(charlists, opts) do
    midpoint_index = find_opponent_midpoint_index(charlists)

    find_plaintiffs_and_defendants(charlists, midpoint_index, opts)
  end

  defp find_opponent_midpoint_index(charlists) do
    Enum.find_index(charlists, fn charlist ->
      Enum.any?(@opponent_delimiters, fn delimiter ->
        :lists.prefix(delimiter, charlist)
      end)
    end)
  end

  defp find_plaintiffs_and_defendants(charlists, nil, _opts) do
    %{
      charlists: charlists,
      plaintiffs: [],
      defendants: [],
      plaintiff_search_breadth: 0,
      defendant_search_breadth: 0
    }
  end

  defp find_plaintiffs_and_defendants(charlists, midpoint_index, opts) do
    filter_phrases =
      DocumentParser.FilterPhrases.list_enabled_filter_phrases() ++
        Map.get(opts, :filter_phrases, [])

    plaintiff_search_breadth = Map.get(opts, :plaintiff_search_breadth_override, 0) - 1

    plaintiff_config = %{
      midpoint_index: midpoint_index,
      filter_phrases: filter_phrases,
      opponent_type: :plaintiff,
      search_breadth_override: plaintiff_search_breadth
    }

    {plaintiffs, attempted_plaintiff_search_breadth} = find_opponents(charlists, plaintiff_config)

    defendant_search_breadth = Map.get(opts, :defendant_search_breadth_override, 0) - 1

    defendant_config = %{
      midpoint_index: midpoint_index,
      filter_phrases: filter_phrases,
      opponent_type: :defendant,
      search_breadth_override: defendant_search_breadth
    }

    {defendants, attempted_defendant_search_breadth} = find_opponents(charlists, defendant_config)

    %{
      charlists: charlists,
      plaintiffs: plaintiffs,
      defendants: defendants,
      plaintiff_search_breadth: attempted_plaintiff_search_breadth,
      defendant_search_breadth: attempted_defendant_search_breadth
    }
  end

  defp find_opponents(
         charlists,
         config,
         search_breadth \\ 0,
         opponents \\ []
       )

  defp find_opponents(
         _charlists,
         _config,
         search_breadth,
         opponents
       )
       when search_breadth >= @max_search_breadth,
       do: {opponents, search_breadth}

  defp find_opponents(
         charlists,
         %{
           midpoint_index: midpoint_index,
           filter_phrases: filter_phrases,
           opponent_type: opponent_type,
         } = config,
         search_breadth,
         opponents
       ) do
    possible_index =
      get_next_possible_opponent_index(opponent_type, midpoint_index, search_breadth)

    charlists
    |> Enum.at(possible_index)
    |> then(&Regex.scan(~r/\b[A-Z-]{3,}\b/, to_string(&1)))
    |> filter_scan(filter_phrases)
    |> handle_match(charlists, config, search_breadth, opponents)
  end

  defp handle_match("" = _match, charlists, config, search_breadth, opponents) do
    find_opponents(charlists, config, search_breadth + 1, opponents)
  end

  defp handle_match(
         match,
         _charlists,
         %{search_breadth_override: -1},
         search_breadth,
         _opponents
       ) do
    {[match], search_breadth}
  end

  defp handle_match(
         match,
         charlists,
         %{search_breadth_override: search_breadth_override} = config,
         search_breadth,
         opponents
       )
       when search_breadth <= search_breadth_override do
    find_opponents(charlists, config, search_breadth + 1, opponents ++ [match])
  end

  defp handle_match(match, _charlists, _config, search_breadth, opponents),
    do: {opponents ++ [match], search_breadth}

  defp get_next_possible_opponent_index(:plaintiff, midpoint_index, search_breadth) do
    midpoint_index - search_breadth - 1
  end

  defp get_next_possible_opponent_index(:defendant, midpoint_index, search_breadth) do
    midpoint_index + search_breadth + 1
  end

  def filter_scan(scan, filter_phrases) do
    scan
    |> List.flatten()
    |> Enum.reject(fn match ->
      match in filter_phrases
    end)
    |> Enum.reject(fn opponent ->
      opponent == [] || opponent == ""
    end)
    |> Enum.join(" ")
  end
end
