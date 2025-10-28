-- Dracula Theme
-- Configuration is done via vim global variables in the config function
-- Available variables: g:dracula_bold, g:dracula_italic, g:dracula_strikethrough,
-- g:dracula_underline, g:dracula_undercurl, g:dracula_full_special_attrs_support,
-- g:dracula_inverse, g:dracula_colorterm, g:dracula_high_contrast_diff

---@class DraculaConfigVars
---@field dracula_bold? boolean Enable bold text styling (default: 1)
---@field dracula_italic? boolean Enable italic text styling (default: 1)
---@field dracula_strikethrough? boolean Enable strikethrough text styling (default: 1)
---@field dracula_underline? boolean Enable underline text styling (default: 1)
---@field dracula_undercurl? boolean Enable undercurl text styling (default: same as underline)
---@field dracula_full_special_attrs_support? boolean Enable full special attributes support (default: has('gui_running'))
---@field dracula_inverse? boolean Enable inverse colors (default: 1)
---@field dracula_colorterm? boolean Enable colorterm support (default: 1)
---@field dracula_high_contrast_diff? boolean Enable high contrast diff colors (default: 0)

---@class DraculaPlugin
---@field [1] "dracula/vim" Plugin repository
---@field name? string Plugin name
---@field lazy? boolean Lazy load the plugin
---@field priority? number Load priority (higher = earlier)
---@field event? string|string[] Events to trigger loading
---@field cmd? string|string[] Commands to trigger loading
---@field ft? string|string[] Filetypes to trigger loading
---@field keys? string|table[] Key mappings to trigger loading
---@field dependencies? string|string[] Plugin dependencies
---@field config? function|boolean Configuration function
---@field init? function Initialization function
---@field opts? table|function Plugin options/config (use vim.g in config function)
---@field build? string|function Build command
---@field cond? boolean|function Condition to load plugin
---@field enabled? boolean|function Enable/disable plugin

---@class LazyVimPlugin
---@field [1] "LazyVim/LazyVim" Plugin repository
---@field opts? table Plugin options

---@type (DraculaPlugin|LazyVimPlugin)[]
return {
  {
    "dracula/vim",
    name = "dracula",
  },
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "dracula",
    },
  },
}
