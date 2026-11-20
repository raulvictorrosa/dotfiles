-- Code minimap on the right, like VS Code's. mini.map does not open by itself
-- (and needs setup() called), so open it once everything has loaded.
-- Keys: <leader>mt toggle, <leader>mf focus the map and browse (<CR> accept, <Esc> cancel),
-- <leader>ms switch side. With `focusable = true` the mouse can enter the map window too.
return {
  "nvim-mini/mini.map",
  version = "*",
  event = "VeryLazy",
  keys = {
    { "<leader>mt", function() require("mini.map").toggle() end, desc = "Minimap: toggle" },
    { "<leader>mf", function() require("mini.map").toggle_focus() end, desc = "Minimap: focus and browse" },
    { "<leader>ms", function() require("mini.map").toggle_side() end, desc = "Minimap: switch side" },
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
    map.open()
  end,
}
