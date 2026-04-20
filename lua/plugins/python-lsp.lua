return {
  { import = "lazyvim.plugins.extras.lang.python" },

  {
    "neovim/nvim-lspconfig",
    opts = function(_, opts)
      opts.servers.ty = {
        enabled = true,
        settings = {
          ty = {
            completions = {
              autoImport = true,
            },
          },
        },
      }
      opts.servers.pyright      = { enabled = false }
      opts.servers.basedpyright = { enabled = false }
      opts.servers.ruff = opts.servers.ruff or {}
      opts.servers.ruff.enabled = true
      opts.setup = opts.setup or {}
      opts.setup.ruff = function()
        require("snacks").util.lsp.on({ name = "ruff" }, function(_, client)
          client.server_capabilities.hoverProvider = false
        end)
      end
    end,
  },
}
