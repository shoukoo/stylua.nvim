# stylua.nvim

This repository is heavily inspired by [ckipp01's repo](https://github.com/ckipp01/stylua-nvim.git)

stylua.nvim is a minimal wrapper around the Lua code formatter,
[StyLua](https://github.com/JohnnyMorganz/StyLua). It does pretty much what
you'd expect it to do, format your Lua file using Stylua.

## Getting started 🏡

### Requirements
- Neovim 0.5+
- StyLua

### Install Stylua
If you have Rust installed, you can install Stylua using cargo
```
cargo install stylua
```

MacOS
```
brew install stylua
```
You can also download the binary [here](https://github.com/JohnnyMorganz/StyLua/releases)

## Installation 💾
Use your faviourie package manager to install stylua.nvim
#### Packer

```lua
use 'shoukoo/stylua.nvim'
```

#### Vim-Plug
```viml
Plug 'shoukoo/stylua.nvim'
```

## Setup 🛠️
#### Format your file on save: 
```lua
require('stylua').setup({
  on_save = true,
})
```

#### Assign a dedicated key to format the file: 
```lua
local opts = { noremap=true, silent=true }
buf_set_keymap("n", "<leader>f", "<cmd>lua require("stylua")format_file()<CR>', opts)
```

#### Usage via nvim-lspconfig with sumneko_lua:
You can follow the standalone instruction to install [sumneko_lua](https://github.com/sumneko/lua-language-server/wiki/Build-and-Run-(Standalone))
```lua

local on_attach = function(lsp)
  return function(_, bufnr)
    local function buf_set_keymap(...)
      vim.api.nvim_buf_set_keymap(bufnr, ...)
    end

    -- Mappings.
    local opts = { noremap = true, silent = true }

    -- See `:help vim.lsp.*` for documentation on any of the below functions
    if lsp == 'sumneko_lua' then
      buf_set_keymap('n', 'gf', [[<Cmd>lua require"stylua".format_file()<CR>]], opts)
    else
      buf_set_keymap('n', 'gf', '<Cmd>lua vim.lsp.buf.formatting()<CR>', opts)
    end
    ...
  end
end

...

nvim_lsp.sumneko_lua.setup({
  cmd = { sumneko_binary, '-E', sumneko_root_path .. '/main.lua' },
  on_attach = on_attach('sumneko_lua'),
  capabilities = capabilities,
...

```

##### Create a seperate command to format your code
The code below uses `:Format` cmd to format code: 
```lua
  local lsp_config = require("lspconfig")
  lsp_config.sumneko_lua.setup({
    commands = {
      Format = {
        function()
          require("stylua").format_file()
        end,
      },
    },
    ...
  })
```

You can get more detail by reading the [help docs](https://github.com/shoukoo/stylua.nvim/blob/master/doc/stylua.txt).
