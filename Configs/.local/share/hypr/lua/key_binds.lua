-- Keybinds for this machine: 1:1 with live ~/.config/hypr/keybindings.conf
-- plus the personal binds from userprefs.conf. Lua-only extras (altab,
-- calculator, numpad 11-20, Super+Alt+F4, wallpaper ←/→, Super+Ctrl+S OCR)
-- are omitted on purpose.
hyde.binds.dedup = true

local _apps = hyde.config.app
local MOD = hyde.config.modifiers.main
local _F

local function rofi(cmd)
	return hl.dsp.exec_cmd("pkill -x rofi || " .. cmd)
end

local move_window = function(dir, pix)
	local lut = { l = { -1, 0 }, r = { 1, 0 }, u = { 0, -1 }, d = { 0, 1 } }
	lut.left, lut.right, lut.up, lut.down = lut.l, lut.r, lut.u, lut.d
	local m = lut[dir]
	return function()
		local args = hl.get_active_window().floating and { x = m[1] * pix, y = m[2] * pix, relative = true }
			or { direction = dir }
		hl.dispatch(hl.dsp.window.move(args))
	end
end

local _wm = "Window Management"
_F = { description = "[Window Management] close focused window" }
hl.bind(MOD .. " + Q", hl.dsp.window.close(), _F)
_F = { description = "[Window Management] close focused window" }
hl.bind("ALT + F4", hl.dsp.window.close(), _F)
_F = { description = "[Window Management] kill hyprland session" }
hl.bind(MOD .. " + Delete", hl.dsp.exec_cmd("hyde-shell logout"), _F)
_F = { description = "[Window Management] Toggle floating" }
hl.bind(MOD .. " + W", hl.dsp.window.float({ action = "toggle" }), _F)
_F = { description = "[Window Management] toggle group" }
hl.bind(MOD .. " + G", hl.dsp.group.toggle(), _F)
_F = { description = "[Window Management] toggle fullscreen" }
hl.bind("SHIFT + F11", hl.dsp.window.fullscreen(), _F)
_F = { description = "[Window Management] lock screen" }
hl.bind(MOD .. " + L", hl.dsp.exec_cmd("~/mhm/scripts/lock.sh"), _F)
_F = { description = "[Window Management] toggle pin on focused window" }
hl.bind(MOD .. " + SHIFT + F", hl.dsp.exec_cmd(hyde.sh.window.pin()), _F)
_F = { description = "[Window Management] logout menu" }
hl.bind("CTRL + ALT + DELETE", hl.dsp.exec_cmd("hyde-shell logoutlaunch"), _F)

_F = { description = "[Window Management|Group Navigation] change active group backwards" }
hl.bind(MOD .. " + CTRL + H", hl.dsp.group.prev(), _F)
_F = { description = "[Window Management|Group Navigation] change active group forwards" }
hl.bind(MOD .. " + CTRL + L", hl.dsp.group.next(), _F)

_F = { description = "[Window Management|Change focus] focus left" }
hl.bind(MOD .. " + Left", hl.dsp.focus({ direction = "left" }), _F)
_F = { description = "[Window Management|Change focus] focus right" }
hl.bind(MOD .. " + Right", hl.dsp.focus({ direction = "right" }), _F)
_F = { description = "[Window Management|Change focus] focus up" }
hl.bind(MOD .. " + Up", hl.dsp.focus({ direction = "up" }), _F)
_F = { description = "[Window Management|Change focus] focus down" }
hl.bind(MOD .. " + Down", hl.dsp.focus({ direction = "down" }), _F)
_F = { description = "[Window Management|Change focus] Cycle focus" }
hl.bind("ALT + TAB", hl.dsp.exec_cmd('hyprctl --batch "dispatch cyclenext ; dispatch alterzorder top"'), _F)

_F = { description = "[Window Management|Resize Active Window] resize window right", repeating = true }
hl.bind(MOD .. " + SHIFT + RIGHT", hl.dsp.window.resize({ x = 30, y = 0, relative = true }), _F)
_F = { description = "[Window Management|Resize Active Window] resize window left", repeating = true }
hl.bind(MOD .. " + SHIFT + LEFT", hl.dsp.window.resize({ x = -30, y = 0, relative = true }), _F)
_F = { description = "[Window Management|Resize Active Window] resize window up", repeating = true }
hl.bind(MOD .. " + SHIFT + UP", hl.dsp.window.resize({ x = 0, y = -30, relative = true }), _F)
_F = { description = "[Window Management|Resize Active Window] resize window down", repeating = true }
hl.bind(MOD .. " + SHIFT + DOWN", hl.dsp.window.resize({ x = 0, y = 30, relative = true }), _F)

