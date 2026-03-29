--=================--
-- Initializations
--=================--
local wezterm = require("wezterm")
local act = wezterm.action
local config = wezterm.config_builder()
local resurrect = wezterm.plugin.require("https://github.com/MLFlexer/resurrect.wezterm")
--=========--
-- Functions
--=========--
local function tab_title(tab_info)
	local title = tab_info.tab_title
	if title and #title > 0 then
		return title
	end

	return tab_info.active_pane.title
end
--=========--
-- CONFIGs
--=========--
--------------------------
---- General settings
--------------------------
config.max_fps = 120
-------- Window --------
config.initial_cols = 120
config.initial_rows = 50
config.enable_tab_bar = true
config.tab_bar_at_bottom = true
-------- Font --------
config.freetype_load_flags = "NO_HINTING"
config.font_size = 14
config.line_height = 1
config.font = wezterm.font_with_fallback({
	{ family = "OpenDyslexicM Nerd Font Mono", weight = "Regular" },
	{ family = "Mononoki Nerd Font Mono", weight = "Regular" },
	{ family = "Monoid Nerd Font Mono", weight = "Regular" },
	{ family = "MartianMono Nerd Font Mono", weight = "Regular", stretch = "Condensed" },
})
-------- Colors --------
local theme = wezterm.plugin.require("https://github.com/oxechicao/mandacaru-wezterm").main
config.colors = theme.colors()
config.use_fancy_tab_bar = false
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
config.leader = { key = "g", mods = "CTRL" }
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
	---- TMUX rebindings ----
	{
		-- Rename tab
		key = "$",
		mods = "LEADER",
		action = wezterm.action.PromptInputLine({
			description = "Rename tab:",
			action = wezterm.action_callback(function(window, _, line)
				if line then
					window:active_tab():set_title(line)
				end
			end),
		}),
	},
}
--========--
-- Events --
--========--
wezterm.on("format-tab-title", function(tab)
	local title = tab_title(tab)
	if tab.is_active then
		return {
			{ Text = " " .. title .. " " },
		}
	end
	if tab.is_last_active then
		return {
			{ Text = " " .. title .. "*" },
		}
	end
	return title
end)
return config
