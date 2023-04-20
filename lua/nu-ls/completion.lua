local types = require("nu-ls.types")
local CompletionItemKind = types.CompletionItemKind

-- The cursor position passed from null-ls has a 1-indexed row (line) and a
-- 0-indexed column (think: caret position). Meanwhile, the nushell binary is
-- instead expecting a integer number of _characters deep into the file_.
---@param row number The 1-indexed row (line) of the cursor
---@param col number The 0-indexed column (caret position) of the cursor
---@param path string The path to the file
---@return integer rv The number of characters deep the cursor is into the file
local to_absolute_position = function(row, col, path)
  local cmd_string = string.format("awk -v line=%d -v col=%d 'NR < line { chars += length($0) + 1 } NR == line { chars += col; print chars; exit }' %s", row, col, path)
  return tonumber(vim.fn.system(cmd_string)) or 0
end

---@param params Params
---@param done fun(result: CompletionList[])
local handler = function(params, done)

  local cursor_position = to_absolute_position(params.row, params.col, params.bufname)
  local cmd_string = string.format("/usr/bin/env nu --ide-complete %d %s", cursor_position, params.bufname)

  local raw_nu_result = vim.fn.system(cmd_string)
  local nu_completions = vim.fn.json_decode(raw_nu_result).completions

  local items = {}
  for _, completion in ipairs(nu_completions) do
    table.insert(items, {
      label = completion,
      kind = CompletionItemKind.Text,
    })
  end

  done({
    {
      isIncomplete = true,
      items = items,
    },
  })

end

return {
  handler = handler,
}
