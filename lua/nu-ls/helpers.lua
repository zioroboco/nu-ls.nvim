-- Get the cursor position in characters from the start of the buffer.
---@return integer
local get_cursor_position = function()
  local row, col = unpack(vim.api.nvim_win_get_cursor(0))
  -- TODO: depending on how nu's counting this, I might need to count preceeding multi-byte characters
  local bytes = vim.fn.line2byte(row) + col - 1
  return bytes
end

return {
  get_cursor_position = get_cursor_position,
}
