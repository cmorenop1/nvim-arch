-- Author: Cristopher Moreno

local map = vim.keymap.set

-- 1. SEARCHING
local function find_files_in_cwd()
  local dir = vim.fn.expand('%:p:h')
  if dir == '' or dir == '.' then
    dir = vim.loop.cwd()
  end
  require('telescope.builtin').find_files({ cwd = dir })
end

local function live_grep_in_cwd()
  local dir = vim.fn.expand('%:p:h')
  if dir == '' or dir == '.' then
    dir = vim.loop.cwd()
  end
  require('telescope.builtin').live_grep({ cwd = dir })
end

map('n', '<leader><leader>', find_files_in_cwd, { desc = 'Find Files in CWD' })
map('n', '<leader>fg', live_grep_in_cwd, { desc = 'Find Files in CWD' })

map('n', 'za', function()
  vim.cmd('normal! za')
  vim.notify('[za] Folding!!')
end, { desc = 'Toggle Folding' })

-- 2. DELETING & YANKING
map("n", "D", '"_ld$', { desc = "[D]elete until EOL" })
map({ "n", "x" }, "d", '"_d', { noremap = true, silent = true, desc = "Delete without yanking" })
map("n", "dd", '"_dd', { noremap = true, silent = true, desc = "Delete line without yanking" })
map("n", "<Tab>y", "yiw", { noremap = true, silent = true, desc = "[y]ank" })
map("n", "<Tab>c", '"_ciw', { noremap = true, silent = true, desc = "[c]hange" })
map("n", "C", '"_ciw', { noremap = true, silent = true, desc = "[C]hange" })
map({ "n", "t" }, "<Tab>p", '"_ciw<C-r>0<Esc>', { noremap = true, silent = true, desc = "[p]aste inside Word" })

-- 3. MOVING AROUND
map("n", "gg", "gg_", { noremap = true, silent = true })
map("n", "G", "G_", { noremap = true, silent = true })
map("n", "$", "$h", { noremap = true, silent = true })
map({ "n", "v" }, "<Home>", "_", { noremap = true, silent = true })
map("n", "<C-d>", "<Cmd>normal! <C-d>zz0<CR>", { noremap = true, silent = true })
map("n", "<C-u>", "<Cmd>normal! <C-u>zz0<CR>", { noremap = true, silent = true })
map({ "n", "v", "x" }, "<Up>", "<Up>zz", { noremap = true, silent = true })
map({ "n", "v", "x" }, "<Down>", "<Down>zz", { noremap = true, silent = true })
map("n", "<S-Up>", "<Up>0_zz", { noremap = true, silent = true })
map("n", "<S-Down>", "<Down>0_zz", { noremap = true, silent = true })
map("n", "<BS>", "_zz", { noremap = true, silent = true })
map({ "n", "v" }, "k", "kzz", { noremap = true, silent = true })
map({ "n", "v" }, "j", "jzz", { noremap = true, silent = true })
map({ "n" }, "<Tab>s", function()
  vim.cmd("normal! mm")
  vim.cmd("normal! Vip=")
  vim.cmd("normal! `m")
  vim.cmd("normal! zz")
  vim.cmd("delmarks m")
end, { noremap = true, silent = true, desc = "Format [s]election" })

-- PAGE JUMPS
map({ "n", "v" }, "<PageDown>", "<C-d>zz0", { desc = "Go half page down" })
map({ "n", "v" }, "<PageUp>", "<C-u>zz0", { desc = "Go half page up" })
map({ "n", "v" }, "<Tab>]", "<C-d>zz0", { noremap = true, silent = true, desc = "Go half page down" })
map({ "n", "v" }, "<Tab>[", "<C-u>zz0", { noremap = true, silent = true, desc = "Go half page down" })

