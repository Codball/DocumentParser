defmodule DocumentParser.ParserTest do
  use DocumentParser.DataCase

  alias DocumentParser.LegalDocuments.Parser

  @fixtures_path "/test/support/fixtures/"

  test "Test A returns plaintiff and defendant" do
    filepath = File.cwd!() <> @fixtures_path <> "A.xml"

    %{plaintiffs: plaintiffs, defendants: defendants} =
      Parser.V1.get_plaintiffs_and_defendants(filepath)

    assert plaintiffs == ["ANGELO ANGELES"]
    assert defendants == ["HILL-ROM COMPANY INC"]
  end

  test "Test B returns plaintiff and defendant" do
    filepath = File.cwd!() <> @fixtures_path <> "B.xml"

    %{plaintiffs: plaintiffs, defendants: defendants} =
      Parser.V1.get_plaintiffs_and_defendants(filepath)

    assert plaintiffs == ["KUSUMA AMBELGAR"]
    assert defendants == ["THIRUMALLAILLC"]
  end

  test "Test C returns plaintiff and defendant" do
    filepath = File.cwd!() <> @fixtures_path <> "C.xml"

    %{plaintiffs: plaintiffs, defendants: defendants} =
      Parser.V1.get_plaintiffs_and_defendants(filepath)

    assert plaintiffs == ["ALBA ALVARADO"]
    assert defendants == ["LAGUARDIA ENTERPRISES INC"]
  end
end
