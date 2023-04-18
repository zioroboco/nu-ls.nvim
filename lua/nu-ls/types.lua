-- null-ls params for a completion provider (approx.) {{{
--   see: https://github.com/jose-elias-alvarez/null-ls.nvim/blob/main/doc/MAIN.md#params
---@class Params
---@field client_id number null-ls client id
---@field lsp_method string LSP method that triggered request / notification
---@field lsp_params table original LSP params from request / notification
---@field options table|nil options from LSP params
---@field content string[] current buffer content
---@field bufnr number current buffer's number
---@field method string null-ls method
---@field row number cursor's current row
---@field col number cursor's current column
---@field bufname string full path to current buffer
---@field filetype string current buffer's filetype
---@field root string current buffer's root directory
---@field word_to_complete string keyword under cursor
-- }}}

-- language server protocol completion list type (approx.) {{{
--   see: https://microsoft.github.io/language-server-protocol/specifications/specification-current
---@class CompletionList
---@field isIncomplete boolean This list is not complete. Further typing should result in recomputing this list.
---@field itemDefaults table A table containing default values for completion items.
---@field items CompletionItem[] The completion items.

---@class Range
---@field start Position The range's start position.
---@field end Position The range's end position.

---@class Position
---@field line number Line position in a document (zero-based).
---@field character number Character offset on a line in a document (zero-based).

---@class CompletionItem
---@field label string The label of this completion item.
---@field labelDetails table Additional details for the label.
---@field kind CompletionItemKind The kind of this completion item.
---@field tags number[] Tags for this completion item.
---@field detail string A human-readable string with additional information about this item.
---@field documentation string|MarkupContent A human-readable string that represents a doc-comment.
---@field deprecated boolean Indicates if this item is deprecated.
---@field preselect boolean Select this item when showing.
---@field sortText string A string that should be used when comparing this item with other items.
---@field filterText string A string that should be used when filtering a set of completion items.
---@field insertText string A string that should be inserted into a document when selecting this completion.
---@field insertTextFormat number The format of the insert text.
---@field insertTextMode number How whitespace and indentation is handled during completion item insertion.
---@field textEdit TextEdit|InsertReplaceEdit An edit which is applied to a document when selecting this completion.
---@field textEditText string The edit text used if the completion item is part of a CompletionList and CompletionList defines an item default for the text edit range.
---@field additionalTextEdits TextEdit[] An optional array of additional text edits that are applied when selecting this completion.
---@field commitCharacters string[] An optional set of characters that when pressed while this completion is active will accept it first and then type that character.
---@field command Command An optional command that is executed after inserting this completion.
---@field data LSPAny A data entry field that is preserved on a completion item between a completion and a completion resolve request.

---@class MarkupContent
---@field kind "plaintext"|"markdown" The type of the Markup.
---@field value string The content itself.

---@alias LSPAny any
---@alias TextEdit any
---@alias InsertReplaceEdit any
-- }}}

-- language server protocol completion type enum {{{
---@enum CompletionItemKind
local CompletionItemKind = {
    Text = 1,
    Method = 2,
    Function = 3,
    Constructor = 4,
    Field = 5,
    Variable = 6,
    Class = 7,
    Interface = 8,
    Module = 9,
    Property = 10,
    Unit = 11,
    Value = 12,
    Enum = 13,
    Keyword = 14,
    Snippet = 15,
    Color = 16,
    File = 17,
    Reference = 18,
    Folder = 19,
    EnumMember = 20,
    Constant = 21,
    Struct = 22,
    Event = 23,
    Operator = 24,
    TypeParameter = 25,
}
-- }}}

return {
  CompletionItemKind = CompletionItemKind,
}
