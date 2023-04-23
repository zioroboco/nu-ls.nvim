# nu-ls.nvim

A (WIP) [null-ls.nvim](https://github.com/jose-elias-alvarez/null-ls.nvim) source for [nushell](https://www.nushell.sh/), using nu's (unreleased) IDE support.

```lua
require("null-ls").setup({
  sources = {
    require("nu-ls"),
    -- ...
  },
})

-- The source attaches to buffers with the `nu` filetype, so this will apply
-- that filetype to anything with a `.nu` extension:
vim.filetype.add({
  extension = {
    nu = "nu",
  },
})
```
