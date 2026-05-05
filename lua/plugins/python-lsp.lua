return {
  "neovim/nvim-lspconfig",
  opts = {
    servers = {
      basedpyright = {
        settings = {
          basedpyright = {
            analysis = {
              typeCheckingMode = "all",
              autoImportCompletions = true,
              autoSearchPaths = true,
              useLibraryCodeForTypes = true,
              diagnosticMode = "workspace",
            },
          },
        },
      },
      ruff = {
        on_attach = function(client)
          client.server_capabilities.hoverProvider = false
          client.server_capabilities.definitionProvider = false
          client.server_capabilities.referencesProvider = false
        end,
      },
      pyright = { enabled = false },  -- ← conflicts with basedpyright, kill it
      ty     = { enabled = false },  -- ← was stealing your code actions, kill it
    },
  },
}