-- WORD MOVES
map({ "n", "v" }, "<C-Right>", "e", { noremap = true, silent = true })
map({ "n", "v" }, "<C-Left>", "b", { noremap = true, silent = true })
map({ "n", "v" }, "<S-l>", "w", { noremap = true, silent = true })
map({ "n", "v" }, "<S-h>", "b", { noremap = true, silent = true })
map({ "n", "v" }, "<C-l>", "$", { noremap = true, silent = true })
map({ "n", "v" }, "<C-h>", "_", { noremap = true, silent = true })

-- BUFFERS
map("n", "<leader><Right>", "<Cmd>silent! bnext<CR>", { noremap = true, silent = true })
map("n", "<leader><Left>", "<Cmd>silent! bprevious<CR>", { noremap = true, silent = true })

-- 4. INSERTING & EDITING
map("n", "o", "o<Esc>zz", { noremap = true, silent = true })
map("n", "O", "O<Esc>zz", { noremap = true, silent = true })
map("n", "<S-a>", "a", { noremap = true, silent = true })

-- 5. `'[{("SURROUND")}]'` WITH SYMBOLS
local delimiters = { ["{"] = "}", ["("] = ")", ["["] = "]", ["q"] = '"', ["s"] = "'", ["b"] = "`" }
for trigger, target in pairs(delimiters) do
  map("x", "<leader>z" .. trigger, "gsa" .. target .. "h", { remap = true, silent = true, desc = "with " .. target })
end

-- 6. TAB RULES
map({ "n", "v" }, "<Tab><Right>", "$", { noremap = true, silent = true, desc = "Go right" })
map({ "n", "v" }, "<Tab><Left>", "_", { noremap = true, silent = true, desc = "Go left" })
map({ "n", "v" }, "<Tab><Up>", "<Cmd>0<CR><Cmd>normal! _<CR>", { noremap = true, silent = true, desc = "Go up" })

map("n", "<Tab>f", function()
  local win = 0
  local cursor = vim.api.nvim_win_get_cursor(win)
  vim.cmd("normal! ggVG=")
  vim.lsp.buf.code_action({
    context = { only = { "source.organizeImports" } },
    apply = true,
  })
  vim.api.nvim_win_set_cursor(win, cursor)
  vim.cmd("normal! zz")
end, { noremap = true, silent = true, desc = "Format File" })

-- 7. BIG TOOLS
map("n", "<leader>m", "<Cmd>Mason<CR>", { noremap = true, silent = true })
map("n", "<leader>M", "<Cmd>LazyExtras<CR>", { noremap = true, silent = true })

map("n", "<F5>", function()
  package.loaded["config.keymaps"] = nil
  require("config.keymaps")
  vim.cmd("e!")
  vim.notify("Reload!", vim.log.levels.INFO)
end, { desc = "Reload!" })

map("n", "<leader>r", function()
  local win = 0
  local cursor = vim.api.nvim_win_get_cursor(win)
  local word = vim.fn.expand("<cword>")
  local new_word = vim.fn.input("Replace '" .. word .. "' with: ")
  if new_word ~= "" then
    local count = vim.fn.searchcount({ pattern = word, recompute = true }).total
    vim.cmd(string.format("%%s/%s/%s/g", word, new_word))
    print(count .. " instances replaced")
  end
  vim.api.nvim_win_set_cursor(win, cursor)
  vim.cmd("normal! zz")
end, { desc = "Replace word" })


map("n", "<leader>p", function()
  local dir = vim.fn.expand("%:.")
  local formatted = dir:gsub("/", "."):gsub("%.py$", "")
  local output = "from " .. formatted .. " import"
  vim.fn.setreg("0", output)
  vim.fn.setreg("+", output)
  vim.notify("Relative path copied to clipboard", vim.log.levels.INFO)
end, { noremap = true, silent = true })

map("n", "<Tab>.", function()
  vim.cmd("edit $HOME/.config/nvim/lua/config/keymaps.lua")
  vim.notify("Edit Keymaps!")
end, {
    desc = "Edit keymaps file",
    noremap = true,
  })

