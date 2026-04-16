return {
  { "nvim-dashboard/dashboard-nvim", enabled = false },
  { "nvim-mini/mini.starter", enabled = false },
  {
    "goolord/alpha-nvim",
    lazy = false,
    priority = 1000,
    config = function()
      local alpha = require("alpha")
      local dashboard = require("alpha.themes.dashboard")

      dashboard.section.header.val = {
        "    ",
        "NVIM",
        "    ",
      }

      dashboard.section.buttons.val = {
        -- NO BUTTONS
      }

      alpha.setup(dashboard.config)
    end,
  },
}
