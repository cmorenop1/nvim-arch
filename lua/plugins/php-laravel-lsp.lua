return {
  ------------------------------------------------------------------------
  -- LSP CONFIG
  ------------------------------------------------------------------------
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        intelephense = {
          root_dir = function(fname)
            return require("lspconfig.util").root_pattern("composer.json", ".git")(fname)
          end,
          settings = {
            intelephense = {
              environment = {
                phpVersion = "8.4.1",
              },
              files = {
                maxSize = 5000000,
              },
              telemetry = { enabled = false },
              diagnostics = { enable = true },
              completion = {
                insertUseDeclaration = true,
                triggerParameterHints = true,
              },
            },
          },
        },
      },
    },
  },

  ------------------------------------------------------------------------
  -- FORMATTER (CONFORM)
  ------------------------------------------------------------------------
  {
    "stevearc/conform.nvim",
    optional = true,
    opts = {
      formatters_by_ft = {
        php = { "php_cs_fixer" },
        blade = { "php_cs_fixer" },
      },
      formatters = {
        php_cs_fixer = {
          command = "php-cs-fixer",
          args = {
            "fix",
            "$FILENAME",
            "--rules=@PSR12",
            "--using-cache=no",
          },
          stdin = false,
        },
      },
    },
  },

  ------------------------------------------------------------------------
  -- MASON INSTALLERS
  ------------------------------------------------------------------------
  {
    "mason-org/mason.nvim",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, {
        "intelephense",
        "php-cs-fixer",
        "phpcs",
      })
    end,
  },

}
