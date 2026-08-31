-- Personal Hyprland overrides (was userprefs.conf).
-- Loaded last from hyprland.lua. Hyprland 0.55+ does not read the .conf file.

local exec_once = {
	"openrgb -p pf1",
	"bash ~/.local/bin/startup-layout",
	"xrdb -merge ~/.Xresources",
	"easyeffects --service-mode --hide-window",
	"/home/btw/mhm/hyprshaderd/hyprshaderd",
	-- Native Vulkan/Wayland Earth wallpaper. Unreal stays for explicit captures.
	"/home/btw/.local/bin/earth-native start",
	"/home/btw/.local/bin/hypr-seat-watch",
	"systemctl --user start pcpanel.service",
}

hl.env("WALLPAPER_BACKEND", "hyprpaper")
hl.env("GTK_USE_PORTAL", "1")
hl.env("GDK_DEBUG", "portals")
hl.env("HYPRLIGHTD_BRIGHTNESS_NORMAL", "0.55")

hl.config({
	cursor = {
		no_hardware_cursors = true,
	},
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
		cm_auto_hdr = 0,
		cm_enabled = true,
	},
	debug = {
		full_cm_proto = true,
	},
	decoration = {
		rounding = 10,
		active_opacity = 1.0,
		inactive_opacity = 1.0,
		fullscreen_opacity = 1.0,
		shadow = {
			enabled = false,
		},
		blur = {
			enabled = true,
			size = 5,
			passes = 4,
			new_optimizations = true,
			ignore_opacity = true,
			xray = false,
			special = true,
		},
	},
	general = {
		gaps_in = 3,
		gaps_out = 8,
		border_size = 2,
		resize_on_border = true,
	},
	misc = {
		allow_session_lock_restore = true,
	},
})

hl.bind("SUPER + ALT + N", hl.dsp.exec_cmd("/home/btw/.local/bin/earth-native control"), {
	description = "Control native Earth renderer",
})
hl.bind("SUPER + ALT + SHIFT + N", hl.dsp.exec_cmd("/home/btw/.local/bin/earth-native restart"), {
	description = "Restart native Earth renderer",
})
hl.bind("SUPER + F", hl.dsp.window.fullscreen(0), { description = "fullscreen" })
hl.bind("F9", hl.dsp.exec_cmd("playerctl pause && pamixer -m"), {
	description = "pause media and mute output",
})
hl.bind("SUPER + C", hl.dsp.exec_cmd("bash ~/mhm/scripts/center.sh"), {
	description = "center window",
})
hl.bind("SUPER + SHIFT + C", hl.dsp.exec_cmd("bash ~/mhm/scripts/resize-30.sh"), {
	description = "resize window",
})

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

hl.workspace_rule({ workspace = "1", monitor = "DP-1" })
hl.workspace_rule({ workspace = "2", monitor = "DP-1" })
hl.workspace_rule({ workspace = "9", monitor = "DP-1" })
hl.workspace_rule({ workspace = "3", monitor = "DP-2" })
hl.workspace_rule({ workspace = "4", monitor = "DP-2" })

-- 2.5x faster. "liner" in the old conf is Hyprland's builtin linear bezier.
local function anim(leaf, enabled, speed, bezier, style)
	hl.animation({
		leaf = leaf,
		enabled = enabled,
		speed = speed,
		bezier = bezier,
		style = style,
	})
end
anim("windows", true, 2.5, "default", "popin 60%")
anim("windowsIn", true, 2.5, "default", "popin 60%")
anim("windowsOut", true, 2.5, "default", "popin 60%")
anim("windowsMove", true, 2.5, "default", "slide")
anim("layers", true, 2.5, "default", "popin")
anim("fade", true, 2.5, "default")
anim("fadeIn", true, 2.5, "default")
anim("fadeOut", true, 2.5, "default")
anim("fadeSwitch", true, 2.5, "default")
anim("fadeShadow", true, 2.5, "default")
anim("fadeDim", true, 2.5, "default")
anim("fadeLayers", true, 2.5, "default")
anim("workspaces", true, 2.5, "default", "slide")
anim("border", true, 2.5, "linear")
anim("borderangle", true, 2.5, "linear", "once")
anim("specialWorkspace", false, 0, "default")

-- ICC on DP-2 stays commented (same as the old conf):
-- hl.monitor({ output = "DP-2", icc = "/home/btw/.local/share/color/icc/LG-ULTRAWIDE.icm" })

return { exec_once = exec_once }
