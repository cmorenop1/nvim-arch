return {
  {
    "akinsho/toggleterm.nvim",
    version = "*",
    config = function()
      require("toggleterm").setup({
        shade_terminals = true,
        insert_mappings = true,
        terminal_mappings = true,
        start_in_insert = true,
      })

      local opts = { noremap = true, silent = true }

      vim.keymap.set("n", "<leader>t", "<cmd>ToggleTerm direction=horizontal<cr>", {
        desc = "Toggle Terminal Horizontal",
        noremap = opts.noremap,
        silent = opts.silent,
      })

      function _G.set_terminal_keymaps()
        local t_opts = { buffer = 0 }
        vim.keymap.set("t", "<esc>", [[<C-\><C-n>]], t_opts)
      end

      vim.cmd("autocmd! TermOpen term://* lua set_terminal_keymaps()")
    end,
  },
}
