-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

if vim.env.SSH_TTY or vim.env.SSH_CONNECTION then
  -- ── REMOTE / SSH ──────────────────────────────────────────
  -- Use OSC 52 to tunnel clipboard to your LOCAL machine.
  -- Paste reads from Neovim's internal unnamed register
  -- (OSC 52 paste is unreliable in many terminals).
  local osc52 = require("vim.ui.clipboard.osc52")
  vim.opt.clipboard = "unnamedplus"
  vim.g.clipboard = {
    name = "OSC 52",
    copy = {
      ["+"] = osc52.copy("+"),
      ["*"] = osc52.copy("*"),
    },
    paste = {
      -- Paste from Neovim's own register (safer than OSC52 paste)
      ["+"] = function()
        return vim.split(vim.fn.getreg('"'), "\n")
      end,
      ["*"] = function()
        return vim.split(vim.fn.getreg('"'), "\n")
      end,
    },
  }
else
  -- ── LOCAL ─────────────────────────────────────────────────
  -- Standard system clipboard sync, no extra setup needed.
  vim.opt.clipboard = "unnamedplus"
end

vim.opt.relativenumber = true
vim.g.minipairs_disable = true
vim.o.autowriteall = true
vim.g.autoformat = false
vim.g.lazyvim_python_lsp = "ty"
