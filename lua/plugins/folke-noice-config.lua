return {
  {
    "folke/noice.nvim",
    opts = {
      lsp = {
        signature = {
          enabled = true,
          auto_open = {
            enabled = true,
            trigger = true,
          },
          view = "hover",
        },
      },
      views = {
        hover = {
          size = {
            max_height = 5,
            max_width = 60,
          },
          border = {
            style = "rounded",
          },
        },
      },
    },
  },
}
