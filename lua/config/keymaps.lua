-- =============================================================================
-- Author : Cristopher Moreno
-- File   : keymaps.lua
-- =============================================================================

local M      = {}

-- ─────────────────────────────────────────────────────────────────────────────
-- § 1  DEPENDENCIES & ALIASES
-- ─────────────────────────────────────────────────────────────────────────────
local map    = vim.keymap.set
local api    = vim.api
local fn     = vim.fn
local lsp    = vim.lsp.buf
local home   = vim.uv.os_homedir()
local notify = vim.notify


-- ─────────────────────────────────────────────────────────────────────────────
-- § 2  UTILITIES  (pure helpers – no side-effects, fully reusable)
-- ─────────────────────────────────────────────────────────────────────────────

local U = {}

--- Read an entire file from disk.
---@param path string  Accepts `~` and `$ENV` expansions.
---@return string|nil
function U.read_file(path)
  local f = io.open(fn.expand(path), "r")
  if not f then return nil end
  local content = f:read("*a")
  f:close()
  return content
end

--- Walk up the directory tree and return the first ancestor that contains a
--- git marker (.git dir or .gitignore).  Falls back to `cwd`.
---@return string

function U.project_root()
  local dir     = fn.getcwd()

  local markers = { ".git", ".gitignore" }

  while dir ~= home and dir ~= "/" do
    for _, m in ipairs(markers) do
      local full = dir .. "/" .. m

      if fn.isdirectory(full) == 1 or fn.filereadable(full) == 1 then
        return dir
      end
    end

    dir = fn.fnamemodify(dir, ":h")
  end

  return fn.getcwd()
end

--- Safely close a floating window.

---@param win integer

function U.close_win(win)
  if api.nvim_win_is_valid(win) then
    api.nvim_win_close(win, true)
  end
end

--- Create a read-only scratch buffer pre-filled with `lines`.

---@param lines string[]

---@return integer buf

function U.readonly_buf(lines)
  local buf = api.nvim_create_buf(false, true)

  api.nvim_buf_set_lines(buf, 0, -1, false, lines)

  api.nvim_set_option_value("modifiable", false, { buf = buf })

  return buf
end

--- Open a centred floating window.
---@param buf     integer
---@param width   integer
---@param height  integer
---@param opts    table   Extra `nvim_open_win` overrides (title, footer, …).
---@return integer win

function U.float_win(buf, width, height, opts)
  local base = {
    relative = "editor",
    width    = width,
    height   = height,
    row      = math.floor((vim.o.lines - height) / 2),
    col      = math.floor((vim.o.columns - width) / 2),
    style    = "minimal",
    border   = "rounded",
  }

  local win = api.nvim_open_win(buf, true, vim.tbl_extend("force", base, opts or {}))
  api.nvim_set_option_value("winhl", "Normal:Normal,FloatBorder:Comment", { win = win })
  return win
end

--- Bind a close key (q / <Esc>) to a buffer-local function.
---@param buf      integer
---@param close_fn function
function U.bind_close(buf, close_fn)
  local o = { buffer = buf, nowait = true }
  map("n", "q", close_fn, o)
  map("n", "<Esc>", close_fn, o)
end

--- Bind every uppercase letter (A-Z) in a buffer.
---@param buf      integer
---@param callback fun(letter: string)
function U.bind_az(buf, callback)
  for i = 65, 90 do
    local letter = string.char(i)
    map("n", letter, function() callback(letter) end,
      { buffer = buf, nowait = true })
  end
end

-- ─────────────────────────────────────────────────────────────────────────────
-- § 3  DOMAIN SERVICES  (business logic, grouped by concern)
-- ─────────────────────────────────────────────────────────────────────────────

-- ── 3a  LSP / FORMAT ─────────────────────────────────────────────────────────

local LSP = {}

--- Organise imports then LSP-format.
--- Code-action is async; formatting is deferred so both run in the right order.
---@param delay_ms? integer  Default 500 ms.

function LSP.format_file(delay_ms)
  vim.cmd("e!")
  notify("Format!!", vim.log.levels.INFO)
  lsp.code_action({
    context = { only = { "source.organizeImports" } },
    apply   = true,
  })
  vim.defer_fn(function()
    local cursor = api.nvim_win_get_cursor(0)
    lsp.format({ async = false })
    api.nvim_win_set_cursor(0, cursor)
  end, delay_ms or 500)
end

--- Open LSP code-actions then run a full format pass.

