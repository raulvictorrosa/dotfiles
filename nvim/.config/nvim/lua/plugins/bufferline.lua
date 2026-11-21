---@module "lazy"
---@module "bufferline"
---@type LazySpec
return {
  "akinsho/bufferline.nvim",
  ---@type bufferline.UserConfig
  opts = {
    options = {
      always_show_bufferline = true,
    },
  },
}
