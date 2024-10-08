# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     DocumentParser.Repo.insert!(%DocumentParser.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

["COMPLAINT", "FOR", "DAMAGES"]
|> Enum.each(fn word ->
  DocumentParser.Repo.insert!(%DocumentParser.FilterPhrases.FilterPhrase{word: word, enabled: true})
end)
