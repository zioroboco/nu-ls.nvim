local types = require("nu-ls.types")
local CompletionItemKind = types.CompletionItemKind

local to_absolute_position = require("nu-ls.common").to_absolute_position

---@param params Params
---@param done fun(result: CompletionList[])
local handler = function(params, done)

  local cursor_position = to_absolute_position(params.row, params.col, params.bufname)
  local cmd_string = string.format("/usr/bin/env nu --ide-complete %d %s", cursor_position, params.bufname)

  local cmd_status, nu_result = pcall(vim.fn.system, cmd_string)
  if not cmd_status then
    vim.api.nvim_err_writeln("nu-ls: error calling nu binary")
    return done({})
  end

  local decode_status, decoded_nu_result = pcall(vim.fn.json_decode, nu_result)
  if not decode_status or not decoded_nu_result or not decoded_nu_result.completions then
    -- currently suppressing an error introduced by the debounce timer
    -- tracking in: https://github.com/zioroboco/nu-ls.nvim/issues/10
    -- vim.api.nvim_err_writeln(string.format("nu-ls: unexpected response from nu binary:\n    %s", nu_result))
    return done({})
  end

  local items = {}
  for _, completion in ipairs(decoded_nu_result.completions) do
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
