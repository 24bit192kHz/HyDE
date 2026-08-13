-- Hyprland loads this file when it is started without a config, and it prefers
-- it over hyprland.conf. HyDE loads it too, last, as the override layer below.
-- The block keeps the two apart: hyde.lua sets `hyde` on its first line, so it
-- runs only when this file is the entry point and HyDE has not been loaded.
-- Removing it leaves a session with a cursor and nothing else.
if not hyde then
	local share = os.getenv("XDG_DATA_HOME") or (os.getenv("HOME") .. "/.local/share")
	local entry = share .. "/hypr/hyde.lua"
	local handle = io.open(entry, "r")
	if not handle then
		error("HyDE is not installed at " .. entry .. ". Run install.sh -r, or point Hyprland at your own config.")
	end
	handle:close()
	dofile(entry)
end

-- Machine overrides for btw (CachyOS + Hyprland + RTX 3080 Ti).
-- Ported from live userprefs.conf / keybindings.conf onto HyDE's lua-only tree.

hl.on("hyprland.start", function()
	hl.exec_cmd("openrgb -p pf1")
	hl.exec_cmd("bash ~/.local/bin/startup-layout")
	hl.exec_cmd("xrdb -merge ~/.Xresources")
	hl.exec_cmd("/home/btw/mhm/hyprshaderd/hyprshaderd")
	hl.exec_cmd("/home/btw/.local/bin/earth-native start")
	hl.exec_cmd("systemctl --user start pcpanel.service")
end)

hl.env("WALLPAPER_BACKEND", "hyprpaper")
hl.env("GTK_USE_PORTAL", "1")
hl.env("GDK_DEBUG", "portals")
hl.env("HYPRLIGHTD_BRIGHTNESS_NORMAL", "0.55")

hl.config({
	input = {
		kb_layout = "us,ara",
		kb_options = "grp:caps_toggle",
		repeat_delay = 250,
		repeat_rate = 50,
		touchpad = {
			natural_scroll = false,
		},
	},
	render = {
		cm_auto_hdr = 1,
		cm_enabled = true,
	},
	debug = {
		full_cm_proto = true,
	},
	decoration = {
		active_opacity = 1.0,
		inactive_opacity = 1.0,
		fullscreen_opacity = 1.0,
		blur = {
			enabled = true,
			size = 8,
			passes = 2,
		},
	},
	misc = {
		allow_session_lock_restore = true,
	},
	workspace = {
		"1,monitor:DP-1",
		"2,monitor:DP-1",
		"9,monitor:DP-1",
		"3,monitor:DP-2",
		"4,monitor:DP-2",
	},
})

hl.animation({ leaf = "windows", enabled = true, speed = 2.5, bezier = "default", style = "popin 60%" })
hl.animation({ leaf = "windowsIn", enabled = true, speed = 2.5, bezier = "default", style = "popin 60%" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 2.5, bezier = "default", style = "popin 60%" })
hl.animation({ leaf = "windowsMove", enabled = true, speed = 2.5, bezier = "default", style = "slide" })
hl.animation({ leaf = "layers", enabled = true, speed = 2.5, bezier = "default", style = "popin" })
hl.animation({ leaf = "fade", enabled = true, speed = 2.5, bezier = "default" })
hl.animation({ leaf = "fadeIn", enabled = true, speed = 2.5, bezier = "default" })
hl.animation({ leaf = "fadeOut", enabled = true, speed = 2.5, bezier = "default" })
hl.animation({ leaf = "fadeSwitch", enabled = true, speed = 2.5, bezier = "default" })
hl.animation({ leaf = "fadeShadow", enabled = true, speed = 2.5, bezier = "default" })
hl.animation({ leaf = "fadeDim", enabled = true, speed = 2.5, bezier = "default" })
hl.animation({ leaf = "fadeLayers", enabled = true, speed = 2.5, bezier = "default" })
hl.animation({ leaf = "workspaces", enabled = true, speed = 2.5, bezier = "default", style = "slide" })
hl.animation({ leaf = "border", enabled = true, speed = 2.5, bezier = "liner" })
hl.animation({ leaf = "borderangle", enabled = true, speed = 2.5, bezier = "liner", style = "once" })
hl.animation({ leaf = "specialWorkspace", enabled = false, speed = 0, bezier = "default" })

hl.window_rule({
	match = { class = "^(kitty)$" },
	no_blur = true,
})

hl.window_rule({
	match = { class = "^(com.getpcpanel.MainFX)$" },
	workspace = "9 silent",
})

hl.window_rule({
	name = "furmark_at_cursor",
	match = { initial_title = "^(GeeXLab Player)(.*)$" },
	float = true,
	move = "(cursor_x-(window_w*0.5)) (cursor_y-(window_h*0.5))",
})

-- Lua's bind parser drops ALT_R as a modifier (it is a keysym), so the live
-- Alt_R+Control_R waybar toggle cannot be registered with hl.bind. Inject the
-- exact hyprlang bind instead.
hl.exec_cmd(
	"hyprctl keyword bindd 'Alt_R, Control_R, [Window Management] toggle waybar and reload config, exec, hyde-shell waybar --hide'"
)
