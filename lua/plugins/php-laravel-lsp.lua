return {
  {
    "neovim/nvim-lspconfig",

    opts = {
      servers = {
        intelephense = {
          root_dir = function(fname)
            return require("lspconfig.util").root_pattern(
              "composer.json",
              ".git"
            )(fname)
          end,

          settings = {
            intelephense = {
              environment = {
                phpVersion = "8.4.1",
              },

              files = {
                maxSize = 5000000,
              },

              telemetry = {
                enabled = false,
              },

              diagnostics = {
                enable = true,
              },

              completion = {
                insertUseDeclaration = true,
                triggerParameterHints = true,
              },

              ----------------------------------------------------------------
              -- DISABLE LSP FORMATTER
              -- USE php-cs-fixer INSTEAD
              ----------------------------------------------------------------

              format = {
                enable = false,
              },
            },
          },
        },
      },
    },
  },

  ------------------------------------------------------------------------
  -- FORCE AUTOFORMAT
  ------------------------------------------------------------------------

  {
    "stevearc/conform.nvim",

    optional = true,

    opts = {
      --------------------------------------------------------------------
      -- AUTOFORMAT ON SAVE
      --------------------------------------------------------------------

      format_on_save = {
        timeout_ms = 5000,
        lsp_fallback = false,
      },

      --------------------------------------------------------------------
      -- FORMATTERS
      --------------------------------------------------------------------

      formatters_by_ft = {
        php = { "php_cs_fixer" },
      },

      --------------------------------------------------------------------
      -- php-cs-fixer
      --------------------------------------------------------------------

      formatters = {
        php_cs_fixer = {
          command = "php-cs-fixer",

          args = {
            "fix",
            "--rules=@PSR12",
            "--using-cache=no",
            "$FILENAME",
          },

          stdin = false,
        },
      },
    },
  },

  ------------------------------------------------------------------------
  -- MASON
  ------------------------------------------------------------------------

  {
    "mason-org/mason.nvim",

    opts = {
      ensure_installed = {
        "intelephense",
        "php-cs-fixer",
        "phpcs",
      },
    },
  },
}
