--=================--
-- Initializations
--=================--
local wezterm = require("wezterm")
local act = wezterm.action
local config = wezterm.config_builder()
local resurrect = wezterm.plugin.require("https://github.com/MLFlexer/resurrect.wezterm")
--=========--
-- CONFIGs
--=========--
--------------------------
---- General settings
--------------------------
-------- Window --------
config.initial_cols = 120
config.initial_rows = 50
config.max_fps = 120
config.prefer_egl = true
config.enable_tab_bar = false
config.window_background_opacity = 1
config.macos_window_background_blur = 100
-------- Font --------
config.font_size = 12
config.line_height = 1.4
config.font = wezterm.font_with_fallback({
  { family = "Monoid Nerd Font Mono", weight = "Regular" },
  { family = "Mononoki Nerd Font Mono", weight = "Regular" },
  { family = "OpenDyslexicM Nerd Font Mono", weight = "Regular" },
  { family = "MartianMono Nerd Font Mono", weight = "Regular", stretch = "Condensed" },
})
-------- Colors --------
local theme = wezterm.plugin.require("https://github.com/neapsix/wezterm").moon
config.colors = theme.colors()
--================--
-- Plugins config
--================--
----------------
---- RESURRECT
------ Resurrect your terminal environment!⚰️
------ A plugin to save the state of your windows, tabs and panes.
------ Inspired by tmux-resurrect and tmux-continuum.
----------------
resurrect.state_manager.periodic_save({
  interval_seconds = 10,
  save_workspaces = false,
  save_windows = false,
  save_tabs = true,
})
wezterm.on("smart_workspace_switcher.workspace_switcher.created", function(window, path, label)
  local workspace_state = resurrect.workspace_state
  workspace_state.restore_workspace(resurrect.state_manager.load_state(label, "workspace"), {
    window = window,
    relative = true,
    restore_text = true,
    on_pane_restore = resurrect.tab_state.default_on_pane_restore,
  })
end)
--- Saves the state whenever I select a workspace
wezterm.on("smart_workspace_switcher.workspace_switcher.selected", function(window, path, label)
  local workspace_state = resurrect.workspace_state
  resurrect.state_manager.save_state(workspace_state.get_workspace_state())
  resurrect.state_manager.write_current_state(label, "tabs")
end)
wezterm.on("gui-startup", resurrect.state_manager.resurrect_on_gui_startup)
--============================--
-- KEYS actions / Keybindings
--============================--
config.send_composed_key_when_left_alt_is_pressed = false
config.send_composed_key_when_right_alt_is_pressed = false
config.leader = { key = "a", mods = "CTRL" }
config.keys = {
  -------- Movement between words ---------
  { key = "LeftArrow", mods = "OPT", action = act.SendKey({ key = "b", mods = "ALT" }) },
  { key = "RightArrow", mods = "OPT", action = act.SendKey({ key = "f", mods = "ALT" }) },
  { key = "Backspace", mods = "OPT", action = act.SendKey({ key = "\x08", mods = "ALT" }) },
  -- { key = "LeftArrow", mods = "OPT", action = act.SendString("\x1b[1;5D") },
  -- { key = "RightArrow", mods = "OPT", action = act.SendString("\x1b[1;5C") },
  { key = "LeftArrow", mods = "CMD", action = act.SendString("\x01") },
  { key = "RightArrow", mods = "CMD", action = act.SendString("\x05") },
  -------- Ressurect actions --------
  {
    key = "r",
    mods = "LEADER",
    action = wezterm.action_callback(function(win, pane)
      resurrect.fuzzy_loader.fuzzy_load(win, pane, function(id, label)
        local type = string.match(id, "^([^/]+)") -- match before '/'
        id = string.match(id, "([^/]+)$") -- match after '/'
        id = string.match(id, "(.+)%..+$") -- remove file extention
        local opts = {
          relative = true,
          restore_text = true,
          on_pane_restore = resurrect.tab_state.default_on_pane_restore,
        }
        if type == "workspace" then
          local state = resurrect.state_manager.load_state(id, "workspace")
          resurrect.workspace_state.restore_workspace(state, opts)
        elseif type == "window" then
          local state = resurrect.state_manager.load_state(id, "window")
          resurrect.window_state.restore_window(pane:window(), state, opts)
        elseif type == "tab" then
          local state = resurrect.state_manager.load_state(id, "tab")
          resurrect.tab_state.restore_tab(pane:tab(), state, opts)
        end
      end)
    end),
  },
  {
    key = "s",
    mods = "LEADER",
    action = wezterm.action_callback(function(win, pane)
      resurrect.fuzzy_loader.fuzzy_load(win, pane, function(id, label)
        local type = string.match(id, "^([^/]+)") -- match before '/'
        id = string.match(id, "([^/]+)$") -- match after '/'
        id = string.match(id, "(.+)%..+$") -- remove file extention
        local opts = {
          relative = true,
          restore_text = true,
          window = pane:window(),
          -- tab = win:active_tab(),
          close_open_tabs = true,
          on_pane_restore = resurrect.tab_state.default_on_pane_restore,
        }
        if type == "workspace" then
          local state = resurrect.state_manager.load_state(id, "workspace")
          resurrect.workspace_state.restore_workspace(state, opts)
        elseif type == "window" then
          local state = resurrect.state_manager.load_state(id, "window")
          resurrect.window_state.restore_window(pane:window(), state, opts)
        elseif type == "tab" then
          local state = resurrect.state_manager.load_state(id, "tab")
          resurrect.tab_state.restore_tab(pane:tab(), state, opts)
        end
      end)
    end),
  },
  {
    -- Delete a saved session using a fuzzy finder
    key = "d",
    mods = "LEADER",
    action = wezterm.action_callback(function(win, pane)
      resurrect.fuzzy_load(win, pane, function(id)
        resurrect.delete_state(id)
      end, {
        title = "Delete State",
        description = "Select session to delete and press Enter = accept, Esc = cancel, / = filter",
        fuzzy_description = "Search session to delete: ",
        is_fuzzy = true,
      })
    end),
  },
}
return config
