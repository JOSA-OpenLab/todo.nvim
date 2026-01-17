# todo.nvim

A simple Neovim plugin for managing todo files in a floating window.

![Neovim](https://img.shields.io/badge/NeoVim-000000?style=for-the-badge&logo=neovim&logoColor=white)
![Lua](https://img.shields.io/badge/Lua-000000?style=for-the-badge&logo=lua&logoColor=white)

## Features

- Open todo files in a beautiful floating window
- Auto-resizable window that maintains center position
- Unsaved changes protection with auto-save on focus lost
- Configurable keymaps
- Smart file resolution (project-local or global)
- Auto-creates todo file if it doesn't exist
- Health checks for debugging

## Installation

**Requirements:** Neovim >= 0.9.0

### Using [lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
{
  "JOSA-OpenLab/todo.nvim",
  cmd = { "Todo", "Td" },
  keys = {
    { "<leader>td", "<cmd>Todo<cr>", desc = "Toggle Todo" },
  },
  opts = {
    target_file = "todo.md",
    global_file = "~/notes/todo.md",
  },
}
```

### Using [packer.nvim](https://github.com/wbthomason/packer.nvim)

```lua
use {
  "JOSA-OpenLab/todo.nvim",
  config = function()
    require("todo").setup({
      target_file = "todo.md",
      global_file = "~/notes/todo.md",
    })
  end,
}
```

### Using [vim-plug](https://github.com/junegunn/vim-plug)

```vim
Plug 'JOSA-OpenLab/todo.nvim'

lua << EOF
require("todo").setup({
  target_file = "todo.md",
  global_file = "~/notes/todo.md",
})
EOF
```

## Configuration

```lua
require("todo").setup({
  -- Path to your todo file (relative to project root or absolute)
  target_file = "todo.md",

  -- Fallback global file when target_file doesn't exist
  global_file = "~/notes/todo.md",

  -- Window dimensions (0-1 for percentage, >1 for columns/rows)
  width = 0.8,
  height = 0.8,

  -- Maximum window dimensions (nil for no limit)
  max_width = 80,
  max_height = nil,

  -- Border style: "none", "single", "double", "rounded", "solid", "shadow"
  border = "rounded",

  -- Keymap to toggle todo window (false to disable)
  keymap = "<leader>td",

  -- Command name to toggle todo window
  command = "Todo",
})
```

## Usage

### Commands

| Command  | Description                          |
| -------- | ------------------------------------ |
| `:Todo`  | Toggle the todo floating window      |
| `:Todo!` | Force close (ignore unsaved changes) |
| `:Td`    | Alias for `:Todo`                    |

### Default Keymaps

| Mode             | Key          | Action             |
| ---------------- | ------------ | ------------------ |
| Normal           | `<leader>td` | Toggle todo window |
| Normal (in todo) | `q`          | Close window       |
| Normal (in todo) | `<Esc>`      | Close window       |

### Lua API

```lua
local todo = require("todo")

-- Open/toggle the todo window
todo.open()
todo.toggle()

-- Close the todo window
todo.close()       -- respects unsaved changes
todo.close(true)   -- force close
```

## Health Check

Run `:checkhealth todo` to verify your setup.

## File Resolution

The plugin resolves the todo file in this order:

1. `target_file` if it exists (expanded path)
2. `target_file` in git repository root (if relative path)
3. `global_file` as fallback

If no file exists, it will be created automatically with a basic template.

## License

MIT