function LSP.actions_and_format()
  vim.cmd("e!")
  lsp.code_action()
  LSP.format_file()
  notify("Organise!!", vim.log.levels.INFO)
end

function LSP.go_to_definition()
  vim.cmd("e!")
  vim.lsp.buf.definition()
  vim.notify("Definition!!", vim.log.levels.INFO)
  -- Wait 1 second, then center
  vim.defer_fn(function()
    vim.cmd("normal! zz")
  end, 1000) -- 1000 ms = 1 second
end

-- ── 3b  CONFIG ───────────────────────────────────────────────────────────────



local Config = {}



--- Hot-reload keymaps without restarting Neovim.

function Config.reload()
  package.loaded["config.keymaps"] = nil
  require("config.keymaps")
  vim.cmd("e!")
  notify("Reload!", vim.log.levels.INFO)
  vim.cmd("normal! zz")
end

local Buf = {}
function Buf.close_current()
  vim.cmd("bd!")
  notify("Buffer closed")
end

--- Close every listed buffer and open the dashboard.

function Buf.close_all()
  for _, b in ipairs(fn.getbufinfo({ buflisted = 1 })) do
    vim.cmd("bd! " .. b.bufnr)
  end

  vim.cmd("enew")
  vim.cmd("Alpha")
  vim.cmd("bd! #")
  notify("All buffers closed")
end

local Marks = {}
---@return { letter:string, file:string, line:integer }[]
local function _global_marks()
  local out = {}

  for _, m in ipairs(fn.getmarklist()) do
    if m.mark:match("^'[A-Z]$") then
      table.insert(out, {
        letter = m.mark:sub(2, 2),
        file   = (m.file or "[no file]"):gsub(vim.env.HOME, "~"),
        line   = m.pos[2],
      })
    end
  end
  return out
end



--- Build display lines for a marks popup.

---@param marks { letter:string, file:string, line:integer }[]

---@param footer string

---@return string[], table<string,boolean>

local function _marks_lines(marks, footer)
  local used  = {}

  local lines = { "  Used global marks (A-Z)", "  " .. string.rep("─", 44) }

  for _, m in ipairs(marks) do
    used[m.letter] = true

    table.insert(lines, string.format("  %s  →  %s:%d", m.letter, m.file, m.line))
  end

  if #lines == 2 then
    table.insert(lines, "  (none set)")
  end

  table.insert(lines, "  " .. string.rep("─", 44))

  table.insert(lines, footer)

  return lines, used
end



--- Show the "add global mark" floating UI.

function Marks.add()
  local marks       = _global_marks()

  local footer      = "  Press any A-Z to set — [ESC/q] = close"

  local lines, used = _marks_lines(marks, footer)

  local buf         = U.readonly_buf(lines)

  local win         = U.float_win(buf, 58, #lines, {

    title     = " add mark ",

    title_pos = "center",

  })

  local close       = function() U.close_win(win) end

  U.bind_close(buf, close)

  U.bind_az(buf, function(letter)
    close()

    vim.cmd("mark " .. letter)

    local suffix = used[letter] and " (overwrote existing)" or ""

    notify("Global mark [" .. letter .. "] set" .. suffix, vim.log.levels.INFO)
  end)
end

--- Show the "delete global mark" floating UI.

function Marks.delete()
  local marks       = _global_marks()

  local footer_hint = "  [A-Z] → delete specific   [0] → delete ALL"

  local lines, _    = _marks_lines(marks, footer_hint)

  local buf         = U.readonly_buf(lines)

  local win         = U.float_win(buf, 58, #lines, {

    title      = " delete mark ",

    title_pos  = "center",

    footer     = " [q] close ",

    footer_pos = "center",

  })

  local close       = function() U.close_win(win) end

  U.bind_close(buf, close)

  map("n", "0", function()
    close()

    vim.cmd("delmarks a-z A-Z 0-9")

    notify("All custom and history marks deleted", vim.log.levels.WARN)
  end, { buffer = buf, nowait = true })

  U.bind_az(buf, function(letter)
    close()

    vim.cmd("delmarks " .. letter)

    notify("Global mark [" .. letter .. "] deleted", vim.log.levels.INFO)
  end)
end

--- List all global marks via Telescope.

function Marks.list()
  require("telescope.builtin").marks()
end

-- ── 3e  EDITOR UTILITIES ─────────────────────────────────────────────────────



local Editor = {}



--- Project-aware Telescope file picker.

function Editor.find_files()
  require("telescope.builtin").find_files({ cwd = U.project_root() })
end

