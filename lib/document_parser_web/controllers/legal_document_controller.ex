defmodule DocumentParserWeb.LegalDocumentController do
  use DocumentParserWeb, :controller

  alias DocumentParser.LegalDocuments
  alias DocumentParser.LegalDocuments.LegalDocument
  alias DocumentParser.LegalDocuments.Parser

  action_fallback DocumentParserWeb.FallbackController

  def index(conn, _params) do
    legal_documents = LegalDocuments.list_legal_documents()
    render(conn, :index, legal_documents: legal_documents)
  end

  def create(conn, %{
        "document_name" => document_name,
        "file" => %Plug.Upload{path: path},
        "opts" => opts_json
      }) do
    opts = parse_opts(opts_json)

    %{
      plaintiffs: plaintiffs,
      defendants: defendants,
      plaintiff_search_breadth: attempted_plaintiff_search_breadth,
      defendant_search_breadth: attempted_defendant_search_breadth,
      charlists: charlists
    } = Parser.V1.get_plaintiffs_and_defendants(path, opts)

    plaintiff_entities =
      Enum.map(plaintiffs, fn plaintiff ->
        %{name: plaintiff, type: "plaintiff"}
      end)

    defendant_entities =
      Enum.map(defendants, fn defendant ->
        %{name: defendant, type: "defendant"}
      end)

    legal_document_params = %{
      file_name: document_name,
      parsed_strings: Jason.encode!(charlists),
      entities: plaintiff_entities ++ defendant_entities
    }

    with {:ok, %LegalDocument{} = legal_document} <-
           LegalDocuments.create_legal_document(legal_document_params) do
      preloaded_legal_document =
        DocumentParser.Repo.preload(legal_document, [:plaintiffs, :defendants])

      conn
      |> put_status(:created)
      |> put_resp_header("location", ~p"/api/legal_documents/#{legal_document}")
      |> render(:show,
        legal_document: preloaded_legal_document,
        attempted_plaintiff_search_breadth: attempted_plaintiff_search_breadth,
        attempted_defendant_search_breadth: attempted_defendant_search_breadth
      )
    end
  end

  def create(conn, %{"legal_document" => legal_document_params}) do
    with {:ok, %LegalDocument{} = legal_document} <-
           LegalDocuments.create_legal_document(legal_document_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", ~p"/api/legal_documents/#{legal_document}")
      |> render(:show, legal_document: legal_document)
    end
  end

  def show(conn, %{"id" => id}) do
    legal_document = LegalDocuments.get_legal_document!(id)
    render(conn, :show, legal_document: legal_document)
  end

  def update(conn, %{"id" => id, "document_name" => document_name, "opts" => opts_json}) do
    legal_document = LegalDocuments.get_legal_document!(id) |> DocumentParser.Repo.preload(:entities)
    charlists = Jason.decode!(legal_document.parsed_strings)
    opts = parse_opts(opts_json)

    %{
      plaintiffs: plaintiffs,
      defendants: defendants,
      plaintiff_search_breadth: attempted_plaintiff_search_breadth,
      defendant_search_breadth: attempted_defendant_search_breadth,
      charlists: charlists
    } = Parser.V1.get_plaintiffs_and_defendants(charlists, opts)

    plaintiff_entities =
      Enum.map(plaintiffs, fn plaintiff ->
        %{name: plaintiff, type: "plaintiff"}
      end)

    defendant_entities =
      Enum.map(defendants, fn defendant ->
        %{name: defendant, type: "defendant"}
      end)

    legal_document_params = %{
      file_name: document_name,
      parsed_strings: Jason.encode!(charlists),
      entities: plaintiff_entities ++ defendant_entities
    }

    with {:ok, %LegalDocument{} = legal_document} <-
           LegalDocuments.update_legal_document(legal_document, legal_document_params) do
      render(conn, :show,
        legal_document: legal_document,
        attempted_plaintiff_search_breadth: attempted_plaintiff_search_breadth,
        attempted_defendant_search_breadth: attempted_defendant_search_breadth
      )
    end
  end

  def delete(conn, %{"id" => id}) do
    legal_document = LegalDocuments.get_legal_document!(id)

    with {:ok, %LegalDocument{}} <- LegalDocuments.delete_legal_document(legal_document) do
      send_resp(conn, :no_content, "")
    end
  end

  defp parse_opts(opts_json) do
    opts_json
    |> Jason.decode!()
    |> Enum.map(fn
      {"filter_phrases", string} -> {:filter_phrases, String.split(string, ", ")}
      {key, value} -> {String.to_atom(key), value}
    end)
    |> Map.new()
  end
end
