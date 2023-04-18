local null_ls = require("null-ls")

---@param params Params
local handler = function(params, done)
  if params.method == null_ls.methods.COMPLETION then
    require("nu-ls.completion").handler(params, done)
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
