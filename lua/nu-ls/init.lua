local null_ls = require("null-ls")

---@param params Params
local handler = function(params, done)

  -- we can't read the data from stdin (nu is expecting a file path), but we
  -- also don't want to have to write our modified bufer to disk (to provide
  -- up-to-date cursor positions, etc.), so we're writing a copy of the current
  -- buffer to a temporary file, and pointing nu at that instead
  params.bufname = vim.fn.tempname()
  vim.fn.writefile(vim.api.nvim_buf_get_lines(params.bufnr, 0, -1, false), params.bufname)

  local cleanup_and_done = function(result)
    vim.fn.delete(params.bufname) -- deferred cleanup of the temp file
    done(result)
  end

  if params.method == null_ls.methods.COMPLETION then
    require("nu-ls.handlers.completion").handler(params, cleanup_and_done)
  end

end

return {
  name = "nu-ls",
  filetypes = { "nu" },
  method = {
    null_ls.methods.COMPLETION
  },
  generator = {
    async = true,
    fn = handler,
  },
}
