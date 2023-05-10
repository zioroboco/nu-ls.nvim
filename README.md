# nu-ls.nvim


A [null-ls.nvim](https://github.com/jose-elias-alvarez/null-ls.nvim) source providing language server features for the [nushell](https://www.nushell.sh/) language in [neovim](https://neovim.io/).

Intended to provide an uncomplicated way to access nushell's language server features via the `nu --ide-*` flags added in [nushell v0.79](https://www.nushell.sh/blog/2023-04-25-nushell_0_79.html). It does not provide syntax highlighting or other features (see [nushell/tree-sitter-nu](github.com/nushell/tree-sitter-nu)), and not all language server methods are supported (e.g. go to definition, see [#2](https://github.com/zioroboco/nu-ls.nvim/issues/2)).

Note that this project is unstable: releases are unversioned, and future updates will require backwards-incompatible changes to config.


## Installation


### Installing the `nu-ls.nvim` package

Install `zioroboco/nu-ls.nvim` using any package manager. Note that this is a [null-ls.nvim](https://github.com/jose-elias-alvarez/null-ls.nvim) source, which will also need to be installed along with its dependency [plenary.nvim](https://github.com/nvim-lua/plenary.nvim).

For example:

```lua
-- if using folke/lazy.nvim
require("lazy").setup({
  "nvim-lua/plenary.nvim",
  "jose-elias-alvarez/null-ls.nvim",
  "zioroboco/nu-ls.nvim",
  -- ...
})

-- if using wbthomason/packer.nvim
require("packer").startup(function(use)
  use "nvim-lua/plenary.nvim"
  use "jose-elias-alvarez/null-ls.nvim"
  use "zioroboco/nu-ls.nvim"
  -- ...
end)
```


### Registering as a null-ls source

The `nu-ls` source can now be registered with `null-ls`:

```lua
-- register nu-ls as a null-ls source (required)
require("null-ls").setup({
  sources = {
    require("nu-ls"),
    -- ...
  },
})
```


### Setting the `nu` filetype

The `nu-ls` source will be attached to buffers with the `nu` filetype.

This filetype can be associated with buffers according to their file extension:

```lua
vim.filetype.add({
  extension = {
    nu = "nu",
  },
})
```

In addition, you can also set the filetype by reading shebangs, which might be useful if you keep any executable nushell scripts without the `.nu` extension. For example (assuming shebangs starting `#!/usr/bin/env nu`):

```lua
-- see `:h vim.filetype.add()`
vim.filetype.add({
  pattern = {
    [".*"] = {
      priority = -math.huge,
      function(path, bufnr)
        local content = vim.filetype.getlines(bufnr, 1)
        if vim.filetype.matchregex(content, [[^#!/usr/bin/env nu]]) then
          return "nu"
        end
      end,
    },
  },
})
```


## Troubleshooting

### Poor completions performance

It's been reported that completions can be slow, particularly on larger files. A workaround at the moment is to use the `setup` function to construct a custom null-ls source which doesn't include the completions method:

```lua
require("null-ls").setup({
  sources = {
    require("nu-ls").setup({
      methods = {
        "diagnostics_on_open",
        "diagnostics_on_save",
        "hover",
      },
    }),
    -- ...
  },
})
```
