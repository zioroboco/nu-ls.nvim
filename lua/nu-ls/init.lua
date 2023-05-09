local null_ls = require("null-ls")

---@class Options
---@field debounce number Delay after last input before generating completions, in milliseconds (default: 100ms)
local options = {
  debounce = 100,
}

local debounce_timer = vim.loop.new_timer()
if debounce_timer == nil then
  error("Failed to create timer")
end

---@param params Params
local handler = function(params, done)

  -- diagnostics run from the filesystem, so we can skip the temp file stuff
  if params.method == null_ls.methods.DIAGNOSTICS_ON_OPEN or params.method == null_ls.methods.DIAGNOSTICS_ON_SAVE then
    require("nu-ls.handlers.diagnostics").handler(params, done)
    return
  end

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
    if debounce_timer:is_active() then
      debounce_timer:stop()
    end
    debounce_timer:start(options.debounce, 0, vim.schedule_wrap(function()
      require("nu-ls.handlers.completion").handler(params, cleanup_and_done)
    end))
  end

  if params.method == null_ls.methods.HOVER then
    require("nu-ls.handlers.hover").handler(params, cleanup_and_done)
  end

end

---@param opts Options
local function setup(opts)
  if opts and opts.debounce then
    options.debounce = opts.debounce
  end
end

return {
  name = "nu-ls",
  filetypes = { "nu" },
  method = {
    null_ls.methods.COMPLETION,
    null_ls.methods.DIAGNOSTICS_ON_OPEN,
    null_ls.methods.DIAGNOSTICS_ON_SAVE,
    null_ls.methods.HOVER,
  },
  generator = {
    async = true,
    fn = handler,
  },
  setup = setup,
}
