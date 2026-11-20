---@module "lazy"
---@module "noice"
---@type LazySpec
return {
  "folke/noice.nvim",
  ---@type NoiceConfig
  opts = {
    presets = {
      -- noice replaces vim.lsp.buf.hover (K) and signature help with its own windows,
      -- which ignore 'winborder' and are borderless unless this preset is on.
      lsp_doc_border = true,
    },
    views = {
      hover = {
        win_options = {
          -- The border defaults to FloatBorder, which some colorschemes leave almost
          -- the same colour as the popup; use the (visible) cmdline popup border instead.
          winhighlight = { Normal = "NoicePopup", FloatBorder = "NoiceCmdlinePopupBorder" },
        },
      },
    },
  },
}
