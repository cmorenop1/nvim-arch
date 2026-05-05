return {
  {
    "neovim/nvim-lspconfig",
    opts = function(_, opts)
      vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(
        vim.lsp.handlers.hover, {
          border = "rounded",
          focusable = true,
          silent = true,
          max_width = 60,
          max_height = 10,
          wrap = true,
          wrap_at = 60,
        }
      )
      return opts
    end,
  },
}
