defmodule DocumentParser.LegalDocumentsTest do
  use DocumentParser.DataCase

  alias DocumentParser.LegalDocuments

  describe "legal_documents" do
    alias DocumentParser.LegalDocuments.LegalDocument

    import DocumentParser.LegalDocumentsFixtures

    @invalid_attrs %{file_name: nil, parsed_strings: nil}

    test "list_legal_documents/0 returns all legal_documents" do
      legal_document = legal_document_fixture()
      assert LegalDocuments.list_legal_documents() == [legal_document]
    end

    test "get_legal_document!/1 returns the legal_document with given id" do
      legal_document = legal_document_fixture()
      assert LegalDocuments.get_legal_document!(legal_document.id) == legal_document
    end

    test "create_legal_document/1 with valid data creates a legal_document" do
      valid_attrs = %{file_name: "some file_name", parsed_strings: "some parsed_strings"}

      assert {:ok, %LegalDocument{} = legal_document} = LegalDocuments.create_legal_document(valid_attrs)
      assert legal_document.file_name == "some file_name"
      assert legal_document.parsed_strings == "some parsed_strings"
    end

    test "create_legal_document/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = LegalDocuments.create_legal_document(@invalid_attrs)
    end

    test "update_legal_document/2 with valid data updates the legal_document" do
      legal_document = legal_document_fixture()
      update_attrs = %{file_name: "some updated file_name", parsed_strings: "some updated parsed_strings"}

      assert {:ok, %LegalDocument{} = legal_document} = LegalDocuments.update_legal_document(legal_document, update_attrs)
      assert legal_document.file_name == "some updated file_name"
      assert legal_document.parsed_strings == "some updated parsed_strings"
    end

    test "update_legal_document/2 with invalid data returns error changeset" do
      legal_document = legal_document_fixture()
      assert {:error, %Ecto.Changeset{}} = LegalDocuments.update_legal_document(legal_document, @invalid_attrs)
      assert legal_document == LegalDocuments.get_legal_document!(legal_document.id)
    end

    test "delete_legal_document/1 deletes the legal_document" do
      legal_document = legal_document_fixture()
      assert {:ok, %LegalDocument{}} = LegalDocuments.delete_legal_document(legal_document)
      assert_raise Ecto.NoResultsError, fn -> LegalDocuments.get_legal_document!(legal_document.id) end
    end

    test "change_legal_document/1 returns a legal_document changeset" do
      legal_document = legal_document_fixture()
      assert %Ecto.Changeset{} = LegalDocuments.change_legal_document(legal_document)
    end
  end
end
