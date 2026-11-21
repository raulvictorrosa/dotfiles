---@module "lazy"
---@module "which-key"
---@type LazySpec
return {
  "folke/which-key.nvim",
  ---@type wk.Opts
  opts = {
    win = {
      title = true,
      title_pos = "center",
      row = 0.5, -- fractions are % of free space: 0.5 = centered
      col = 0.5,
      no_overlap = false, -- otherwise it jumps below the cursor when they collide
    },
  },
}