map({ "n", "i" }, "<F1>", function()
  local var = vim.fn.input("(Python) Print: ")
  if var == "" then
    return
  end
  local row = unpack(vim.api.nvim_win_get_cursor(0))
  local current_line = vim.api.nvim_get_current_line()
  local indent = current_line:match("^%s*") or ""
  local line = indent .. string.format('print(f"%s={%s}")', var, var)
  if vim.api.nvim_get_mode().mode:match("^i") then
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "n", true)
  end
  vim.api.nvim_buf_set_text(0, row - 1, 0, row - 1, 0, { line })
end)

-- map({ "n", "i" }, "<F2>", function()
--   local input = vim.fn.input("Calculator: ")
--   local solver = load("return " .. input)
--   if not solver then
--     vim.api.nvim_echo({ { "Invalid Math!", "ErrorMsg" } }, true, {})
--     return
--   end
--   local ok, result = pcall(solver)
--   if ok and type(result) == "number" then
--     local result_value = " " .. tostring(result)
--     if vim.api.nvim_get_mode().mode == "i" then
--       vim.api.nvim_feedkeys(result_value, "n", false)
--     else
--       vim.api.nvim_put({ result_value }, "c", true, true)
--     end
--     return
--   end
--   vim.api.nvim_echo({ { "Invalid Math!", "ErrorMsg" } }, true, {})
-- end, { desc = "Calculate and insert math", silent = true })

-- vim.keymap.set({ "n", "i" }, "<F7>", function()
--   local link = vim.fn.input("Link: ")
--   if link == "" then
--     return
--   end
--   local command =
--   string.format('split | term python3 -m pip install yt-dlp; yt-dlp --netrc -x --audio-format mp3 "%s" ; exit', link)
--   vim.cmd(command)
-- end)

-- TERMINAL
map({ "n", "i", "t" }, "<F6>", "<Cmd>terminal<CR><Cmd>startinsert<CR>", { noremap = true, silent = true })

map({ "n", "i", "t" }, "<F4>", function()
  local mode = vim.fn.mode()
  if mode == "i" then
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "n", true)
  elseif mode == "t" then
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<C-\\><C-n>", true, false, true), "n", true)
  end
  vim.cmd("bd!")
end, { noremap = true, silent = true })

map({ "n", "i", "t" }, "<F12>", function()
  local mode = vim.fn.mode()
  if mode == "i" then
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "n", true)
  elseif mode == "t" then
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<C-\\><C-n>", true, false, true), "n", true)
  end
  vim.cmd("bd!")
end, { noremap = true, silent = true })

map({ "n", "t" }, "<C-Up>", [[<C-\><C-n><C-w>k]], { desc = "Move Up", remap = false })
map({ "n", "t" }, "<C-Down>", [[<C-\><C-n><C-w>j]], { desc = "Move Down", remap = false })

