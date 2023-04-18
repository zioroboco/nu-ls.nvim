local types = require("nu-ls.types")
local CompletionItemKind = types.CompletionItemKind

---@param params Params
---@param done fun(result: CompletionList[])
local handler = function(params, done)

  ---@type CompletionList
  local dummy_completions = {
    isIncomplete = true,
    items = {
      {
        label = "blep",
        kind = CompletionItemKind.Text,
      },
    },
  }

  done({
    dummy_completions,
  })

end

return {
  handler = handler,
}
