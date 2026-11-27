---@module "lazy"
---@module "lazyvim"
---@type LazySpec
return {
  "LazyVim/LazyVim",
  ---@type LazyVimOptions
  opts = {
    news = {
      lazyvim = false,
      neovim = false,
    },
  },
}