--- Project-aware Telescope live-grep.

function Editor.live_grep()
  require("telescope.builtin").live_grep({ cwd = U.project_root() })
end

--- Replace the word under the cursor across the whole buffer.

function Editor.replace_word()
  local cursor   = api.nvim_win_get_cursor(0)

  local word     = fn.expand("<cword>")

  local new_word = fn.input("Replace '" .. word .. "' with: ")

  if new_word ~= "" then
    local count = fn.searchcount({ pattern = word, recompute = true }).total

    vim.cmd(string.format("%%s/%s/%s/g", word, new_word))

    print(count .. " instances replaced")
  end

  api.nvim_win_set_cursor(0, cursor)

  vim.cmd("normal! zz")
end

--- Copy a Python relative import path for the word under the cursor.

function Editor.copy_python_import()
  local word      = fn.expand("<cword>")

  local dir       = fn.expand("%:.")

  local formatted = dir:gsub("/", "."):gsub("%.py$", "")

  local output    = "from " .. formatted .. " import " .. word

  fn.setreg("0", output)

  fn.setreg("+", output)

  notify("Relative path copied to clipboard", vim.log.levels.INFO)
end

--- Insert a Python `print(f"var={var}")` debug line above the cursor.

function Editor.insert_python_print()
  local var = fn.input("(Python) Print: ")

  if var == "" then return end

  local row    = unpack(api.nvim_win_get_cursor(0))

  local indent = api.nvim_get_current_line():match("^%s*") or ""

  local line   = indent .. string.format('print(f"%s={%s}")', var, var)

  if api.nvim_get_mode().mode:match("^i") then
    api.nvim_feedkeys(api.nvim_replace_termcodes("<Esc>", true, false, true), "n", true)
  end

  api.nvim_buf_set_text(0, row - 1, 0, row - 1, 0, { line })
end

--- Jump the cursor to the horizontal middle of the current line.

function Editor.goto_line_middle()
  fn.cursor(0, math.floor(fn.col("$") / 2))

  vim.cmd("normal! zz")
end

--- Open the keymaps file for editing.

function Editor.edit_keymaps()
  vim.cmd("edit $HOME/.config/nvim/lua/config/keymaps.lua")

  notify("Edit Keymaps!")
end

-- ── 3f  LLM TOOL ─────────────────────────────────────────────────────────────



local LLM         = {}
local PROMPT_PATH = "$HOME/.config/nvim/scripts/system_prompt.txt"
local SCRIPT_PATH = "$HOME/.config/nvim/scripts/llm-tool.sh"
local CONVO_DIR   = "$HOME/conversations/"
local DEFAULT_SYS = "IMPORTANT: Your response must always be in English language."

--- Save floating-window buffer to disk with a timestamped filename.
---@param buf integer
local function _save_conversation(buf)
  local dir = fn.expand(CONVO_DIR)

  if fn.isdirectory(dir) == 0 then fn.mkdir(dir, "p") end

  local file = io.open(dir .. "conversation_" .. os.date("%Y%m%d_%H%M%S") .. ".txt", "w")

  if file then
    file:write(table.concat(api.nvim_buf_get_lines(buf, 0, -1, false), "\n"))

    file:close()

    notify("Conversation saved → " .. dir, vim.log.levels.INFO)
  end
end



--- Run the external LLM shell script on the visually selected text.

