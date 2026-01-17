local M = {}

function M.check()
  vim.health.start("todo.nvim")

  -- Check Neovim version
  if vim.fn.has("nvim-0.9.0") == 1 then
    vim.health.ok("Neovim version >= 0.9.0")
  else
    vim.health.warn("Neovim version < 0.9.0, some features may not work")
  end

  -- Check if plugin is loaded
  local ok, config = pcall(require, "todo.config")
  if ok then
    vim.health.ok("Plugin loaded successfully")
  else
    vim.health.error("Failed to load plugin: " .. tostring(config))
    return
  end

  -- Check configuration
  local opts = config.get()
  if opts and opts.target_file then
    vim.health.ok("Configuration loaded")
  else
    vim.health.warn("No configuration found, using defaults")
  end

  -- Check if target file exists
  local target = vim.fn.expand(opts.target_file or "todo.md")
  if vim.fn.filereadable(target) == 1 then
    vim.health.ok("Target file exists: " .. target)
  else
    local global = vim.fn.expand(opts.global_file or "~/todo.md")
    if vim.fn.filereadable(global) == 1 then
      vim.health.ok("Global file exists: " .. global)
    else
      vim.health.warn("No todo file found. Will be created on first use.")
    end
  end
end

return M
