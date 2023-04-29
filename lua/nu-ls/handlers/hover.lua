local to_absolute_position = require("nu-ls.common").to_absolute_position

---@param params Params
---@param done fun(result: string[])
local handler = function(params, done)

  local cursor_position = to_absolute_position(params.row, params.col, params.bufname)
  local cmd_string = string.format("/usr/bin/env nu --ide-hover %d %s", cursor_position, params.bufname)

  local raw_nu_result = vim.fn.system(cmd_string)

  if raw_nu_result ~= "" then
    local decoded_nu_result = vim.fn.json_decode(raw_nu_result)
    if decoded_nu_result then
      return done(vim.split(decoded_nu_result.hover or "", "\n"))
    end
  end

  vim.api.nvim_echo({{ "No hover information available", "WarningMsg" }}, true, {})
  return done({})

end

return {
  handler = handler,
}
