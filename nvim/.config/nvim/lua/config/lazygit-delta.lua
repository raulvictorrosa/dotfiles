-- lazygit (opened from nvim by snacks) takes its UI colours from the active colorscheme,
-- but its diffs are rendered by delta (lazygit/config.yml), whose syntax theme is static
-- (default "Monokai Extended", which looks a lot like Dracula). When --syntax-theme is not
-- given delta falls back to $BAT_THEME, and lazygit inherits nvim's environment, so keep
-- BAT_THEME in sync with the colorscheme. Loaded from config/autocmds.lua.
--
-- Only delta's built-in themes can be matched (`delta --list-syntax-themes`); for any other
-- colorscheme BAT_THEME is unset and delta uses its own default.

---@param name string?
---@return string?
local function delta_theme(name)
  name = (name or ""):lower()
  if name:find("^catppuccin") then
    return vim.o.background == "dark" and "Catppuccin Mocha" or "Catppuccin Latte"
  elseif name:find("^dracula") then
    return "Dracula"
  end
end

local function sync()
  vim.env.BAT_THEME = delta_theme(vim.g.colors_name)
end

vim.api.nvim_create_autocmd("ColorScheme", {
  group = vim.api.nvim_create_augroup("user_lazygit_delta_theme", { clear = true }),
  callback = sync,
})
sync()
