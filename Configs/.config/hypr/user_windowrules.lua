-- Window/layer rules from windowrules.conf (Hyprland Lua does not source that file).
-- Loaded from hyprland.lua after userprefs.lua.

local function rule(spec)
	hl.window_rule(spec)
end

rule({
	name = "idle_inhibit_video",
	match = { class = "^(.*mpv.*)$" },
	idle_inhibit = "fullscreen",
})
rule({
	name = "idle_inhibit_browsers",
	match = {
		class = "^(.*LibreWolf.*)$|^(.*floorp.*)$|^(.*brave.*)$|^(.*firefox.*)$|^(.*chromium.*)$|^(.*zen.*)$|^(.*vivaldi.*)$",
	},
	idle_inhibit = "fullscreen",
})

rule({
	name = "brave_ws3_silent",
	match = { initial_class = "^(brave-origin)$" },
	workspace = "3 silent",
})

rule({
	name = "hyde_picture_in_picture",
	match = { title = "^([Pp]icture[-\\s]?[Ii]n[-\\s]?[Pp]icture)(.*)$" },
	tag = "+picture-in-picture",
	float = true,
	keep_aspect_ratio = true,
	move = "(monitor_w*0.73) (monitor_h*0.72)",
	size = "(monitor_w*0.25) (monitor_h*0.25)",
	pin = true,
})

local function opacity_class(class, active, inactive, fullscreen)
	rule({
		match = { class = class },
		opacity = string.format("%s %s %s", active, inactive, fullscreen or 1),
	})
end

opacity_class("^(firefox)$", 0.90, 0.90, 1)
opacity_class("^(zen)$", 0.90, 0.90, 1)
opacity_class("^(code-oss)$", 0.80, 0.80, 1)
opacity_class("^([Cc]ode)$", 0.80, 0.80, 1)
opacity_class("^(code-url-handler)$", 0.80, 0.80, 1)
opacity_class("^(code-insiders-url-handler)$", 0.80, 0.80, 1)
opacity_class("^(kitty)$", 0.80, 0.80, 1)
opacity_class("^(org.kde.dolphin)$", 0.80, 0.80, 1)
opacity_class("^(org.kde.ark)$", 0.80, 0.80, 1)
opacity_class("^(nwg-look)$", 0.80, 0.80, 1)
opacity_class("^(qt5ct)$", 0.80, 0.80, 1)
opacity_class("^(qt6ct)$", 0.80, 0.80, 1)
opacity_class("^(kvantummanager)$", 0.80, 0.80, 1)
opacity_class("^(org.pulseaudio.pavucontrol)$", 0.80, 0.70, 1)
opacity_class("^(blueman-manager)$", 0.80, 0.70, 1)
opacity_class("^(nm-applet)$", 0.80, 0.70, 1)
opacity_class("^(nm-connection-editor)$", 0.80, 0.70, 1)
opacity_class("^(hyprpolkitagent)$", 0.80, 0.70, 1)
opacity_class("^(org.freedesktop.impl.portal.desktop.gtk)$", 0.80, 0.70, 1)
opacity_class("^(org.freedesktop.impl.portal.desktop.hyprland)$", 0.80, 0.70, 1)
opacity_class("^([Ss]team)$", 0.70, 0.70, 1)
opacity_class("^(steamwebhelper)$", 0.70, 0.70, 1)
opacity_class("^(blender)$", 1.00, 1.00, 1)

for _, class in ipairs({
	"^(com.github.rafostar.Clapper)$",
	"^(com.github.tchx84.Flatseal)$",
	"^(hu.kramo.Cartridges)$",
	"^(com.obsproject.Studio)$",
	"^(org.gnome.Boxes)$",
	"^(vesktop)$",
	"^(discord)$",
	"^(WebCord)$",
	"^(ArmCord)$",
	"^(app.drey.Warp)$",
	"^(net.davidotek.pupgui2)$",
	"^(yad)$",
	"^(Signal)$",
	"^(io.github.alainm23.planify)$",
	"^(io.gitlab.theevilskeleton.Upscaler)$",
	"^(com.github.unrud.VideoDownloader)$",
	"^(io.gitlab.adhami3310.Impression)$",
	"^(io.missioncenter.MissionCenter)$",
	"^(io.github.flattool.Warehouse)$",
}) do
	opacity_class(class, 0.80, 0.80, 1)
end

for _, class in ipairs({
	"^(Signal)$",
	"^(com.github.rafostar.Clapper)$",
	"^(app.drey.Warp)$",
	"^(net.davidotek.pupgui2)$",
	"^(yad)$",
	"^(org.gnome.eog)$",
	"^(io.github.alainm23.planify)$",
	"^(io.gitlab.theevilskeleton.Upscaler)$",
	"^(com.github.unrud.VideoDownloader)$",
	"^(io.gitlab.adhami3310.Impression)$",
	"^(io.missioncenter.MissionCenter)$",
}) do
	rule({ match = { class = class }, float = true })
end

rule({ match = { title = "^(Friends List)$" }, float = true })
rule({ match = { title = "^(Steam Settings)$" }, float = true })
rule({
	match = { initial_title = "^(Image Editor)$", class = "^(blender)$" },
	float = true,
	size = "(monitor_w*0.5) (monitor_h*0.5)",
})
rule({
	match = { initial_title = "^(Ghidra: NO ACTIVE PROJECT)" },
	float = true,
})

-- Restore compositor blur for bars/toasts. HyDE Lua used ignore_alpha=true
-- (threshold 1) which kills blur; gaming workflow also sets blur=false on
-- these namespaces and `hyprctl reload config-only` does not clear it.
local blur_ns =
	"^(waybar|wlogout|logout_dialog|notifications|dunst|rofi|swaync-(notification-window|control-center))$"
for _, name in ipairs({
	"hyde_layer_blur",
	"btw_layer_blur",
	"hyde_workflow_gaming",
	"hyde_workflow_powersaver",
}) do
	hl.layer_rule({
		name = name,
		match = { namespace = blur_ns },
		blur = true,
		no_anim = false,
	})
end
hl.layer_rule({
	name = "hyde_layer_ignore_alpha",
	match = { namespace = blur_ns },
	ignore_alpha = 0,
})
hl.layer_rule({
	name = "btw_layer_ignore_alpha",
	match = { namespace = blur_ns },
	ignore_alpha = 0,
})
