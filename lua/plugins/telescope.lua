return {
  "nvim-telescope/telescope.nvim",
  dependencies = { "nvim-lua/plenary.nvim" },
  keys = {
    {
      "<leader><leader>",
      function()
        local root = require("config.utils").get_project_root() -- see note below
        require("telescope.builtin").find_files({
          cwd = root,
          hidden = true,

          no_ignore = true,
          no_ignore_parent = true,
        })
      end,
      desc = "Find Files",
    },
    {
      "<leader>fg",

      function()
        if vim.fn.executable("rg") == 0 then
          vim.notify("live_grep requires ripgrep (rg)", vim.log.levels.ERROR)
          return
        end
        local root = require("config.utils").get_project_root()
        require("telescope.builtin").live_grep({
          cwd = root,
          additional_args = { "--hidden", "--glob", "!.git" },
        })
      end,
      desc = "Find with GREP (content)",
    },
  },
  config = function()
    require("telescope").setup({
      defaults = {
        file_ignore_patterns = {
          "node_modules/",
          "%.git/",       -- use lua patterns, not globs
          "%.env/",
          "%.venv/",
          "%.ruff_cache/",
          "%.nvm/",
          "%.npm/",
          "%.cargo/",
          "%.rustup/",
          "%.cache/",
        },
        layout_strategy = "flex",
      },
    })
  end,
}
