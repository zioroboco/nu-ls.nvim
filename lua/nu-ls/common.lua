-- The cursor position passed from null-ls has a 1-indexed row (line) and a
-- 0-indexed column (think: caret position). Meanwhile, the nushell binary is
-- instead expecting a integer number of _characters deep into the file_.
---@param row number The 1-indexed row (line) of the cursor
---@param col number The 0-indexed column (caret position) of the cursor
---@param path string The path to the file
---@return integer rv The number of characters deep the cursor is into the file
local to_absolute_position = function(row, col, path)
  local cmd_string = string.format([[
    awk -v line=%d -v col=%d 'NR < line { chars += length($0) + 1 } NR == line { chars += col; print chars; exit }' %s
  ]], row, col, path)

  return tonumber(vim.fn.system(cmd_string)) or 0
end

---@param pos integer An integer number of characters deep into the file
---@param path string The path to the file
---@return { row: number, col: number } rv A table with the row and column of the cursor
local from_absolute_position = function(pos, path)
  local cmd_string = string.format([[
    awk -v pos=%d 'BEGIN { chars = 0 } { chars += length($0) + 1; if (chars >= pos) { print "{\"row\":", NR, ",\"col\":", (pos - (chars - length($0))) + 2 "}"; exit } }' %s
  ]], pos, path)

  local decoded_result = vim.fn.json_decode(vim.fn.system(cmd_string))
  if not decoded_result or decoded_result.row == nil or decoded_result.col == nil then
    error("Could not decode row and column result when determining absolute position of " .. pos .. " in " .. path)
  end

  return decoded_result
end

return {
  to_absolute_position = to_absolute_position,
  from_absolute_position = from_absolute_position,
}
