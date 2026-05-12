return {
  "ojroques/vim-oscyank",
  event = "VeryLazy", -- Load on demand
  config = function()
    -- Default OSCYank configuration
    vim.g.oscyank_max_length = 0   -- No limit (0 = unlimited)
    vim.g.oscyank_silent = false   -- Show confirmation message
    vim.g.oscyank_trim = false     -- Don't trim surrounding whitespace
    vim.g.oscyank_term = "default" -- Auto-detect terminal

    -- Keybindings for yanking to system clipboard
    vim.keymap.set("n", "<leader>y", "<Plug>OSCYankOperator", { desc = "OSC Yank (operator)" })
    vim.keymap.set("n", "<leader>yy", "<Plug>OSCYankOperator_", { desc = "OSC Yank line" })
    vim.keymap.set("v", "<leader>y", "<Plug>OSCYankVisual", { desc = "OSC Yank (visual)" })
  end,
}
