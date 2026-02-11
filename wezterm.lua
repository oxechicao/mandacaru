local wezterm = require("wezterm")
local config = wezterm.config_builder()

-- Window
config.initial_cols = 120
config.initial_rows = 28
config.max_fps = 100
config.prefer_egl = true
config.enable_tab_bar = false
config.window_padding = { left = 0, right = 0, top = 0, bottom = 0 }
config.window_background_opacity = 0.85
config.macos_window_background_blur = 100

-- Editor
config.font_size = 16
config.line_height = 1.2
config.font = wezterm.font_with_fallback({
  { family = "OpenDyslexicM Nerd Font Mono" },
  { family = "MartianMono Nerd Font Mono", stretch = "Condensed", weight = "Regular" },
})
-- color
local theme = wezterm.plugin.require("https://github.com/neapsix/wezterm").moon
config.colors = theme.colors()

-- Finally, return the configuration to wezterm:
return config