function LLM.run()
  vim.cmd('noau normal! "vy')

  local selected = fn.getreg("v")



  local user_prompt = fn.input("Prompt: ")

  if user_prompt == "" then
    notify("llm tool cancelled", vim.log.levels.WARN)

    return
  end



  local sys_prompt = U.read_file(PROMPT_PATH) or DEFAULT_SYS

  local payload    = sys_prompt .. user_prompt .. "\n\nCONTEXT/CODE:\n" .. selected

  local script     = fn.expand(SCRIPT_PATH)



  -- Build the "thinking…" placeholder centred in the window

  local width, height = math.floor(vim.o.columns * 0.8), math.floor(vim.o.lines * 0.8)

  local placeholder   = "thinking..."

  local pad_lines     = {}

  for _ = 1, math.floor(height / 2) do table.insert(pad_lines, "") end

  table.insert(pad_lines, string.rep(" ", math.floor((width - #placeholder) / 2)) .. placeholder)



  local buf = api.nvim_create_buf(false, true)

  api.nvim_set_option_value("filetype", "markdown", { buf = buf })

  api.nvim_buf_set_lines(buf, 0, -1, false, pad_lines)



  local win = U.float_win(buf, width, height, {

    footer     = " [q] quit ",

    footer_pos = "center",

  })

  for opt, val in pairs({ number = true, relativenumber = true, numberwidth = 4, wrap = true }) do
    api.nvim_set_option_value(opt, val, { win = win })
  end

  vim.wo.wrap = true



  -- q → save and close

  map("n", "q", function()
    _save_conversation(buf)

    U.close_win(win)

    api.nvim_buf_delete(buf, { force = true })
  end, { buffer = buf, silent = true })



  fn.jobstart({ script, payload }, {

    stdout_buffered = true,

    on_stdout = function(_, data)
      if data and #data > 0 and data[1] ~= "" then
        api.nvim_buf_set_lines(buf, 0, -1, false, data)
      end
    end,

    on_stderr = function(_, data)
      if data and #data > 1 then
        notify("LLM error: " .. table.concat(data, "\n"), vim.log.levels.ERROR)
      end
    end,

  })
end

-- ─────────────────────────────────────────────────────────────────────────────

-- § 4  KEYMAP REGISTRY  (data-driven — no logic here, only declarations)

-- ─────────────────────────────────────────────────────────────────────────────



-- Each entry: { modes, lhs, rhs, opts }

-- `rhs` may be a string (passed straight to `map`) or a function.



local MAPS = {



  -- ── SEARCH / FILES ──────────────────────────────────────────────────────
  { "n",               "<leader><leader>", Editor.find_files,              { desc = "Find Files" } },
  { "n",               "<leader>fg",       Editor.live_grep,               { desc = "Find with GREP" } },

  -- ── MARKS ───────────────────────────────────────────────────────────────
  { "n",               "<Tab>ml",          Marks.list,                     { desc = "List marks" } },
  { "n",               "<Tab>ma",          Marks.add,                      { desc = "Add Global Mark" } },
  { "n",               "<Tab>md",          Marks.delete,                   { desc = "Delete Mark UI" } },

  -- ── DELETE / YANK ────────────────────────────────────────────────────────
  { "n",               "D",                '"_ld$',                        { desc = "Delete until EOL" } },
  { { "n", "x" },      "d",                '"_d',                          { noremap = true, silent = true, desc = "Delete without yanking" } },
  { "n",               "dd",               '"_dd',                         { noremap = true, silent = true, desc = "Delete line without yanking" } },
  { "n",               "<Tab>y",           "yiw",                          { noremap = true, silent = true, desc = "Yank word" } },
  { "n",               "<Tab>c",           '"_ciw',                        { noremap = true, silent = true, desc = "Change word" } },
  { "n",               "C",                '"_ciw',                        { noremap = true, silent = true, desc = "Change word" } },
  { { "n", "t" },      "<Tab>p",           '"_ciw<C-r>0<Esc>',             { noremap = true, silent = true, desc = "Paste inside word" } },

  -- ── BUFFERS ──────────────────────────────────────────────────────────────
  { "n",               "<Tab>x",           Buf.close_current,              { noremap = true, silent = true, desc = "Close current buffer" } },
  { "n",               "<Tab>X",           Buf.close_all,                  { noremap = true, silent = true, desc = "Close all buffers" } },
  { "n",               "<leader><Right>",  "<Cmd>silent! bnext<CR>",       { noremap = true, silent = true } },
  { "n",               "<leader><Left>",   "<Cmd>silent! bprevious<CR>",   { noremap = true, silent = true } },

  -- ── MOTION ───────────────────────────────────────────────────────────────
  { "n",               "gg",               "gg_",                          { noremap = true, silent = true } },
  { "n",               "G",                "G_",                           { noremap = true, silent = true } },
  { "n",               "$",                "$h",                           { noremap = true, silent = true } },
  { { "n", "v" },      "<Home>",           "_",                            { noremap = true, silent = true } },
  { "n",               "<C-d>",            "<Cmd>normal! <C-d>zz0<CR>",    { noremap = true, silent = true } },
  { "n",               "<C-u>",            "<Cmd>normal! <C-u>zz0<CR>",    { noremap = true, silent = true } },
  { { "n", "v", "x" }, "<Up>",             "<Up>zz",                       { noremap = true, silent = true } },
  { { "n", "v", "x" }, "<Down>",           "<Down>zz",                     { noremap = true, silent = true } },
  { "n",               "<S-Up>",           "<Up>0_zz",                     { noremap = true, silent = true } },
  { "n",               "<S-Down>",         "<Down>0_zz",                   { noremap = true, silent = true } },
  { "n",               "<BS>",             "_zz",                          { noremap = true, silent = true } },
  { { "n", "v" },      "k",                "kzz",                          { noremap = true, silent = true } },
  { { "n", "v" },      "j",                "jzz",                          { noremap = true, silent = true } },
  { { "n", "v" },      "<PageDown>",       "<C-d>zz0",                     { desc = "Half page down" } },
  { { "n", "v" },      "<PageUp>",         "<C-u>zz0",                     { desc = "Half page up" } },
  { "n",               "<Tab><Down>",      Editor.goto_line_middle,        { noremap = true, silent = true, desc = "Middle of line" } },
  { "n",               "<Tab>0",           Editor.goto_line_middle,        { noremap = true, silent = true, desc = "Middle of line" } },
  { { "n", "v" },      "<C-Right>",        "e",                            { noremap = true, silent = true } },
  { { "n", "v" },      "<C-Left>",         "b",                            { noremap = true, silent = true } },
  { { "n", "v" },      "<S-l>",            "w",                            { noremap = true, silent = true } },
  { { "n", "v" },      "<S-h>",            "b",                            { noremap = true, silent = true } },
  { { "n", "v" },      "<C-l>",            "$",                            { noremap = true, silent = true } },
  { { "n", "v" },      "<C-h>",            "_",                            { noremap = true, silent = true } },
  { "n",               "<Tab><Right>",     "$",                            { noremap = true, silent = true, desc = "Go right" } },
  { { "n", "v" },      "<Tab><Left>",      "_",                            { noremap = true, silent = true, desc = "Go left" } },
  { { "n", "v" },      "<Tab><Up>",        "<Cmd>0<CR><Cmd>normal! _<CR>", { noremap = true, silent = true, desc = "Go top" } },
  { "n",               "<Tab>b",           "/[({\\[]<CR>",                 { noremap = true, silent = true, desc = "Next bracket" } },
  { "n",               "<Tab>B",           "?[])}>]<CR>",                  { noremap = true, silent = true, desc = "Prev bracket" } },

  -- ── LSP / FORMAT ─────────────────────────────────────────────────────────
  { "n",               "<Tab>f",           LSP.format_file,                { noremap = true, silent = true, desc = "Format file" } },
  { "n",               "<Tab>k",           LSP.actions_and_format,         { noremap = true, silent = true, desc = "LSP actions + format" } },
  { "n",               "<Tab>d",           LSP.go_to_definition,           { noremap = true, silent = true, desc = "LSP Definition" } },

  -- ── HEALTH BAR ───────────────────────────────────────────────────────────
  { "n",               "<Tab>ho",          ":Healthbar open<CR>",          { noremap = true, silent = true, desc = "Open healthbar" } },
  { "n",               "<Tab>hc",          ":Healthbar close<CR>",         { noremap = true, silent = true, desc = "Close healthbar" } },
  { "n", "<Tab>hh", function()
    notify("HEAL!!")
    vim.cmd("Healthbar reset")
  end, { desc = "Heal healthbar" } },

  -- ── INSERT / EDIT ─────────────────────────────────────────────────────────
  { "n",               "o",         "o<Esc>zz",                              { noremap = true, silent = true } },
  { "n",               "O",         "O<Esc>zz",                              { noremap = true, silent = true } },
  { "n",               "<S-a>",     "a",                                     { noremap = true, silent = true } },

  -- ── REPLACE / PATHS ──────────────────────────────────────────────────────
  { "n",               "<leader>r", Editor.replace_word,                     { desc = "Replace word" } },
  { "n",               "<leader>p", Editor.copy_python_import,               { noremap = true, silent = true } },

  -- ── CONFIG ────────────────────────────────────────────────────────────────
  { "n",               "<F5>",      Config.reload,                           { desc = "Reload keymaps" } },
  { "n",               "<Tab>.",    Editor.edit_keymaps,                     { noremap = true, desc = "Edit keymaps file" } },
  { "n",               "<leader>m", "<Cmd>Mason<CR>",                        { noremap = true, silent = true } },
  { "n",               "<leader>M", "<Cmd>LazyExtras<CR>",                   { noremap = true, silent = true } },

  -- ── TERMINAL ──────────────────────────────────────────────────────────────
  { { "n", "i", "t" }, "<F6>",      "<Cmd>terminal<CR><Cmd>startinsert<CR>", { noremap = true, silent = true } },


  -- ── LLM TOOL ─────────────────────────────────────────────────────────────
  { "v",               "<Tab>m",    LLM.run,                                 { silent = true, desc = "LLM tool" } },

  -- ── DEBUG ─────────────────────────────────────────────────────────────────
  { { "n", "i" },      "<F1>",      Editor.insert_python_print,              {} },
}

-- ─────────────────────────────────────────────────────────────────────────────
-- § 5  PARAMETRIC MAP GROUPS  (loops that generate multiple mappings)
-- ─────────────────────────────────────────────────────────────────────────────
---@param char string
local function _make_append_handler(char)
  return function()
    api.nvim_feedkeys(
      api.nvim_replace_termcodes("<Esc>", true, false, true), "x", false
    )
    for lnum = fn.line("'<"), fn.line("'>") do
      fn.setline(lnum, fn.getline(lnum) .. char)
    end
  end
end

local function _register_parametric_maps()
  for _, char in ipairs({ ",", ";", ":", "=" }) do
    map("v", "<Tab>a" .. char,
      _make_append_handler(char),
      { noremap = true, silent = true, desc = "Append [" .. char .. "] to block" })
  end

  local delimiters = {
    ["{"] = "}",
    ["("] = ")",
    ["["] = "]",
    ["q"] = '"',
    ["s"] = "'",
    ["b"] = "`",
  }
  for trigger, target in pairs(delimiters) do
    map("x", "<leader>z" .. trigger,
      "gsa" .. target .. "h",
      { remap = true, silent = true, desc = "Surround with " .. target })
  end

  local function _term_close()
    local mode = fn.mode()
    if mode == "i" then
      api.nvim_feedkeys(api.nvim_replace_termcodes("<Esc>", true, false, true), "n", true)
    elseif mode == "t" then
      api.nvim_feedkeys(api.nvim_replace_termcodes("<C-\\><C-n>", true, false, true), "n", true)
    end
    vim.cmd("bd!")
  end

  for _, key in ipairs({ "<F4>", "<F12>" }) do
    map({ "n", "i", "t" }, key, _term_close, { noremap = true, silent = true })
  end



  -- Window navigation from terminal

  map({ "n", "t" }, "<C-Up>", [[<C-\><C-n><C-w>k]], { desc = "Move Up" })
  map({ "n", "t" }, "<C-Down>", [[<C-\><C-n><C-w>j]], { desc = "Move Down" })
end

-- ─────────────────────────────────────────────────────────────────────────────
-- § 6  DEAD KEYS  (intentional no-ops)
-- ─────────────────────────────────────────────────────────────────────────────
local function _register_dead_keys()
  -- Suppress accidental resize chords in every mode
  local all_modes = { "n", "i", "v", "x", "s", "o", "t", "c" }
  for _, mode in ipairs(all_modes) do
    map(mode, "<C-W><Up>", "<NOP>", { noremap = true, silent = true })
    map(mode, "<C-W><Down>", "<NOP>", { noremap = true, silent = true })
  end

  -- Single-mode no-ops
  local nops = {
    { { "i", "n", "v", "c" },                "<Insert>" },
    { { "n", "v" },                          "." },
    { { "n", "i", "v", "x", "o", "c", "t" }, "<C-/>" },
    { "n",                                   "Q" },
    { "n",                                   "q" },
    { "n",                                   "<C-q>" },
    { "n",                                   "@" },
    { "n",                                   "@@" },
    { "n",                                   "<C-S-Up>" },
    { "n",                                   "<C-S-Down>" },
    { { "n", "v" },                          "<C-S-Right>" },
    { { "n", "v" },                          "<C-S-Left>" },
    { { "n", "v" },                          "H" },
    { { "n", "v" },                          "J" },
    { { "n", "v" },                          "K" },
    { { "n", "v" },                          "L" },
    { { "n", "v" },                          "Y" },
    { { "n", "v" },                          "P" },
  }

  for _, entry in ipairs(nops) do
    map(entry[1], entry[2], "<Nop>", { noremap = true, silent = true })
  end
end

-- ─────────────────────────────────────────────────────────────────────────────
-- § 7  BOOTSTRAP  (single entry-point; apply everything)
-- ─────────────────────────────────────────────────────────────────────────────
function M.setup()
  for _, entry in ipairs(MAPS) do
    local modes, lhs, rhs, opts = entry[1], entry[2], entry[3], entry[4]
    map(modes, lhs, rhs, opts)
  end
  _register_parametric_maps()
  _register_dead_keys()
end

M.setup()


return M
