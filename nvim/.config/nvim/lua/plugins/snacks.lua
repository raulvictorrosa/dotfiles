return {
  "folke/snacks.nvim",
  ---@type snacks.Config
  opts = {
    picker = {
      hidden = true, -- Show hidden files in the picker (e.g., using <leader><leader>)
      ignored = true, -- Show files ignored by git in the picker
      sources = {
        files = {
          -- Explicitly set for the 'files' source used by <space><space>
          hidden = true,
          ignored = true,
        },
      },
    },
    explorer = {
      files = {
        hidden = true, -- Show hidden files in the file explorer
        ignored = true, -- Show files ignored by git in the file explorer
      },
    },
  },
  keys = {
    {
      "<leader>e",
      function()
        local explorer_win = nil

        for _, win in ipairs(vim.api.nvim_list_wins()) do
          local buf = vim.api.nvim_win_get_buf(win)
          local ft = vim.bo[buf].filetype
          if ft == "snacks_picker_list" then
            explorer_win = win
            break
          end
        end

        if vim.api.nvim_get_current_win() ~= explorer_win and explorer_win then
          vim.api.nvim_set_current_win(explorer_win)
        else
          Snacks.explorer()
        end
      end,
      desc = "Snacks File Explorer",
    },
  },
}
