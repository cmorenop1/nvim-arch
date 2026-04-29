return {
  { import = "lazyvim.plugins.extras.lang.python" },
  {
    "neovim/nvim-lspconfig",
    opts = function(_, opts)
      opts.servers = opts.servers or {}
      opts.setup = opts.setup or {}

      -- 1. basedpyright — EVERYTHING on
      opts.servers.basedpyright = {
        enabled = true,
        settings = {
          basedpyright = {
            analysis = {
              typeCheckingMode = "all",          -- strictest type checking
              autoImportCompletions = true,       -- auto-imports in completions
              autoSearchPaths = true,             -- scan src/ and other paths
              useLibraryCodeForTypes = true,      -- infer types from lib source
              diagnosticMode = "workspace",       -- check ALL files, not just open ones
              inlayHints = {
                variableTypes = true,             -- let x = ... → shows type
                functionReturnTypes = true,       -- def foo() → shows return type
                callArgumentNames = true,         -- foo(|x|=1) argument labels
                genericTypes = true,              -- infer generics inline
              },
            },
          },
        },
      }

      -- 2. Kill standard pyright — no overlap
      opts.servers.pyright = { enabled = false }

      -- 3. Ruff — linting + formatting + imports
      --    hoverProvider OFF so basedpyright owns hover/docs
      opts.servers.ruff = opts.servers.ruff or {}
      opts.servers.ruff.enabled = true
      opts.setup.ruff = function(_, server_opts)
        server_opts.on_attach = function(client, _)
          client.server_capabilities.hoverProvider = false
        end
        require("lspconfig").ruff.setup(server_opts)
        return true
      end
    end,
  },
}
