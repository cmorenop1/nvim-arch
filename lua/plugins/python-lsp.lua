-- nvim/lua/plugins/lsp.lua
return {
  "neovim/nvim-lspconfig",
  opts = {
    servers = {
      basedpyright = {
        settings = {
          basedpyright = {
            analysis = {
              typeCheckingMode = "all",
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
      pyright = {
        enabled = false,
      },
      -- ty = {
      --   enabled = false,
      -- },
    },
  },
}
