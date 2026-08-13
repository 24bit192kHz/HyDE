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

local MOD = hyde.config.modifiers.main

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

-- Overrides HyDE's Super+C editor bind (same flags, last bind wins with dedup).
hl.bind(MOD .. " + C", hl.dsp.exec_cmd("bash ~/mhm/scripts/center.sh"), {
	description = "center window",
})
hl.bind(MOD .. " + SHIFT + C", hl.dsp.exec_cmd("bash ~/mhm/scripts/resize-30.sh"), {
	description = "resize window",
})
hl.bind(MOD .. " + F", hl.dsp.window.fullscreen(0), {
	description = "fullscreen",
})
hl.bind("F9", hl.dsp.exec_cmd("playerctl pause && pamixer -m"), {
	description = "pause media and mute output",
})
hl.bind(MOD .. " + ALT + N", hl.dsp.exec_cmd("/home/btw/.local/bin/earth-native control"), {
	description = "Control native Earth renderer",
})
hl.bind(MOD .. " + ALT + SHIFT + N", hl.dsp.exec_cmd("/home/btw/.local/bin/earth-native restart"), {
	description = "Restart native Earth renderer",
})
hl.bind(MOD .. " + F11", hl.dsp.exec_cmd("/home/btw/mhm/hyprshaderd/hyprshaderd dimmer"), {
	description = "decrease brightness via hyprshaderd",
	repeating = true,
})
hl.bind(MOD .. " + F12", hl.dsp.exec_cmd("/home/btw/mhm/hyprshaderd/hyprshaderd brighter"), {
	description = "increase brightness via hyprshaderd",
	repeating = true,
})
hl.bind(MOD .. " + F1", hl.dsp.exec_cmd("/home/btw/mhm/scripts/songid.sh"), {
	description = "identify playing song",
})
hl.bind(MOD .. " + O", hl.dsp.exec_cmd("/home/btw/mhm/scripts/ocr.sh"), {
	description = "capture text with OCR",
})
hl.bind(MOD .. " + L", hl.dsp.exec_cmd("~/mhm/scripts/lock.sh"), {
	locked = true,
	description = "[Window Management] lock session",
})
