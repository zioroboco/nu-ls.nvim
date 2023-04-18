local helpers = require("nu-ls.helpers")
local types = require("nu-ls.types")
local CompletionItemKind = types.CompletionItemKind

---@param params Params
---@param done fun(result: CompletionList[])
local handler = function(params, done)

  local cursor_position = helpers.get_cursor_position()
  local cmd_string = string.format("nu --ide-complete %d %s", cursor_position, params.bufname)

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
