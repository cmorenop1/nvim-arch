return {
  "nvim-telescope/telescope.nvim",
  dependencies = { "nvim-lua/plenary.nvim" },
  config = function()
    local home = vim.loop.os_homedir() -- or vim.fn.expand("$HOME")
    require("telescope").setup({
      defaults = {
        file_ignore_patterns = { "node_modules", ".git/", ".env/", ".venv/" },
        layout_strategy = "flex",
      },
      pickers = {
        find_files = {
          hidden = true,
          no_ignore = true,
          no_ignore_parent = true,
          cwd = home,
        },
      },
    })
  end,
}
