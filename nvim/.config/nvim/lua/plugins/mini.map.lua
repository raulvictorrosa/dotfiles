-- Code minimap on the right, like VS Code's. mini.map does not open by itself
-- (and needs setup() called), so open it when a file is shown (see `config`).
-- Keys: <leader>mt toggle, <leader>mf focus the map and browse (<CR> accept, <Esc> cancel),
-- <leader>ms switch side. With `focusable = true` the mouse can enter the map window too.
---@module "lazy"
---@type LazySpec
return {
  "nvim-mini/mini.map",
  version = "*",
  event = "VeryLazy",
  keys = {
    {
      "<leader>mt",
      function()
        require("mini.map").toggle()
      end,
      desc = "Minimap: toggle",
    },
    {
      "<leader>mf",
      function()
        require("mini.map").toggle_focus()
      end,
      desc = "Minimap: focus and browse",
    },
    {
      "<leader>ms",
      function()
        require("mini.map").toggle_side()
      end,
      desc = "Minimap: switch side",
    },
  },
  opts = function()
    local map = require("mini.map")
    return {
      integrations = {
        map.gen_integration.builtin_search(),
        map.gen_integration.diagnostic(),
        map.gen_integration.gitsigns(),
      },
      window = {
        focusable = true,
        width = 14,
        winblend = 25,
        show_integration_count = false,
      },
    }
  end,
  config = function(_, opts)
    local map = require("mini.map")
    map.setup(opts)

    -- Show the map only once a file is on screen, not on the dashboard / empty start.
    -- It opens on the "no file -> file" transition only, so a manual <leader>mt close sticks.
    local was_file = false
    local function sync()
      local buf = vim.api.nvim_get_current_buf()
      -- Special windows (the map itself, help, trees...) must not change anything.
      if vim.bo[buf].buftype ~= "" and vim.bo[buf].filetype ~= "snacks_dashboard" then
        return
      end
      local is_file = vim.bo[buf].buftype == "" and vim.api.nvim_buf_get_name(buf) ~= ""
      if is_file and not was_file then
        map.open()
      elseif not is_file then
        map.close()
      end
      was_file = is_file
    end
    vim.api.nvim_create_autocmd("BufEnter", {
      callback = function()
        vim.schedule(sync)
      end,
    })
    sync()
  end,
}
