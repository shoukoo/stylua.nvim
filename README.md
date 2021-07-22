# stylua.nvim

This repository is heavily inspired by [ckipp01's repo](github.com/ckipp01/stylua-nvim.git )

stylua.nvim is a minimal wrapper around the Lua code formatter,
[StyLua](https://github.com/JohnnyMorganz/StyLua). It does pretty much what
you'd expect it to do, format your Lua file using Stylua.

### Install
Make sure you have StyLua installed and then install this plugin:

```lua
use({"shoukoo/stylua.nvim"})
```

### Quick Start
Format your file on save: 
```lua
require('stylua').setup({
  on_save = true,
})
```

Assign a dedicated key to format the file: 
```lua
local opts = { noremap=true, silent=true }
buf_set_keymap("n", "<leader>f", "<cmd>lua require("stylua")format_file()<CR>', opts)
```

Usage via nvim-lspconfig and sumneko_lua to be able to use `:Format`: 
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