_F = { description = "[Window Management|Move active window across workspace] Move active window to the left", repeating = true }
hl.bind(MOD .. " + SHIFT + CONTROL + LEFT", move_window("l", 30), _F)
_F = { description = "[Window Management|Move active window across workspace] Move active window to the right", repeating = true }
hl.bind(MOD .. " + SHIFT + CONTROL + RIGHT", move_window("r", 30), _F)
_F = { description = "[Window Management|Move active window across workspace] Move active window up", repeating = true }
hl.bind(MOD .. " + SHIFT + CONTROL + UP", move_window("u", 30), _F)
_F = { description = "[Window Management|Move active window across workspace] Move active window down", repeating = true }
hl.bind(MOD .. " + SHIFT + CONTROL + DOWN", move_window("d", 30), _F)

_F = { description = "[Window Management|Move & Resize with mouse] hold to move window", mouse = true }
hl.bind(MOD .. " + mouse:272", hl.dsp.window.drag(), _F)
_F = { description = "[Window Management|Move & Resize with mouse] hold to resize window", mouse = true }
hl.bind(MOD .. " + mouse:273", hl.dsp.window.resize(), _F)
_F = { description = "[Window Management|Move & Resize with mouse] hold to move window", mouse = true }
hl.bind(MOD .. " + Z", hl.dsp.window.drag(), _F)
_F = { description = "[Window Management|Move & Resize with mouse] hold to resize window", mouse = true }
hl.bind(MOD .. " + X", hl.dsp.window.resize(), _F)

_F = { description = "[Window Management] toggle split" }
hl.bind(MOD .. " + J", hl.dsp.layout("togglesplit"), _F)

_F = { description = "[Launcher|Apps] terminal emulator" }
hl.bind(MOD .. " + T", hl.dsp.exec_cmd(_apps.terminal), _F)
_F = { description = "[Launcher|Apps] dropdown terminal" }
hl.bind(MOD .. " + ALT + T", hl.dsp.exec_cmd("hyde-shell pypr toggle console"), _F)
_F = { description = "[Launcher|Apps] file explorer" }
hl.bind(MOD .. " + E", hl.dsp.exec_cmd(_apps.explorer), _F)
_F = { description = "[Launcher|Apps] web browser" }
hl.bind(MOD .. " + B", hl.dsp.exec_cmd(_apps.browser), _F)
_F = { description = "[Launcher|Apps] system monitor" }
hl.bind("CTRL + SHIFT + ESCAPE", hl.dsp.exec_cmd("hyde-shell system.monitor"), _F)

_F = { description = "[Launcher|Rofi menus] application finder" }
hl.bind(MOD .. " + A", rofi("hyde-shell rofilaunch d"), _F)
_F = { description = "[Launcher|Rofi menus] window switcher" }
hl.bind(MOD .. " + TAB", rofi("hyde-shell rofilaunch w"), _F)
_F = { description = "[Launcher|Rofi menus] file finder" }
hl.bind(MOD .. " + SHIFT + E", rofi("hyde-shell rofilaunch f"), _F)
_F = { description = "[Launcher|Rofi menus] keybindings hint" }
hl.bind(MOD .. " + slash", rofi("hyde-shell keybinds_hint c"), _F)
_F = { description = "[Launcher|Rofi menus] emoji picker" }
hl.bind(MOD .. " + comma", rofi("hyde-shell emoji-picker"), _F)
_F = { description = "[Launcher|Rofi menus] glyph picker" }
hl.bind(MOD .. " + period", rofi("hyde-shell glyph-picker"), _F)
_F = { description = "[Launcher|Rofi menus] clipboard" }
hl.bind(MOD .. " + V", rofi("hyde-shell cliphist -c"), _F)
_F = { description = "[Launcher|Rofi menus] clipboard manager" }
hl.bind(MOD .. " + SHIFT + V", rofi("hyde-shell cliphist"), _F)
_F = { description = "[Launcher|Rofi menus] select rofi launcher" }
hl.bind(MOD .. " + SHIFT + A", rofi("hyde-shell rofiselect"), _F)

_F = { description = "[Hardware Controls|Audio] toggle mute output", locked = true }
hl.bind("F10", hl.dsp.exec_cmd("hyde-shell volumecontrol -o m"), _F)
_F = { description = "[Hardware Controls|Audio] toggle mute output", locked = true }
hl.bind("XF86AudioMute", hl.dsp.exec_cmd("hyde-shell volumecontrol -o m"), _F)
_F = { description = "[Hardware Controls|Audio] decrease volume", locked = true, repeating = true }
hl.bind("F11", hl.dsp.exec_cmd("hyde-shell volumecontrol -o d"), _F)
_F = { description = "[Hardware Controls|Audio] increase volume", locked = true, repeating = true }
hl.bind("F12", hl.dsp.exec_cmd("hyde-shell volumecontrol -o i"), _F)
_F = { description = "[Hardware Controls|Audio] un/mute microphone", locked = true }
hl.bind("XF86AudioMicMute", hl.dsp.exec_cmd("hyde-shell volumecontrol -i m"), _F)
_F = { description = "[Hardware Controls|Audio] decrease volume", locked = true, repeating = true }
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("hyde-shell volumecontrol -o d"), _F)
_F = { description = "[Hardware Controls|Audio] increase volume", locked = true, repeating = true }
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("hyde-shell volumecontrol -o i"), _F)

