return {
  { import = "lazyvim.plugins.extras.lang.python" },
  {
    "neovim/nvim-lspconfig",
    opts = function(_, opts)
      opts.servers = opts.servers or {}
      opts.setup = opts.setup or {}

      -- 1. ty (register manually if not in lspconfig yet)
      opts.servers.ty = {
        enabled = true,
        settings = {
          ty = {
            completions = { autoImport = true },
          },
        },
      }
      opts.setup.ty = function(_, server_opts)
        local configs = require("lspconfig.configs")
        if not configs.ty then
          configs.ty = {
            default_config = {
              cmd = { "ty", "server" },
              filetypes = { "python" },
              root_dir = require("lspconfig.util").root_pattern("pyproject.toml", ".git"),
            },
          }
        end
        require("lspconfig").ty.setup(server_opts)
        return true
      end

      -- 2. basedpyright
      opts.servers.basedpyright = {
        enabled = true,
        settings = {
          basedpyright = {
            analysis = {
              typeCheckingMode = "off", -- let ty handle types
            },
          },
        },
      }

      -- 3. Disable standard pyright
      opts.servers.pyright = { enabled = false }

      -- 4. Ruff — disable hover to avoid conflict
      opts.servers.ruff = opts.servers.ruff or {}
      opts.servers.ruff.enabled = true
      opts.setup.ruff = function(_, server_opts)
        server_opts.on_attach = function(client, bufnr)
          client.server_capabilities.hoverProvider = false
        end
        require("lspconfig").ruff.setup(server_opts)
        return true
      end
    end,
  },
}
