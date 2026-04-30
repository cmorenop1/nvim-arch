return {
  "jiaoshijie/undotree",
  dependencies = "nvim-lua/plenary.nvim",
  config = true,
  keys = {
    { "<Tab>u", "<cmd>lua require('undotree').toggle()<cr>", desc = "Undo Tree" },
  },
}