_F = { description = "[Hardware Controls|Media] play media", locked = true }
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"), _F)
_F = { description = "[Hardware Controls|Media] pause media", locked = true }
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), _F)
_F = { description = "[Hardware Controls|Media] next media", locked = true }
hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"), _F)
_F = { description = "[Hardware Controls|Media] previous media", locked = true }
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"), _F)
_F = { description = "[Hardware Controls|Media] identify playing song" }
hl.bind(MOD .. " + F1", hl.dsp.exec_cmd("/home/btw/mhm/scripts/songid.sh"), _F)
_F = { description = "[Hardware Controls|Media] toggle mute/unmute for active-window" }
hl.bind(MOD .. " + CONTROL + M", hl.dsp.exec_cmd("hyde-shell window.mute"), _F)

_F = { description = "[Hardware Controls|Brightness] increase brightness", locked = true, repeating = true }
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("hyde-shell brightnesscontrol i"), _F)
_F = { description = "[Hardware Controls|Brightness] decrease brightness", locked = true, repeating = true }
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("hyde-shell brightnesscontrol d"), _F)
_F = { description = "[Hardware Controls|Brightness] decrease brightness via hyprshaderd", repeating = true }
hl.bind(MOD .. " + F11", hl.dsp.exec_cmd("/home/btw/mhm/hyprshaderd/hyprshaderd dimmer"), _F)
_F = { description = "[Hardware Controls|Brightness] increase brightness via hyprshaderd", repeating = true }
hl.bind(MOD .. " + F12", hl.dsp.exec_cmd("/home/btw/mhm/hyprshaderd/hyprshaderd brighter"), _F)

_F = { description = "[Utilities] toggle keyboard layout", locked = true }
hl.bind(MOD .. " + K", hl.dsp.exec_cmd("hyde-shell keyboardswitch"), _F)
_F = { description = "[Utilities] game mode" }
hl.bind(MOD .. " + ALT + G", hl.dsp.exec_cmd("hyde-shell gamemode"), _F)
_F = { description = "[Utilities] open game launcher" }
hl.bind(MOD .. " + SHIFT + G", hl.dsp.exec_cmd("hyde-shell gamelauncher"), _F)

_F = { description = "[Utilities|Screen Capture] capture text with OCR" }
hl.bind(MOD .. " + O", hl.dsp.exec_cmd("/home/btw/mhm/scripts/ocr.sh"), _F)
_F = { description = "[Utilities|Screen Capture] color picker" }
hl.bind(MOD .. " + SHIFT + P", hl.dsp.exec_cmd("hyprpicker -an"), _F)
_F = { description = "[Utilities|Screen Capture] snip screen" }
hl.bind(MOD .. " + P", hl.dsp.exec_cmd("hyde-shell screenshot s"), _F)
_F = { description = "[Utilities|Screen Capture] freeze and snip screen" }
hl.bind(MOD .. " + CONTROL + P", hl.dsp.exec_cmd("hyde-shell screenshot sf"), _F)
_F = { description = "[Utilities|Screen Capture] print monitor", locked = true }
hl.bind(MOD .. " + ALT + P", hl.dsp.exec_cmd("hyde-shell screenshot m"), _F)
_F = { description = "[Utilities|Screen Capture] print all monitors", locked = true }
hl.bind("Print", hl.dsp.exec_cmd("hyde-shell screenshot p"), _F)

_F = { description = "[Theming and Wallpaper] select a global wallpaper" }
hl.bind(MOD .. " + SHIFT + W", rofi("hyde-shell wallpaper -SG"), _F)
_F = { description = "[Theming and Wallpaper] next waybar layout" }
hl.bind(MOD .. " + ALT + Up", hl.dsp.exec_cmd("hyde-shell waybar --next"), _F)
_F = { description = "[Theming and Wallpaper] previous waybar layout" }
hl.bind(MOD .. " + ALT + Down", hl.dsp.exec_cmd("hyde-shell waybar --prev"), _F)
_F = { description = "[Theming and Wallpaper] wallbash mode selector" }
hl.bind(MOD .. " + SHIFT + R", rofi("hyde-shell wallbashtoggle -m"), _F)
_F = { description = "[Theming and Wallpaper] select a theme" }
hl.bind(MOD .. " + SHIFT + T", rofi("hyde-shell theme.select"), _F)
_F = { description = "[Theming and Wallpaper] select animations" }
hl.bind(MOD .. " + SHIFT + Y", rofi("hyde-shell animations --select"), _F)
_F = { description = "[Theming and Wallpaper] select hyprlock layout" }
hl.bind(MOD .. " + SHIFT + U", rofi("hyde-shell hyprlock --select"), _F)

