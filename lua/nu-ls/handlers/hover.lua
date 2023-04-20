local to_absolute_position = require("nu-ls.common").to_absolute_position

---@param params Params
---@param done fun(result: string[])
local handler = function(params, done)

  local cursor_position = to_absolute_position(params.row, params.col, params.bufname)
  local cmd_string = string.format("/usr/bin/env nu --ide-hover %d %s", cursor_position, params.bufname)

  local raw_nu_result = vim.fn.system(cmd_string)
  local nu_hover = vim.fn.json_decode(raw_nu_result).hover

  local hover_lines = {}
  for line in string.gmatch(nu_hover, "[^\n]+") do
    table.insert(hover_lines, line)
  end

  done(hover_lines)

end

return {
  handler = handler,
}
