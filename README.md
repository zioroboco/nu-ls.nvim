# nu-ls.nvim


A [null-ls.nvim](https://github.com/jose-elias-alvarez/null-ls.nvim) source providing language server features for the [nushell](https://www.nushell.sh/) language in [neovim](https://neovim.io/).


## Installation

This repo intends to do exactly one thing: to provide an uncomplicated way to access nushell's language server features via the `nu --ide-*` flags added in [nushell v0.79](https://www.nushell.sh/blog/2023-04-25-nushell_0_79.html).

This isn't intended to be a complete, out-of-the-box nushell plugin for neovim, and some assembly is required. This is deliberate - nu moves fast, editor integrations come and go, and I'm in no better position than you to judge what might make for a good setup over time.

That said, the instructions bellow might help you to set up a reasonably full-featured nushell development environment in neovim.


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


### Registering the null-ls source

The `nu-ls` source can now be registered with `null-ls`:

```lua
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
    ["*"] = {
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


### Syntax highlighting?

> This is probably more hands-on than many people will like, but I think that's just the state of things at the moment. There are superficially easier solutions, but I suspect you might be frustrated by outdated grammars resulting in wonky highlights.
>
> The instructions below will at least allow you to maintain your own highlights queries for things which you care about. This might result in better worst-case highlighting, which is my personal preference.

The ability to add syntax highlighting can be provided by [tree-sitter](https://tree-sitter.github.io/tree-sitter/) using [nvim-treesitter](https://github.com/nvim-treesitter/nvim-treesitter) (please refer to its own installation instructions).

This is how I'm personally configuring tree-sitter for nushell using [nushell/tree-sitter-nu](https://github.com/nushell/tree-sitter-nu):

```lua
local parser_config = require("nvim-treesitter.parsers").get_parser_configs()

parser_config.nu = {
  install_info = {
    url = "https://github.com/nushell/tree-sitter-nu",
    files = { "src/parser.c" },
    branch = "main",
  },
  filetype = "nu",
}
```

Run `:TSInstall nu` in neovim to install the above parser.

To get an overview of how tree-sitter is parsing nushell code, I recommend poking around with [nvim-treesitter/playground](https://github.com/nvim-treesitter/playground).

With tree-sitter available, you can now add [highlights queries](https://tree-sitter.github.io/tree-sitter/syntax-highlighting#highlights) to associate highlight groups with tree-sitter nodes. Run `:highlight` in neovim for a list of highlight groups.

For a very simple example, add the following to `~/.config/nvim/queries/nu/highlights.scm` (this is one of the locations where neovim will look for highlights queries for the nu language, assuming your local neovim config is in the default location):

```scm
; apply the `@comment` highlight group to `comment` nodes
(comment) @comment
```

I found [1Kinoti/tree-sitter-nu](https://github.com/1Kinoti/_tree-sitter-nu) to be a good reference for setting up highlights queries for nushell (see: [`highlights.scm`](https://github.com/1Kinoti/_tree-sitter-nu/blob/main/queries/helix/highlights.scm)). The grammar from this repo was recently merged into [nushell/tree-sitter-nu](https://github.com/nushell/tree-sitter-nu), which I've recommended above.
