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
-- monitors.conf is still hyprlang from nwg-displays. Personal overrides live
-- in userprefs.lua (ported from userprefs.conf).

local cfg = os.getenv("XDG_CONFIG_HOME") or ((os.getenv("HOME") or "") .. "/.config")
local hypr = cfg .. "/hypr"
local load_hyprlang = dofile(hypr .. "/load_hyprlang.lua")

-- Wiki lua monitor rules (0.55+). nwg-displays still writes monitors.conf
-- and monitors.lua; keep this file in sync with that layout.
dofile(hypr .. "/monitors.lua")
-- nwg-displays Apply can emit bitdepth=10. Dual 10-bit / XB30 on this NVIDIA
-- card blanks one or both heads, so re-pin 8-bit sRGB after that load.
hl.monitor({
	output = "DP-1",
	mode = "2560x1080@99.94",
	position = "0x0",
	scale = 1,
	transform = 1,
	bitdepth = 8,
	cm = "srgb",
	disabled = false,
})
hl.monitor({
	output = "DP-2",
	mode = "3440x1440@240.09",
	position = "1080x757",
	scale = 1,
	bitdepth = 8,
	cm = "srgb",
	disabled = false,
})
local userprefs = dofile(hypr .. "/userprefs.lua")
dofile(hypr .. "/user_windowrules.lua")
local user_exec_once = (userprefs and userprefs.exec_once) or {}

-- Hyprland's hl.on replaces, it does not stack. Registering only machine
-- autostart here would skip HyDE's start_up.lua (waybar, dunst, hypridle).
local function check_exec(cmd)
	if type(cmd) == "string" and cmd ~= "" then
		hl.exec_cmd(cmd)
	end
end

local function hyde_session_start()
	local hs = (hyde.config and hyde.config.start) or {}
	check_exec(hs.dbus_share_picker)
	check_exec(hs.systemd_share_picker)
	-- HyDE start_up.lua never runs xdg_portal_reset, and the lua path it
	-- names (resetxdgportal.lua) does not exist. After a compositor restart
	-- xdph dies with "Couldn't connect to a wayland compositor".
	check_exec("hyde-shell resetxdgportal.sh")
	check_exec("uwsm finalize")
	-- Skip hs.wallpaper: cleared in start_up.lua before HyDE registers it.
	check_exec(hs.bar)
	-- Skip hyprsunset: it owns hyprland-ctm-control-v1 exclusively, so
	-- hyprshaderd cannot dim. Night-light stays off on this machine.
	check_exec(hs.notifications)
	check_exec(hs.auth_dialogue)
	if hyde.config and hyde.config.ui then
		check_exec("hyprctl setcursor " .. hyde.config.ui.cursor_theme .. " " .. hyde.config.ui.cursor_size)
	end
	check_exec(hs.text_clipboard)
	check_exec(hs.image_clipboard)
	check_exec(hs.clipboard_persist)
	check_exec(hs.idle_daemon)
	check_exec(hs.battery_notify)
	check_exec(hs.applet_network_manager)
	check_exec(hs.applet_removable_media)
	check_exec(hs.applet_bluetooth)
	check_exec(hs.hyde_config)
end

local function stop_hyprsunset()
	-- systemd Restart=always will bring this back after a compositor restart
	-- unless we stop the unit. It exclusive-owns CTM and kills hyprshaderd's dim.
	check_exec(
		"sh -c 'systemctl --user stop hyde-Hyprland-blue-light-filter.service 2>/dev/null; pkill -x hyprsunset || true'"
	)
end

local function start_hyprshaderd(force)
	local kill_old = ""
	if force then
		kill_old = "pkill -x hyprshaderd || true; sleep 0.2; "
	end
	check_exec(
		"sh -c 'systemctl --user stop hyde-Hyprland-blue-light-filter.service 2>/dev/null; pkill -x hyprsunset || true; "
			.. kill_old
			.. "pgrep -x hyprshaderd >/dev/null || exec /home/btw/mhm/hyprshaderd/hyprshaderd'"
	)
