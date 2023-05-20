local null_ls = require("null-ls")

-- Implemented null-ls method names, as described by :NullLsInfo
---@alias MethodName "completion" | "diagnostics_on_open" | "diagnostics_on_save" | "hover"

---@class Options
---@field debounce number Delay after last input before generating completions, in milliseconds (default: 500ms)
---@field methods MethodName[] Enabled null-ls methods (default: all)
local options = {

  -- FIXME: these are being accessed in different ways...
  --   options.debounce is being looked up in this options table at runtime
  --   options.method is required to be set upon registration with null-ls
  --
  -- So this is used to look up defaults, and directly as a config object.
  --
  -- I'm trying to prevent breaking past versions of the config API -- if we
  -- need to keep using nu-ls long term, we'll want to fix this in a future
  -- breaking (as in versioned) release, in which we stop using the nu-ls
  -- module directly as the source, and require config to be provided first.

  debounce = 500,
  methods = {
    "completion",
    "diagnostics_on_open",
    "diagnostics_on_save",
    "hover",
  }
}

local enabled_internal_methods = {
  null_ls.methods.COMPLETION,
  null_ls.methods.DIAGNOSTICS_ON_OPEN,
  null_ls.methods.DIAGNOSTICS_ON_SAVE,
  null_ls.methods.HOVER,
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
  options = vim.tbl_extend("force", options, opts or {})
  enabled_internal_methods = {}
  for _, method in ipairs(options.methods) do
    local internal_method_name = null_ls.methods[method:upper()]
    if internal_method_name == nil then
      error("nu-ls: invalid method name: " .. method)
      return
    end
    table.insert(enabled_internal_methods, internal_method_name)
  end
  return {
    name = "nu-ls",
    filetypes = { "nu" },
    method = enabled_internal_methods,
    generator = {
      async = true,
      fn = handler,
    },
  }
end

local M = setup(options)
M.setup = setup

return M