for i = 1, 10 do
	local key = (i == 10) and 0 or i
	_F = { description = "[Workspaces|Navigation] navigate to workspace " .. i }
	hl.bind(MOD .. " + " .. key, hl.dsp.focus({ workspace = i }), _F)
end

_F = { description = "[Workspaces|Navigation|Relative workspace] change active workspace forwards" }
hl.bind(MOD .. " + CONTROL + RIGHT", hl.dsp.focus({ workspace = "r+1" }), _F)
_F = { description = "[Workspaces|Navigation|Relative workspace] change active workspace backwards" }
hl.bind(MOD .. " + CONTROL + LEFT", hl.dsp.focus({ workspace = "r-1" }), _F)
_F = { description = "[Workspaces|Navigation] navigate to the nearest empty workspace" }
hl.bind(MOD .. " + CONTROL + DOWN", hl.dsp.focus({ workspace = "empty" }), _F)

for i = 1, 10 do
	local key = (i == 10) and 0 or i
	_F = { description = "[Workspaces|Move window to workspace] move to workspace " .. i }
	hl.bind(MOD .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }), _F)
end

_F = { description = "[Workspaces] move window to next relative workspace" }
hl.bind(MOD .. " + CONTROL + ALT + RIGHT", hl.dsp.window.move({ workspace = "r+1" }), _F)
_F = { description = "[Workspaces] move window to previous relative workspace" }
hl.bind(MOD .. " + CONTROL + ALT + LEFT", hl.dsp.window.move({ workspace = "r-1" }), _F)

_F = { description = "[Workspaces|Navigation] next workspace" }
hl.bind(MOD .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }), _F)
_F = { description = "[Workspaces|Navigation] previous workspace" }
hl.bind(MOD .. " + mouse_up", hl.dsp.focus({ workspace = "e-1" }), _F)

_F = { description = "[Workspaces|Navigation|Special workspace] move to scratchpad" }
hl.bind(MOD .. " + SHIFT + S", hl.dsp.window.move({ workspace = "special" }), _F)
_F = { description = "[Workspaces|Navigation|Special workspace] move to scratchpad (silent)" }
hl.bind(MOD .. " + ALT + S", hl.dsp.window.move({ workspace = "special", follow = false }), _F)
_F = { description = "[Workspaces|Navigation|Special workspace] toggle scratchpad" }
hl.bind(MOD .. " + S", hl.dsp.workspace.toggle_special(), _F)

for i = 1, 10 do
	local key = (i == 10) and 0 or i
	_F = { description = "[Workspaces|Navigation|Move window silently] move to workspace " .. i .. " (silent)" }
	hl.bind(MOD .. " + ALT + " .. key, hl.dsp.window.move({ workspace = i, follow = false }), _F)
end

_F = { description = "[Utilities|Voice Dictation] toggle voice dictation" }
hl.bind(MOD .. " + D", hl.dsp.exec_cmd("~/sherpa-models/dictate-toggle.sh"), _F)

-- Personal binds from userprefs.conf (Super+C is center, not the editor).
_F = { description = "[Window Management] fullscreen" }
hl.bind(MOD .. " + F", hl.dsp.window.fullscreen(0), _F)
_F = { description = "[Window Management] center window" }
hl.bind(MOD .. " + C", hl.dsp.exec_cmd("bash ~/mhm/scripts/center.sh"), _F)
_F = { description = "[Window Management] resize window" }
hl.bind(MOD .. " + SHIFT + C", hl.dsp.exec_cmd("bash ~/mhm/scripts/resize-30.sh"), _F)
_F = { description = "[Hardware Controls|Audio] pause media and mute output" }
hl.bind("F9", hl.dsp.exec_cmd("playerctl pause && pamixer -m"), _F)
_F = { description = "[Utilities] Control native Earth renderer" }
hl.bind(MOD .. " + ALT + N", hl.dsp.exec_cmd("/home/btw/.local/bin/earth-native control"), _F)
_F = { description = "[Utilities] Restart native Earth renderer" }
hl.bind(MOD .. " + ALT + SHIFT + N", hl.dsp.exec_cmd("/home/btw/.local/bin/earth-native restart"), _F)
