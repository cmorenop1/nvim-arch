return {
  "norcalli/nvim-colorizer.lua",
  event = { "BufReadPre", "BufNewFile" },  -- lazy-load on buffer open
  config = function()
    require("colorizer").setup({
      "*",         -- highlight all filetypes by default
      css = {
        rgb_fn  = true,  -- enable css rgb() and rgba()
        hsl_fn  = true,  -- enable css hsl() and hsla()
        css     = true,  -- enable all CSS features
      },
      html = {
        mode   = "foreground",  -- use foreground color instead of background
        names  = false,         -- disable named colors like "Blue"
      },
      javascript = { rgb_fn = true },
      "!vim",      -- exclude vim filetypes
    }, {
        mode = "background",  -- default display mode for all others
      })
  end,
}
