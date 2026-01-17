local config = require("todo.config")

local M = {}

---Calculate window dimensions
---@return { width: number, height: number, col: number, row: number }
local function calculate_dimensions()
  local opts = config.get()
  -- Use defaults if not configured yet
  local cfg_width = opts.width or 0.8
  local cfg_height = opts.height or 0.8
  local editor_width = vim.o.columns
  local editor_height = vim.o.lines

  -- Calculate width
  local width
  if cfg_width <= 1 then
    width = math.floor(editor_width * cfg_width)
  else
    width = cfg_width
  end
  if opts.max_width then
    width = math.min(width, opts.max_width)
  end

  -- Calculate height
  local height
  if cfg_height <= 1 then
    height = math.floor(editor_height * cfg_height)
  else
    height = cfg_height
  end
  if opts.max_height then
    height = math.min(height, opts.max_height)
  end

  -- Center the window
  local col = math.floor((editor_width - width) / 2)
  local row = math.floor((editor_height - height) / 2)

  return {
    width = width,
    height = height,
    col = col,
    row = row,
  }
end

---Get float window configuration
---@return table
function M.get_config()
  local dims = calculate_dimensions()
  local opts = config.get()

  return {
    relative = "editor",
    width = dims.width,
    height = dims.height,
    col = dims.col,
    row = dims.row,
    border = opts.border,
    style = "minimal",
    title = " Todo ",
    title_pos = "center",
  }
end

---Current floating window handle
---@type number|nil
M.current_win = nil

---Current buffer handle
---@type number|nil
M.current_buf = nil

---Check if the todo window is currently open
---@return boolean
function M.is_open()
  return M.current_win ~= nil and vim.api.nvim_win_is_valid(M.current_win)
end

---Close the todo window
---@param force boolean|nil Force close without checking for unsaved changes
---@return boolean success
function M.close(force)
  if not M.is_open() then
    return true
  end

  if not force and M.current_buf and vim.api.nvim_buf_is_valid(M.current_buf) then
    if vim.bo[M.current_buf].modified then
      vim.notify("Buffer has unsaved changes. Save with :w or force close with :q!", vim.log.levels.WARN)
      return false
    end
  end

  vim.api.nvim_win_close(M.current_win, true)
  M.current_win = nil
  return true
end

---Toggle the todo window
function M.toggle()
  if M.is_open() then
    M.close()
  else
    require("todo").open()
  end
end

return M