end

local function start_user_once(cmd, on_reload)
	if type(cmd) ~= "string" or cmd == "" then
		return
	end
	if on_reload and cmd:find("startup-layout", 1, true) then
		return
	end
	if cmd:find("hyprshaderd", 1, true) then
		start_hyprshaderd()
		return
	end
	if cmd:find("easyeffects", 1, true) then
		check_exec("sh -c 'pgrep -f easyeffects >/dev/null || exec easyeffects --service-mode --hide-window'")
		return
	end
	check_exec(cmd)
end

local rt = os.getenv("XDG_RUNTIME_DIR") or "/run/user/1000"
local sig = os.getenv("HYPRLAND_INSTANCE_SIGNATURE") or "none"
local stamp = rt .. "/hypr/" .. sig .. "/btw-session-started"

local function session_autostart()
	local seen = io.open(stamp, "r")
	if seen then
		seen:close()
		return
	end
	local out = io.open(stamp, "w")
	if out then
		out:write("1\n")
		out:close()
	end
	hyde_session_start()
	for _, cmd in ipairs(user_exec_once) do
		if cmd:find("hyprshaderd", 1, true) then
			start_hyprshaderd(true)
		else
			start_user_once(cmd, false)
		end
	end
end

-- hyprland.start often does not fire for Lua configs loaded after the compositor
-- is already up. Stamp so this runs once per instance; timer is the fallback.
hl.on("hyprland.start", session_autostart)
hl.timer(session_autostart, { timeout = 2000, type = "oneshot" })

-- Reloads: keep daemons up, never re-run startup-layout.
for _, cmd in ipairs(user_exec_once) do
	start_user_once(cmd, true)
end
do
	local hs = (hyde.config and hyde.config.start) or {}
	if hs.idle_daemon then
		check_exec("sh -c 'pgrep -x hypridle >/dev/null || " .. hs.idle_daemon .. "'")
	end
	if hs.notifications then
		check_exec("sh -c 'pgrep -x dunst >/dev/null || " .. hs.notifications .. "'")
	end
	if hs.bar then
		check_exec("sh -c 'pgrep -x waybar >/dev/null || " .. hs.bar .. "'")
	end
end

-- Direct kitty binds: HyDE Super+T uses hyde-shell app -T.
hl.bind("SUPER + T", hl.dsp.exec_cmd("kitty"), { description = "[Launcher|Apps] terminal emulator" })
hl.bind("SUPER + RETURN", hl.dsp.exec_cmd("kitty"), { description = "[Launcher|Apps] terminal emulator" })

-- Conf: Alt_R + Control_R = hyde-shell waybar --hide. Lua drops ALT_R and
-- CONTROL_R as modifiers (they register as keys), so that combo cannot be
-- expressed. Super+Shift+B is the Lua replacement.
hl.bind(
	"SUPER + SHIFT + B",
	hl.dsp.exec_cmd("hyde-shell waybar --hide"),
	{ description = "[Window Management] toggle waybar and reload config" }
)

-- HyDE sets a pink overlay when lua_state.colors is invisible to Hyprland's
-- package.searchpath. Apply the palette from the mirrored file and clear it.
do
	local colors_file = (os.getenv("XDG_CONFIG_HOME") or (os.getenv("HOME") .. "/.config"))
		.. "/hypr/lua_state/colors.lua"
	local ok, color = pcall(dofile, colors_file)
	if ok and type(color) == "table" and color._pry4_rgba then
		hl.config({
			general = {
				col = {
					active_border = { colors = { color._pry4_rgba, color._4xa1_rgba }, angle = 45 },
					inactive_border = { colors = { color._pry1_rgba, color._pry2_rgba }, angle = 45 },
				},
			},
		})
	end
	hl.exec_cmd("hyprctl seterror disable")
end
