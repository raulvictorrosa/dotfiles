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
  },
}
