---@module "lazy"
---@module "lazyvim"
---@type LazySpec
return {
  "nvim-treesitter/nvim-treesitter",
  ---@type lazyvim.TSConfig
  ---@diagnostic disable-next-line: missing-fields
  opts = {
    ensure_installed = {
      "bash",
      "html",
      "javascript",
      "json",
      "latex",
      "lua",
      "markdown",
      "markdown_inline",
      "python",
      "query",
      "regex",
      "tsx",
      "typescript",
      "vim",
      "yaml",
    },
  },
}
