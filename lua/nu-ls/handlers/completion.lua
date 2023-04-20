local types = require("nu-ls.types")
local CompletionItemKind = types.CompletionItemKind

local to_absolute_position = require("nu-ls.common").to_absolute_position

---@param params Params
---@param done fun(result: CompletionList[])
local handler = function(params, done)

  -- we can't read the data from stdin (nu is expecting a file path), but we
  -- also don't want to have to write our modified bufer to disk (to provide
  -- up-to-date cursor positions, etc.) every time we want completions... so
  -- we're making a copy of the current buffer, and pointing nu at that
  local temp_file = vim.fn.tempname()
  vim.fn.writefile(vim.api.nvim_buf_get_lines(params.bufnr, 0, -1, false), temp_file)

  local cursor_position = to_absolute_position(params.row, params.col, temp_file)
  local cmd_string = string.format("/usr/bin/env nu --ide-complete %d %s", cursor_position, temp_file)

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

  -- clean up the temp file
  vim.fn.delete(temp_file)

end

return {
  handler = handler,
}
