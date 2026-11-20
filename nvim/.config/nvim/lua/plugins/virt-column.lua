-- Rulers at 80/100/120 columns, like VS Code's `editor.rulers`.
-- 'colorcolumn' paints a whole cell (~8.5pt wide); virt-column draws a thin
-- "▏" (1/8 of a cell, ~2px) instead. VS Code puts a ruler after N characters,
-- i.e. at the left edge of column N + 1, hence 81/101/121.
return {
  "lukas-reineke/virt-column.nvim",
  event = "VeryLazy",
  opts = {
    char = "▏",
    virtcolumn = "81,101,121",
    highlight = "VirtColumn",
  },
  config = function(_, opts)
    -- Line colour: the theme's background nudged 15% towards its foreground
    -- (about VS Code's editorRuler.foreground on Dracula: #424450 on #282a36).
    local function set_hl()
      local n = vim.api.nvim_get_hl(0, { name = "Normal", link = false })
      if not (n.bg and n.fg) then
        return vim.api.nvim_set_hl(0, "VirtColumn", { link = "NonText" })
      end
      local function mix(shift)
        return math.floor(bit.band(bit.rshift(n.bg, shift), 0xff) * 0.85 + bit.band(bit.rshift(n.fg, shift), 0xff) * 0.15)
      end
      vim.api.nvim_set_hl(0, "VirtColumn", { fg = mix(16) * 0x10000 + mix(8) * 0x100 + mix(0) })
    end
    set_hl()
    vim.api.nvim_create_autocmd("ColorScheme", { callback = set_hl })
    require("virt-column").setup(opts)
  end,
}
