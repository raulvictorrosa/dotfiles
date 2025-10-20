local wezterm = require 'wezterm'

-- This will hold the configuration.
local config = wezterm.config_builder()

-- This is where you actually apply your config choices.
config.font_size = 14
config.color_scheme = 'Dracula'
config.font = wezterm.font('JetBrains Mono', { weight = 'Bold' })

return config