-- LLM TOOL
map("v", "<Tab>m", function()
  -- 1. Get the selected text
  vim.cmd('noau normal! "vy')
  local selected_text = vim.fn.getreg("v")

  -- 2. Ask the human for their instruction
  local user_prompt = vim.fn.input("Prompt: ")
  if user_prompt == "" then
    vim.notify("llm tool cancelled", vim.log.levels.WARN)
    return
  end

  local full_payload = user_prompt .. "\n\nCONTEXT/CODE:\n" .. selected_text

  local script_path = vim.fn.expand("$HOME/scripts/llm-tool.sh")
  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_set_option_value("filetype", "markdown", { buf = buf })

  -- Calculate window size
  local width = math.floor(vim.o.columns * 0.8)
  local height = math.floor(vim.o.lines * 0.8)
  local row = math.floor((vim.o.lines - height) / 2)
  local col = math.floor((vim.o.columns - width) / 2)

  local placeholder = "thinking..."
  local pad_top = math.floor(height / 2)
  local pad_left = math.floor((width - #placeholder) / 2)
  local lines = {}
  for _ = 1, pad_top do table.insert(lines, "") end
  table.insert(lines, string.rep(" ", pad_left) .. placeholder)

  -- Open the window
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  local win = vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    width = width,
    height = height,
    row = row,
    col = col,
    style = "minimal",
    border = "rounded",
    footer = " [q] quit ",
    footer_pos = "center",
  })

  -- Enable line numbers in the floating window
  vim.api.nvim_set_option_value("number",         true, { win = win })
  vim.api.nvim_set_option_value("relativenumber", true, { win = win })
  vim.api.nvim_set_option_value("numberwidth",    4,    { win = win })
  vim.api.nvim_set_option_value("wrap",           true, { win = win })

  vim.wo.wrap = true

  -- 4. SAVE AND QUIT LISTENER (The 'q' key)
  vim.keymap.set("n", "q", function()
    local content_lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
    local content = table.concat(content_lines, "\n")
    local dir = vim.fn.expand("$HOME/conversations/")

    if vim.fn.isdirectory(dir) == 0 then vim.fn.mkdir(dir, "p") end

    local timestamp = os.date("%Y%m%d_%H%M%S")
    local filename = dir .. "conversation_" .. timestamp .. ".txt"

    local file = io.open(filename, "w")
    if file then
      file:write(content)
      file:close()
      -- Use a simple print or notify
      vim.notify("Saved: " .. filename, vim.log.levels.INFO)
    end

    -- Cleanup: Close window and wipe buffer
    vim.api.nvim_win_close(win, true)
    vim.api.nvim_buf_delete(buf, { force = true })
  end, { buffer = buf, silent = true })

  -- 3. Execute the script
  vim.fn.jobstart({ script_path, full_payload }, {
    stdout_buffered = true,
    on_stdout = function(_, data)
      if data and #data > 0 and data[1] ~= "" then
        vim.api.nvim_buf_set_lines(buf, 0, -1, false, data)
      end
    end,
    on_stderr = function(_, data)
      if data and #data > 1 then
        vim.notify("Error: " .. table.concat(data, "\n"), vim.log.levels.ERROR)
      end
    end,
  })
end, { desc = "ll[m] tool", silent = true })


-- 8. DEAD KEYS
local modes = { "n", "i", "v", "x", "s", "o", "t", "c" }
for _, mode in ipairs(modes) do
  map(mode, "<C-W><Up>", "<NOP>", { noremap = true, silent = true })
  map(mode, "<C-W><Down>", "<NOP>", { noremap = true, silent = true })
end
map({ "i", "n", "v", "c" }, "<Insert>", "<Nop>", { noremap = true, silent = true })
map({ "n", "i", "v", "x", "o", "c", "t" }, "<C-/>", "<Nop>", { noremap = true, silent = true })
map("n", "Q", "<Nop>", { noremap = true })
map("n", "q", "<Nop>", { noremap = true })
map("n", "<C-q>", "<Nop>", { noremap = true })
map("n", "@", "<Nop>", { noremap = true })
map("n", "@@", "<Nop>", { noremap = true })
map("n", "<C-S-Up>", "<Nop>", { noremap = true, silent = true })
map("n", "<C-S-Down>", "<Nop>", { noremap = true, silent = true })
map({ "n", "v" }, "<C-S-Right>", "<Nop>", { noremap = true, silent = true })
map({ "n", "v" }, "<C-S-Left>", "<Nop>", { noremap = true, silent = true })
map({ "n", "v" }, "H", "<Nop>")
map({ "n", "v" }, "J", "<Nop>")
map({ "n", "v" }, "K", "<Nop>")
map({ "n", "v" }, "L", "<Nop>")
-- map({'n','v'}, 'C', '<Nop>')
map({ "n", "v" }, "Y", "<Nop>")
map({ "n", "v" }, "P", "<Nop>")
-- END OF FILE
