local from_absolute_position = require("nu-ls.common").from_absolute_position
local to_absolute_position   = require("nu-ls.common").to_absolute_position

---@param line string A single line of output from `nu --ide-check ...`
---@param params Params The null-ls params table
---@return Diagnostic | nil
local parse_line = function(line, params)

  if line == "" then
    return nil
  end

  ---@type NuDiagnostic | nil
  local nu_diagnostic = vim.fn.json_decode(line)

  if nu_diagnostic == nil or nu_diagnostic.type ~= "diagnostic" then
    return nil
  end

  ---@type 1|2|3|4
  local severity = 1
  if nu_diagnostic.severity == "Warning" then
    severity = 2
  elseif nu_diagnostic.severity == "Information" then
    severity = 3
  elseif nu_diagnostic.severity == "Hint" then
    severity = 4
  end

  local span = {
    ["start"] = from_absolute_position(tonumber(nu_diagnostic.span["start"]) or 0, params.bufname),
    ["end"] = from_absolute_position(tonumber(nu_diagnostic.span["end"]) or 0, params.bufname),
  }

  ---@type Diagnostic
  local diagnostic = {
    message = nu_diagnostic.message,
    severity = severity,
    row = span["start"].row,
    col = span["start"].col,
    end_row = span["end"].row,
    end_col = span["end"].col,
    bufnr = params.bufnr,
    filename = params.bufname,
    source = "nu-ls",
  }

  return diagnostic
end

---@param params Params
---@param done fun(result: Diagnostic[])
local handler = function(params, done)

  local cursor_position = to_absolute_position(params.row, params.col, params.bufname)
  local cmd_string = string.format("/usr/bin/env nu --ide-check %d %s", cursor_position, params.bufname)
  local raw_nu_result = vim.fn.system(cmd_string)

  local raw_nu_result_lines = vim.split(raw_nu_result, "\n")

  ---@type Diagnostic[]
  local diagnostics = {}
  for _, line in ipairs(raw_nu_result_lines) do
    local diagnostic = parse_line(line, params)
    if diagnostic ~= nil then
      table.insert(diagnostics, diagnostic)
    end
  end

  done(diagnostics)

end

return {
  handler = handler,
}

