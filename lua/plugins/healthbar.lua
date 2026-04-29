return {
  "healthbar",
  dir = "~/.config/nvim/lua/plugins",
  config = function()
    local health_win = nil
    local health_buf = nil
    local health_chan = nil -- Store the channel ID here

    local function close_health()
      if health_win and vim.api.nvim_win_is_valid(health_win) then
        vim.api.nvim_win_close(health_win, true)
      end
      health_win = nil
      health_chan = nil
    end

    local function open_health()
      if health_win and vim.api.nvim_win_is_valid(health_win) then
        return
      end

      local cols = vim.o.columns
      health_buf = vim.api.nvim_create_buf(false, true)
      health_win = vim.api.nvim_open_win(health_buf, false, {
        relative   = "editor",
        anchor     = "NE",
        row        = 1,
        col        = cols - 2,
        width      = 36,
        height     = 3,
        style      = "minimal",
        border     = "rounded",
        zindex     = 50,
      })

      vim.api.nvim_buf_call(health_buf, function()
        local cmd = "bash $HOME/.config/nvim/scripts/healthbar.sh"
        health_chan = vim.fn.termopen(cmd, {
          on_exit = function()
            close_health()
          end,
        })
      end)
    end

    local function reset_health()
      if health_chan then
        vim.api.nvim_chan_send(health_chan, "r")
      else
        open_health()
      end
    end

    vim.api.nvim_create_user_command("Healthbar", function(opts)
      local action = opts.fargs[1]
      if action == "open" then
        open_health()
      elseif action == "close" then
        close_health()
      elseif action == "reset" then
        reset_health() -- Calls the new logic instead of flickering windows
      else
        print("Usage: :Healthbar [open|close|reset]")
      end

    end, {
        nargs = 1,
        complete = function()
          return { "open", "close", "reset" }
        end,
      })
  end,
}
