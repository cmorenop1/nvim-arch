local M = {}
local home = vim.uv.os_homedir()

function M.get_project_root()
  local dir = vim.fn.getcwd()
  local markers = { ".git" }
  while dir ~= home and dir ~= "/" do
    for _, m in ipairs(markers) do
      if vim.fn.isdirectory(dir .. "/" .. m) == 1
        or vim.fn.filereadable(dir .. "/" .. m) == 1 then
        return dir
      end
    end
    dir = vim.fn.fnamemodify(dir, ":h")
  end
  return vim.fn.getcwd()
end

return M
