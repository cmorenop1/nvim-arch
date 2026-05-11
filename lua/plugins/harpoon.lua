return {
  "ThePrimeagen/harpoon",
  branch = "harpoon2",
  dependencies = { "nvim-lua/plenary.nvim" },
  keys = function()
    local keys = {
      {
        "<Tab>Q",
        function()
          local harpoon = require("harpoon")
          harpoon:list():add()
          local filename = vim.fn.expand("%:t")
          vim.api.nvim_echo({
            { "[Harpoon] Added ", "None" },
            { filename,           "Title" },
          }, false, {})
        end,
        desc = "Harpoon File",
      },
      {
        "<Tab>q",
        function()
          local harpoon = require("harpoon")

          local function generate_harpoon_picker()
            local file_paths = {}
            for _, item in ipairs(harpoon:list().items) do
              table.insert(file_paths, {
                text = item.value,
                file = item.value,
              })
            end
            return file_paths
          end
          Snacks.picker({
            finder = generate_harpoon_picker,
            win = {
              input = {
                keys = {
                  ["dd"] = { "harpoon_delete", mode = { "n", "x" } },
                },
              },
              list = {
                keys = {
                  ["dd"] = { "harpoon_delete", mode = { "n", "x" } },
                },
              },
            },
            actions = {
              harpoon_delete = function(picker, item)
                local to_remove = item or picker:selected()
                if to_remove then
                  table.remove(harpoon:list().items, to_remove.idx)
                  picker:find({ refresh = true })
                end
              end,
            },
          })

          vim.defer_fn(function()
            vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "n", false)
          end, 10)
        end,
        desc = "Harpoon Picker (Snacks)",
      },
    }
    return keys
  end,
}
