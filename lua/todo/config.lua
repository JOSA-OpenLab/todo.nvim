local M = {}

---@class TodoConfig
---@field target_file string Path to the todo file
---@field global_file string Fallback global file path
---@field width number|nil Window width (0-1 for percentage, >1 for columns)
---@field height number|nil Window height (0-1 for percentage, >1 for rows)
---@field max_width number|nil Maximum window width in columns
---@field max_height number|nil Maximum window height in rows
---@field border string|table Window border style
---@field keymap string|false Keymap to open todo (false to disable)
---@field command string Command name to open todo

---@type TodoConfig
M.defaults = {
  target_file = "todo.md",
  global_file = "~/todo.md",
  width = 0.8,
  height = 0.8,
  max_width = 80,
  max_height = nil,
  border = "rounded",
  keymap = "<leader>td",
  command = "Todo",
}

---@type TodoConfig
M.options = {}

---@param opts TodoConfig|nil
function M.setup(opts)
  M.options = vim.tbl_deep_extend("force", {}, M.defaults, opts or {})
end

---@return TodoConfig
function M.get()
  return M.options
end

return M
