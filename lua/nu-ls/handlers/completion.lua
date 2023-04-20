local types = require("nu-ls.types")
local CompletionItemKind = types.CompletionItemKind

local to_absolute_position = require("nu-ls.common").to_absolute_position

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
