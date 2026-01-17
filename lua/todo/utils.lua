local M = {}

---Expand a file path (resolve ~, environment variables, etc.)
---@param path string
---@return string
function M.expand_path(path)
  return vim.fn.expand(path)
end

---Resolve the target file path
---@param target_file string
---@param global_file string
---@return string
function M.resolve_file(target_file, global_file)
  local target = M.expand_path(target_file)
  
  -- If target exists, use it
  if vim.fn.filereadable(target) == 1 then
    return target
  end
  
  -- Check if we're in a git repo and target is relative
  if not target_file:match("^[~/]") then
    local git_root = vim.fn.systemlist("git rev-parse --show-toplevel 2>/dev/null")[1]
    if git_root and vim.fn.isdirectory(git_root) == 1 then
      local git_target = git_root .. "/" .. target_file
      if vim.fn.filereadable(git_target) == 1 then
        return git_target
      end
    end
  end
  
  -- Fall back to global file
  return M.expand_path(global_file)
end

---Ensure the parent directory exists for a file
---@param filepath string
---@return boolean success
function M.ensure_parent_dir(filepath)
  local parent = vim.fn.fnamemodify(filepath, ":h")
  if vim.fn.isdirectory(parent) == 0 then
    return vim.fn.mkdir(parent, "p") == 1
  end
  return true
end

---Create file if it doesn't exist
---@param filepath string
---@return boolean success
function M.ensure_file(filepath)
  if vim.fn.filereadable(filepath) == 1 then
    return true
  end
  
  if not M.ensure_parent_dir(filepath) then
    return false
  end
  
  local file = io.open(filepath, "w")
  if file then
    file:write("# Todo\n\n- [ ] \n")
    file:close()
    return true
  end
  return false
end

return M
