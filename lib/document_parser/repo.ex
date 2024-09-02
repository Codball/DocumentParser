defmodule DocumentParser.Repo do
  use Ecto.Repo,
    otp_app: :document_parser,
    adapter: Ecto.Adapters.Postgres
end
