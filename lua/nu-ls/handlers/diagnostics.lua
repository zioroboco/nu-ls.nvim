local from_absolute_position = require("nu-ls.common").from_absolute_position
local to_absolute_position   = require("nu-ls.common").to_absolute_position

---@param params Params
---@param done fun(result: Diagnostic[])
local handler = function(params, done)

  local cursor_position = to_absolute_position(params.row, params.col, params.bufname)
  local cmd_string = string.format("/usr/bin/env nu --ide-check %d %s", cursor_position, params.bufname)
  local raw_nu_result = vim.fn.system(cmd_string)

  -- reject responses from nu which are too short to be useful
  if raw_nu_result == "" or string.len(raw_nu_result) <= 2 then
    return done({})
  end

  ---@type NuDiagnostic | nil
  local nu_diagnostic = vim.fn.json_decode(raw_nu_result)

  if nu_diagnostic == nil or nu_diagnostic.message == nil or nu_diagnostic.span == nil then
    return done({})
  end

  if not nu_diagnostic then
    error("Could not decode nu diagnostic result: " .. raw_nu_result)
  end

  ---@type 1|2|3|4
  local severity = 1
  if nu_diagnostic.severity == "Error" then
    severity = 1
  elseif nu_diagnostic.severity == "Warning" then
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

  done({
    diagnostic,
  })

end

return {
  handler = handler,
}

