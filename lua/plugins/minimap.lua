return {
  {
    "nvim-mini/mini.map",
    branch = "main",
    keys = {
      { "<leader>0m", function() require("mini.map").toggle() end, desc = "Toggle Mini Map" },
      { "<leader>0f", function() require("mini.map").toggle_focus() end, desc = "Focus Mini Map" },
    },
    opts = function()
      local map = require("mini.map")
      return {
        integrations = {
          map.gen_integration.builtin_search(),
          map.gen_integration.diff(),
          map.gen_integration.diagnostic(),
        },
        symbols = {
          encode = map.gen_encode_symbols.dot("4x2"),
          scroll_line = "▶",
          scroll_view = "┃",
        },
        window = {
          focusable = true,
          side = "right",
          width = 6,
          winblend = 50,
        },
      }
    end,
  },
}
