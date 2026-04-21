return {
  "johmsalas/text-case.nvim",
  config = function()
    require("textcase").setup({
      default_keymappings_enabled = false,
    })
  end,
  keys = {
    { "<Tab>1", "<cmd>lua require('textcase').visual('to_camel_case')<CR>",    mode = "x", desc = "To camelCase" },
    { "<Tab>2", "<cmd>lua require('textcase').visual('to_snake_case')<CR>",    mode = "x", desc = "To snake_case" },
    { "<Tab>3", "<cmd>lua require('textcase').visual('to_upper_case')<CR>",    mode = "x", desc = "To UPPER CASE" },
    { "<Tab>4", "<cmd>lua require('textcase').visual('to_lower_case')<CR>",    mode = "x", desc = "To lower case" },
  },

}
