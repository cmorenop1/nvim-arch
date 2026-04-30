return {
  { import = "lazyvim.plugins.extras.lang.python" },
  {
    "neovim/nvim-lspconfig",
    opts = function(_, opts)
      opts.servers = opts.servers or {}

      -- 1. KILL COMPETITION
      opts.servers.pyright = { enabled = false }
      opts.servers.ruff = { enabled = false } -- Ruff is now dead
      opts.servers.ruff_lsp = { enabled = false } -- Ensure the old lsp version is also dead

      -- 2. BASEDPYRIGHT: FULL CONTROL
      opts.servers.basedpyright = {
        enabled = true,
        settings = {
          basedpyright = {
            analysis = {
              -- Re-enabling full power
              typeCheckingMode = "standard", -- or "all" if you want maximum strictness
              diagnosticMode = "workspace",
              autoImportCompletions = true,
              autoSearchPaths = true,
              useLibraryCodeForTypes = true,
            },
          },
        },
        -- REMOVED the on_attach that was disabling hover/definition/rename
        -- Basedpyright now handles everything.
      }
    end,
  },
}
