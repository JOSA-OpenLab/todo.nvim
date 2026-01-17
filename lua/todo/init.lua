local M = {}

---@type boolean
M._initialized = false

---Setup the plugin with user configuration
---@param opts TodoConfig|nil
function M.setup(opts)
  if M._initialized then
    return
  end

  local config = require("todo.config")
  config.setup(opts)

  M._setup_commands()
  M._setup_keymaps()
  M._setup_autocmds()

  M._initialized = true
end

---Open the todo file in a floating window
function M.open()
  local config = require("todo.config")
  local window = require("todo.window")
  local utils = require("todo.utils")

  -- If already open, focus it
  if window.is_open() then
    vim.api.nvim_set_current_win(window.current_win)
    return
  end

  local opts = config.get()
  local filepath = utils.resolve_file(opts.target_file, opts.global_file)

  -- Ensure file exists (create if needed)
  if not utils.ensure_file(filepath) then
    vim.notify("Failed to create todo file: " .. filepath, vim.log.levels.ERROR)
    return
  end

  -- Find or create buffer
  local buf = vim.fn.bufnr(filepath, false)
  if buf == -1 then
    buf = vim.api.nvim_create_buf(true, false)
    vim.api.nvim_buf_call(buf, function()
      vim.cmd.edit(vim.fn.fnameescape(filepath))
    end)
    buf = vim.fn.bufnr(filepath, false)
  end

  -- Buffer settings
  vim.bo[buf].swapfile = false

  -- Open window
  local win_config = window.get_config()
  local win = vim.api.nvim_open_win(buf, true, win_config)
  window.current_win = win
  window.current_buf = buf

  -- Window-local settings
  vim.wo[win].spell = false
  vim.wo[win].number = true
  vim.wo[win].relativenumber = true
  vim.wo[win].wrap = true
  vim.wo[win].linebreak = true
  vim.wo[win].cursorline = true

  -- Buffer-local keymaps
  local keymap_opts = { buffer = buf, noremap = true, silent = true }

  vim.keymap.set("n", "q", function()
    window.close()
  end, vim.tbl_extend("force", keymap_opts, { desc = "Close todo window" }))

  vim.keymap.set("n", "<Esc>", function()
    window.close()
  end, vim.tbl_extend("force", keymap_opts, { desc = "Close todo window" }))

  -- Set up resize autocmd for this window
  local group = vim.api.nvim_create_augroup("TodoWindowResize", { clear = true })
  vim.api.nvim_create_autocmd("VimResized", {
    group = group,
    callback = function()
      if window.is_open() then
        vim.api.nvim_win_set_config(window.current_win, window.get_config())
      end
    end,
  })

  -- Clean up when window closes
  vim.api.nvim_create_autocmd("WinClosed", {
    group = group,
    pattern = tostring(win),
    callback = function()
      window.current_win = nil
      window.current_buf = nil
      vim.api.nvim_del_augroup_by_id(group)
    end,
    once = true,
  })
end

---Close the todo window
---@param force boolean|nil
function M.close(force)
  local window = require("todo.window")
  window.close(force)
end

---Toggle the todo window
function M.toggle()
  local window = require("todo.window")
  window.toggle()
end

---Setup user commands
function M._setup_commands()
  local config = require("todo.config")
  local opts = config.get()

  vim.api.nvim_create_user_command(opts.command, function(cmd_opts)
    if cmd_opts.bang then
      M.close(true)
    else
      M.toggle()
    end
  end, {
    bang = true,
    desc = "Open todo file in floating window",
  })

  -- Keep Td as an alias for backwards compatibility
  if opts.command ~= "Td" then
    vim.api.nvim_create_user_command("Td", function()
      M.toggle()
    end, { desc = "Open todo file in floating window (alias)" })
  end
end

---Setup keymaps
function M._setup_keymaps()
  local config = require("todo.config")
  local opts = config.get()

  if opts.keymap and opts.keymap ~= false then
    vim.keymap.set("n", opts.keymap, function()
      M.toggle()
    end, { silent = true, desc = "Toggle todo window" })
  end
end

---Setup autocommands
function M._setup_autocmds()
  local group = vim.api.nvim_create_augroup("TodoNvim", { clear = true })

  -- Auto-save on focus lost (optional, for better UX)
  vim.api.nvim_create_autocmd("FocusLost", {
    group = group,
    callback = function()
      local window = require("todo.window")
      if window.is_open() and window.current_buf then
        if vim.bo[window.current_buf].modified then
          vim.api.nvim_buf_call(window.current_buf, function()
            vim.cmd("silent! write")
          end)
        end
      end
    end,
  })
end

return M
