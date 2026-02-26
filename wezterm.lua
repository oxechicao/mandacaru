local wezterm = require("wezterm")
local config = wezterm.config_builder()
local act = wezterm.action

-- Window
config.initial_cols = 120
config.initial_rows = 50
config.max_fps = 100
config.prefer_egl = true
config.enable_tab_bar = false
config.window_background_opacity = 1
config.macos_window_background_blur = 100

-- Editor
config.font_size = 15
config.line_height = 1
config.font = wezterm.font_with_fallback({
  { family = "OpenDyslexicM Nerd Font Mono", weight = "Regular" },
  { family = "MartianMono Nerd Font Mono", weight = "Regular", stretch = "Condensed" },
})

-- color
local theme = wezterm.plugin.require("https://github.com/neapsix/wezterm").main
config.colors = theme.colors()

-- actions
config.keys = {
  { key = "LeftArrow", mods = "OPT", action = act.SendString("\x1b[1;5D") },
  { key = "RightArrow", mods = "OPT", action = act.SendString("\x1b[1;5C") },
  { key = "LeftArrow", mods = "CMD", action = act.SendString("\x01") },
  { key = "RightArrow", mods = "CMD", action = act.SendString("\x05") },
}

return config
