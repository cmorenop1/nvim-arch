local npairs = require("nvim-autopairs")

npairs.setup({
  check_ts = false,
  enable_moveright = false,
  enable_afterquote = false,
  map_cr = false,
  map_bs = false,
  disable_filetype = { "TelescopePrompt", "spectre_panel", "vim" },
  fast_wrap = {},
})

local Rule = require("nvim-autopairs.rule")
npairs.get_rules():remove_rule('"')
npairs.get_rules():remove_rule("'")
npairs.clear_rules()
