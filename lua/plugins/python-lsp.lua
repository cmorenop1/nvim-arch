-- python-lsp.lua
return {
  "neovim/nvim-lspconfig",
  opts = {
    inlay_hints = { enabled = true },
    servers = {
      basedpyright = {
        capabilities = {
          general = {
            positionEncodings = { "utf-16" },
          },
        },
        init_options = { disablePullDiagnostics = true },
        settings = {
          basedpyright = {
            typeCheckingMode = "off",
            analysis = {
              autoImportCompletions = true,
              autoSearchPaths = true,
              useLibraryCodeForTypes = true,
              diagnosticMode = "openFilesOnly",
            },
          },
        },
      },
      ruff = {
        capabilities = {
          general = {
            positionEncodings = { "utf-16" },
          },
        },
        on_attach = function(client)
          client.server_capabilities.hoverProvider = false
          client.server_capabilities.definitionProvider = false
          client.server_capabilities.referencesProvider = false
        end,
      },
      pyright = { enabled = false },
      ty     = { enabled = false },
    },
  },
}
