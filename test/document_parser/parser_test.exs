defmodule DocumentParser.ParserTest do
  use DocumentParser.DataCase

  alias DocumentParser.LegalDocuments.Parser
  alias DocumentParser.FilterPhrases.FilterPhrase

  @fixtures_path "/test/support/fixtures/"

  describe "Parsing test Document A" do
    setup %{insert_phrases: insert_phrases} = context do
      if insert_phrases do
        Repo.insert(%FilterPhrase{word: "COMPLAINT", enabled: true})
        Repo.insert(%FilterPhrase{word: "FOR", enabled: true})
      end

      {:ok, context}
    end

    @tag insert_phrases: true
    test "returns plaintiff and defendant using global filters" do
      filepath = get_fixture_filepath("A.xml")

      %{plaintiffs: plaintiffs, defendants: defendants} =
        Parser.V1.get_plaintiffs_and_defendants(filepath)

      assert plaintiffs == ["ANGELO ANGELES"]
      assert defendants == ["HILL-ROM COMPANY INC"]
    end

    @tag insert_phrases: false
    test "returns wrong plaintiff without global filters" do
      filepath = get_fixture_filepath("A.xml")

      %{plaintiffs: plaintiffs, defendants: defendants} =
        Parser.V1.get_plaintiffs_and_defendants(filepath)

      assert plaintiffs == ["COMPLAINT FOR"]
      assert defendants == ["HILL-ROM COMPANY INC"]
    end
  end

  describe "Parsing test Document B" do
    test "returns plaintiff and defendant using filter opts" do
      filepath = get_fixture_filepath("B.xml")
      opts = %{filter_phrases: ["COMPLAINT", "FOR", "DAMAGES"]}

      %{plaintiffs: plaintiffs, defendants: defendants} =
        Parser.V1.get_plaintiffs_and_defendants(filepath, opts)

        assert plaintiffs == ["KUSUMA AMBELGAR"]
        assert defendants == ["THIRUMALLAILLC"]
    end

    test "returns wrong plaintiff without filter_phrases" do
      filepath = get_fixture_filepath("B.xml")

      %{plaintiffs: plaintiffs, defendants: defendants} =
        Parser.V1.get_plaintiffs_and_defendants(filepath)

        assert plaintiffs == ["COMPLAINT FOR DAMAGES"]
        assert defendants == ["THIRUMALLAILLC"]
    end
  end

  describe "Parsing test Document C" do
    test "returns plaintiff and defendant" do
      filepath = get_fixture_filepath("C.xml")

      %{plaintiffs: plaintiffs, defendants: defendants} =
        Parser.V1.get_plaintiffs_and_defendants(filepath)

      assert plaintiffs == ["ALBA ALVARADO"]
      assert defendants == ["LAGUARDIA ENTERPRISES INC"]
    end

    test "returns additional defendant with increased search_breadth" do
      filepath = get_fixture_filepath("C.xml")

      opts = %{defendant_search_breadth_override: 1}

      %{plaintiffs: plaintiffs, defendants: defendants} =
        Parser.V1.get_plaintiffs_and_defendants(filepath, opts)

      assert plaintiffs == ["ALBA ALVARADO"]
      assert defendants == ["LAGUARDIA ENTERPRISES INC", "SONSONATE"]
    end
  end

  defp get_fixture_filepath(file_name) do
    File.cwd!() <> @fixtures_path <> file_name
  end
end
