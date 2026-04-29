return {
  { import = "lazyvim.plugins.extras.lang.python" },
  {
    "neovim/nvim-lspconfig",
    opts = function(_, opts)
      opts.servers = opts.servers or {}
      opts.setup = opts.setup or {}

      -- 1. Basedpyright: Configured ONLY for Auto-Imports
      opts.servers.basedpyright = {
        enabled = true,
        settings = {
          basedpyright = {
            analysis = {
              -- We set this to "off" or "openFilesOnly" to prevent it from 
              -- fighting with 'ty' over error highlights.
              typeCheckingMode = "off", 
              diagnosticMode = "openFilesOnly",
              autoImportCompletions = true,
              autoSearchPaths = true,
              useLibraryCodeForTypes = true,
            },
          },
        },
        -- Disable duplicate capabilities so they don't overlap with 'ty'
        on_attach = function(client, _)
          client.server_capabilities.hoverProvider = false
          client.server_capabilities.definitionProvider = false
          client.server_capabilities.typeDefinitionProvider = false
          client.server_capabilities.renameProvider = false
          client.server_capabilities.diagnosticProvider = false
        end,
      }

      -- 2. Pyright / 'ty': Your primary engine
      -- Since you set vim.g.lazyvim_python_lsp = "ty" in options.lua,
      -- LazyVim will attempt to configure 'ty' if it's available.
      opts.servers.pyright = { enabled = false } -- Ensure standard pyright is dead

      -- 3. Ruff: Linting & Formatting
      opts.servers.ruff = opts.servers.ruff or {}
      opts.servers.ruff.enabled = true
      opts.setup.ruff = function(_, server_opts)
        server_opts.on_attach = function(client, _)
          -- Disable hover so it doesn't conflict with your primary LSP
          client.server_capabilities.hoverProvider = false
        end
        require("lspconfig").ruff.setup(server_opts)
        return true
      end
    end,
  },
}
