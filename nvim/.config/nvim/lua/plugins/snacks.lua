---@module "lazy"
---@module "snacks"
---@type LazySpec
return {
  "folke/snacks.nvim",
  ---@type snacks.Config
  opts = {
    scroll = {
      enabled = false, -- Disable scrolling animations
    },
    image = {
      enabled = true, -- Inline image/PDF/LaTeX/Mermaid rendering (needs a kitty-graphics-protocol terminal)
    },
    -- Same split as VS Code: the explorer lists everything (dotfiles and gitignored files),
    -- while the pickers (find files, grep, ...) skip what .gitignore ignores, e.g. node_modules.
    -- <a-i> / <a-h> inside a picker toggle ignored / hidden files when you need them.
    picker = {
      hidden = true, -- Show hidden files in the picker (e.g., using <leader><leader>)
      ignored = false, -- Hide files ignored by git in the picker
      sources = {
        files = {
          -- The 'files' source (<space><space>) has its own defaults and ignores the
          -- picker-level hidden/ignored, so set both explicitly.
          hidden = true,
          ignored = false,
        },
        explorer = {
          hidden = true, -- Show hidden files in the file explorer
          ignored = true, -- Show files ignored by git in the file explorer
          win = {
            list = {
              -- Hybrid line numbers in the explorer, same as the editor, so counts like 5j / 3k
              -- can be read straight off the gutter. Snacks hides them by default. The list
              -- buffer only holds the rows on screen, so the number on the cursor line is the
              -- screen row, not the item's position in the whole tree.
              wo = {
                number = true,
                relativenumber = true,
              },
            },
          },
        },
      },
    },
  },
  keys = {
    {
      -- <leader>e behaves like VS Code's "focus Explorer" instead of LazyVim's plain toggle:
      --   explorer closed                  -> open it
      --   explorer open, cursor in editor  -> move the cursor to the explorer (keeps it open)
      --   cursor already in the explorer   -> close it (Snacks.explorer() toggles)
      -- The explorer is a snacks picker, so its window is found by the "snacks_picker_list"
      -- filetype.
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
