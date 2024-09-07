# DocumentParser

To start your Phoenix server:

  * Run `mix setup` to install and setup dependencies
  * Start Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

## User Story (LiveView Frontend)
https://github.com/user-attachments/assets/29c38f30-2fd4-4b2d-b6e6-250831d90ae4
1. Visit [`/legal_documents`](http://localhost:4000/legal_documents) and click on the new button
2. Type in a name for the document and upload an .xml file
3. Verify plaintiffs and defendants are correct
    1. If they are correct click save
    2. If they are not correct or are missing additional entities, increase search breadth and add filter phrases for the false positives

## JSON Endpoints

### Create a Legal Document
```
curl -X POST \
  -F "document_name=DocumentA" \
  -F "file=@C:\Path\To\Project\document_parser\test\support\fixtures\A.xml" \
  -F 'opts={"filter_phrases": "COMPLAINT, FOR, DAMAGES", "plaintiff_search_breadth_override": 1, "defendant_search_breadth_override": 1}' \
  localhost:4000/api/legal_documents/
```

returns:
```
{
  "data":
    {
      "id":1,
      "file_name":"DocumentA",
      "defendants":["HILL-ROM COMPANY INC"],
      "plaintiffs":["ANGELO ANGELES"],
      "attempted_plaintiff_search_breadth":9,
      "attempted_defendant_search_breadth":3
    }
}
```

### List all Legal Documents
```
curl -X GET localhost:4000/api/legal_documents/
```

returns:
```
{
  "data":
    [
      {
        "id":1,
        "file_name":"DocumentA",
        "defendants":["HILL-ROM COMPANY INC"],
        "plaintiffs":["ANGELO ANGELES"]
      }
    ]
}
```

### Update a Legal Document
```
curl -X PUT \
  -F "document_name=DocumentX" \
  -F 'opts={"filter_phrases": "COMPLAINT, FOR, DAMAGES", "plaintiff_search_breadth_override": 10, "defendant_search_breadth_override": 10}' \
  localhost:4000/api/legal_documents/1
```

returns:
```
{
  "data":
    {
      "id":1,
      "file_name":"DocumentX",
      "defendants":["HILL-ROM COMPANY INC"],
      "plaintiffs":["ANGELO ANGELES"],
      "attempted_plaintiff_search_breadth":10,
      "attempted_defendant_search_breadth":10
    }
}
```

### Get a Legal Document
```
curl -X GET localhost:4000/api/legal_documents/1
```

returns:
```
{
  "data":
    {
      "id":1,
      "file_name":"A",
      "defendants":["HILL-ROM COMPANY INC"],
      "plaintiffs":["ANGELO ANGELES"]
    }
}
```

### Delete a Legal Document
```
curl -X DELETE localhost:4000/api/legal_documents/1
```

## Challenges
* When the XML structure varies greatly or lacks a clear schema, it becomes difficult to write a static parsing script. The problem of determining names is likely best solved by a trained LLM or NER system that can understand context. Manually writing rules and parsers for each unique document is not scalable, especially if new formats or variations constantly emerge. This approach also requires multiple algorithms and continuous manual updates to handle edge cases, leading to high maintenance costs and inefficiencies.
* Trying to process a file as soon as it's uploaded via a `phx-change` and `handle_event` callback resulted in an error `cannot consume uploaded files when entries are still in progress`. This was solved by the `handle_progress/3` callback and checking `entry.done?` in the `FormComponent`.

## Algorithm
The algorithm (`DocumentParser.LegalDocuments.Parser.V1`) focuses on finding the opponent declaration, delimited by `vs.`, `vs`, or `v.`, and then searching phrases before and after the delimiter for words with at least 3 letters that are fully capitalized. An alternate strategy of searching the document for the words `plaintiff` and `defendant` was considered but was not used due to the number of possible edge cases and inconsistencies in the documents. 

## Future Features
* Include more versions of the parser with different algorithms that provide results on different documents that don't have the delimiter
* Allow user to edit the parsed plaintiffs or defendants manually in case there are small changes
* Allow user to upload the pdfs/images that represent the .xml structure being parsed to be displayed on the `show` page

## Thoughts in hindsight
* `parsed_strings` on `LegalDocument` should probably be called `parsed_charlists`
* `file_name` on `LegalDocument` should probably be called `document_name` to avoid confusion
* The `search_breadth` fields on a `LegalDocument` should probably reside on an `Entity`. This way, in the case of multiple plaintiffs/defendants, we could show the search breadth where the entity was found rather than the maximum breadth reached.

