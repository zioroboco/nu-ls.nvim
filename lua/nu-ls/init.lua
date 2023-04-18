local null_ls = require("null-ls")

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
  name = "nu-ls",
  filetypes = { "nu" },
  method = { null_ls.methods.COMPLETION },
  generator = {
    async = true,
    fn = handler,
  }
}
