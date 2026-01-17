-- todo.nvim - A simple floating todo plugin for Neovim
-- Maintainer: Your Name
-- License: MIT

-- Prevent loading twice
if vim.g.loaded_todo_nvim then
  return
end
vim.g.loaded_todo_nvim = true

-- Requires Neovim 0.9+
if vim.fn.has("nvim-0.9.0") ~= 1 then
  vim.notify("todo.nvim requires Neovim 0.9.0 or later", vim.log.levels.ERROR)
  return
end

-- Lazy load the plugin - don't setup until user calls it
-- This allows users to configure before setup
vim.api.nvim_create_user_command("Todo", function()
  require("todo").setup()
  require("todo").toggle()
end, { desc = "Open todo file (auto-setup)" })

vim.api.nvim_create_user_command("Td", function()
  require("todo").setup()
  require("todo").toggle()
end, { desc = "Open todo file (auto-setup, alias)" })
