return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, {
        "blade",
        "php",
        "php_only",
        "html",
        "javascript",
        "css",
        "json",
        "sql",
      })

      -- Register the blade filetype pattern here or in a separate file
      vim.filetype.add({
        pattern = {
          [".*%.blade%.php"] = "blade",
        },
      })
    end,
    -- We remove the manual 'config' function entirely.
    -- LazyVim will call the correct internal setup using the 'opts' above.
  },

  -- ══════════════════════════════════════════════════════════
  -- LSP - Language Server Protocol
  -- ══════════════════════════════════════════════════════════
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        intelephense = {
          filetypes = { "php", "blade" },
          settings = {
            intelephense = {
              environment = {
                phpVersion = "8.4.1",
              },
              files = {
                maxSize = 5000000,
                associations = { "*.php", "*.blade.php" },
              },
              exclude = {
                "**/.git/**",
                "**/node_modules/**",
                "**/vendor/**/tests/**",
                "**/vendor/**/test/**",
                "**/vendor/bin/**",
              },
              telemetry = { enabled = false },
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

  -- ══════════════════════════════════════════════════════════
  -- FORMATTING - Code formatting with conform.nvim
  -- ══════════════════════════════════════════════════════════
  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = {
        -- php = { "php_cs_fixer" },
        php = { "pint" },
        blade = { "blade-formatter" },
      },
      formatters = {
        pint = {
          command = "pint",
          args = { "$FILENAME" },
          stdin = false,
        },
        ["blade-formatter"] = {
          command = "blade-formatter",
          args = { "--write", "$FILENAME" },
          stdin = false,
        },
      },
    },
  },

  -- ══════════════════════════════════════════════════════════
  -- MASON - Package manager
  -- ══════════════════════════════════════════════════════════
  {
    "mason-org/mason.nvim", -- Fixed the repo name (it's williamboman, not mason-org)
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, {
        "intelephense",
        "html-lsp",
        "php-cs-fixer",
        "blade-formatter",
        "phpcs",
        "phpstan",
      })
    end,
  },

  -- ══════════════════════════════════════════════════════════
  -- PHP.NVIM - Additional PHP tooling
  -- ══════════════════════════════════════════════════════════
  {
    "tjdevries/php.nvim",
    ft = { "php", "blade" },
    -- If the plugin has a default setup, 'config = true' is a shorthand in Lazy
    config = true,
  },
}
