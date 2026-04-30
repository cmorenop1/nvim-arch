return {
  -- 1. LSP Configuration
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        -- Base PHP LSP
        intelephense = {
          filetypes = { "php", "blade" },
          settings = {
            intelephense = {
              filepatherules = {
                -- Ensures Intelephense understands Laravel's directory structure
                ["**/*.blade.php"] = "blade",
              },
            },
          },
        },
        -- Specialized Laravel LSP
        laravel_ls = {
          filetypes = { "php", "blade" },
        },
        -- Alternative open-source LSP (if you prefer it over Intelephense)
        phpactor = {
          enabled = false, -- Set to true if you want to swap
        },
      },
    },
  },

  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = {
        php = { "pint" },
        blade = { "blade-formatter" },
      },
    },
  },
}

