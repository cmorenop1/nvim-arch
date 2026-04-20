return {
  "nvim-telescope/telescope.nvim",
  dependencies = { "nvim-lua/plenary.nvim" },
  config = function()
    local home = vim.uv.os_homedir()

    local function get_project_root()
      local dir = vim.fn.getcwd()
      local markers = { ".git" } -- TREE CEILING
      while dir ~= home and dir ~= "/" do
        for _, m in ipairs(markers) do
          if vim.fn.isdirectory(dir .. "/" .. m) == 1 or vim.fn.filereadable(dir .. "/" .. m) == 1 then
            return dir
          end
        end
        dir = vim.fn.fnamemodify(dir, ":h")
      end
      return vim.fn.getcwd()
    end

    require("telescope").setup({
      defaults = {
        file_ignore_patterns = {
          "node_modules",
          ".git/",
          ".env/",
          ".venv/",
          ".ruff_cache/",
        },
        layout_strategy = "flex",
      },
      pickers = {
        find_files = {
          hidden = true,
          no_ignore = true,
          no_ignore_parent = true,
          cwd = get_project_root(),
        },
      },
    })
  end,
}
