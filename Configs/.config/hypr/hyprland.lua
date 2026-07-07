local MOD = hyde.config.modifiers.main

hl.on("hyprland.start", function()
    hl.exec_cmd("quickshell -p ~/test/earth/")
    hl.exec_cmd("openrgb -p pf1")
    hl.exec_cmd("bash ~/mhm/scripts/startup-layout")
    hl.exec_cmd("xrdb -merge ~/.Xresources")
    hl.exec_cmd("systemctl --user start pcpanel.service")
    hl.exec_cmd("/home/btw/.local/bin/hyprlightd")
end)

hl.env("WALLPAPER_BACKEND", "hyprpaper")
hl.env("GTK_USE_PORTAL", "1")
hl.env("GDK_DEBUG", "portals")
hl.env("HYPRLIGHTD_BRIGHTNESS_NORMAL", "0.55")

hl.config({
    input = {
        kb_layout = "us,ara",
        kb_options = "grp:caps_toggle",
        repeat_delay = 200,
        repeat_rate = 30,
        touchpad = {
            natural_scroll = false
        }
    },
    render = {
        cm_auto_hdr = 0
    },
    decoration = {
        active_opacity = 1.0,
        inactive_opacity = 1.0,
        fullscreen_opacity = 1.0,
        blur = {
            enabled = true,
            size = 8,
            passes = 2
        }
    },
    misc = {
        allow_session_lock_restore = true
    }
})

hl.bind(MOD .. " + F", hl.dsp.window.fullscreen(0), { description = "fullscreen" })
hl.bind("F9", hl.dsp.exec_cmd("playerctl pause && pamixer -m"))
hl.bind(MOD .. " + C", hl.dsp.exec_cmd("bash ~/mhm/scripts/center.sh"), { description = "center window" })
hl.bind(MOD .. " + SHIFT + C", hl.dsp.exec_cmd("bash ~/mhm/scripts/resize-30.sh"), { description = "resize window" })

hl.window_rule({
    match = { class = "^(kitty)$" },
    no_blur = true
})

-- Workspace assignments
-- hl.workspace("1", { monitor = "DP-1" })
-- hl.workspace("2", { monitor = "DP-1" })
-- hl.workspace("9", { monitor = "DP-1" })
-- hl.workspace("3", { monitor = "DP-2" })
-- hl.workspace("4", { monitor = "DP-2" })

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
    match = { class = "^(com.getpcpanel.MainFX)$" },
    workspace = "9 silent"
})

hl.window_rule({
    name = "furmark_at_cursor",
    match = { initial_title = "^(GeeXLab Player)(.*)$" },
    float = true,
    move = "(cursor_x-(window_w*0.5)) (cursor_y-(window_h*0.5))"
})

hl.bind(MOD .. " + L", hl.dsp.exec_cmd("~/mhm/scripts/lock.sh"), { locked = true })

hl.unbind(MOD .. " + F11")
hl.unbind(MOD .. " + F12")
hl.bind(MOD .. " + F11", hl.dsp.exec_cmd("/home/btw/.local/bin/hyprlightctl dimmer"), { description = "decrease brightness", repeating = true })
hl.bind(MOD .. " + F12", hl.dsp.exec_cmd("/home/btw/.local/bin/hyprlightctl brighter"), { description = "increase brightness", repeating = true })

hl.config({
    workspace = {
        "1,monitor:DP-1",
        "2,monitor:DP-1",
        "9,monitor:DP-1",
        "3,monitor:DP-2",
        "4,monitor:DP-2"
    }
})
