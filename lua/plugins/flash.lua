return {
  {
    "https://codeberg.org/andyg/leap.nvim.git",
    event = "VeryLazy",
    dependencies = {
      "tpope/vim-repeat",
    },
    config = function()
      local leap = require("leap")

      -- Default mappings (s / S / gs etc.)
      leap.add_default_mappings()

      -- Optional UI tuning
      vim.api.nvim_set_hl(0, "LeapBackdrop", { link = "Comment" })
      vim.api.nvim_set_hl(0, "LeapMatch", { fg = "white", bold = true })
    end,
  },
}
