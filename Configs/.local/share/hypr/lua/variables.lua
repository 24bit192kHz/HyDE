local systemd_env= {
    "WAYLAND_DISPLAY",
    "XDG_CURRENT_DESKTOP",
    "XDG_SESSION_TYPE",
    "XDG_SESSION_DESKTOP",
    "XDG_CONFIG_HOME",
    "XDG_DATA_HOME",
    "XDG_CACHE_HOME",
    "XDG_STATE_HOME",
    "QT_QPA_PLATFORMTHEME"
}
local systemd_env_str = table.concat(systemd_env, " ")

local unt = "hyde-" .. (os.getenv("XDG_SESSION_DESKTOP") or "") -- Holder for the unit name
local svc = "service" -- Holder for the service command
local scp = "scope" -- Holder for the scope command

-- hyde env
hyde.env("XDG_CURRENT_DESKTOP", "Hyprland")
hyde.env("XDG_SESSION_TYPE", "wayland")
hyde.env("XDG_SESSION_DESKTOP", "Hyprland")
hyde.env("QT_AUTO_SCREEN_SCALE_FACTOR", "1")
hyde.env("QT_QPA_PLATFORM", "wayland;xcb")
hyde.env("QT_WAYLAND_DISABLE_WINDOWDECORATION", "1")
hyde.env("QT_QPA_PLATFORMTHEME", "qt6ct")
hyde.env("MOZ_ENABLE_WAYLAND", "1")
hyde.env("GDK_SCALE", "1")
hyde.env("ELECTRON_OZONE_PLATFORM_HINT", "auto")
hyde.env("XDG_CONFIG_HOME", os.getenv("XDG_CONFIG_HOME") or ((os.getenv("HOME") or "") .. "/.config"))
hyde.env("XDG_CACHE_HOME", os.getenv("XDG_CACHE_HOME") or ((os.getenv("HOME") or "") .. "/.cache"))
hyde.env("XDG_DATA_HOME", os.getenv("XDG_DATA_HOME") or ((os.getenv("HOME") or "") .. "/.local/share"))
hyde.env("XDG_STATE_HOME", os.getenv("XDG_STATE_HOME") or ((os.getenv("HOME") or "") .. "/.local/state"))
hyde.env("PATH", os.getenv("PATH") or "")

-- Startup commands
hyde.start = hyde.start or {}

hyde.start.dbus_share_picker("dbus-update-activation-environment --systemd " .. systemd_env_str) -- for XDPH
hyde.start.systemd_share_picker("systemctl --user import-environment " .. systemd_env_str) -- for XDPH ( redundant with the first one )
hyde.start.xdg_portal_reset("hyde-shell resetxdgportal.sh") -- for XDPH
hyde.start.auth_dialogue("hyde-shell app -t " .. svc .. " -- polkitkdeauth.sh")
hyde.start.idle_daemon("hyde-shell app -u " .. unt .. "-idle.service -t "  .. svc .. " -- hypridle")
hyde.start.blue_light_filter_daemon("hyde-shell app -u " .. unt .. "-blue-light-filter.service -t " .. svc .. " -- hyprsunset")
hyde.start.text_clipboard("hyde-shell app -u " .. unt .. "-text-clipboard.service -t "  .. svc .. " wl-paste --type text --watch cliphist store")
hyde.start.image_clipboard("hyde-shell app -u " .. unt .. "-image-clipboard.service -t "  .. svc .. " wl-paste --type image --watch cliphist store")
hyde.start.clipboard_persist("hyde-shell app -u " .. unt .. "-clipboard-persist.service -t "  .. svc .. " wl-clip-persist --clipboard regular")
hyde.start.wallpaper("hyde-shell app -u " .. unt .. "-wallpaper.service -t "  .. svc .. " -- wallpaper.sh --start --global")
hyde.start.bar("hyde-shell app -u " .. unt .. "-bar.scope -t "  .. scp .. " -- waybar.py --watch") -- waybar.py injects it itself as -u $unt.service :- therefore we use scope here to avoid conflicts
hyde.start.notifications("hyde-shell app -u " .. unt .. "-notifications.service -t "  .. svc .. " -- dunst")
hyde.start.battery_notify("hyde-shell app -u " .. unt .. "-battery-notify.service -t "  .. svc .. " -- batterynotify.sh")
hyde.start.applet_network_manager("hyde-shell app -u " .. unt .. "-network-manager-applet.service -t "  .. svc .. " -- nm-applet --indicator")
hyde.start.applet_removable_media("hyde-shell app -u " .. unt .. "-removable-media-applet.service -t "  .. svc .. " -- udiskie --no-automount --smart-tray")
hyde.start.applet_bluetooth("hyde-shell app -u " .. unt .. "-bluetooth-applet.service -t "  .. svc .. " -- blueman-applet")
hyde.start.hyde_config("hyde-shell app -u " .. unt .. "-config-watcher.service -t "  .. svc .. " -- config.lua")

-- UI stuff
hyde.ui = hyde.ui or {}


-- Themes (assign to hyde.ui)
hyde.ui.hyde_theme = "HyDE"
hyde.ui.gtk_theme = "Wallbash-Gtk"
hyde.ui.icon_theme = "Tela-circle-dracula"
hyde.ui.color_scheme = "prefer-dark"
hyde.ui.button_layout = "" -- colon separated list of buttons

-- Cursor
hyde.ui.cursor_theme = "Bibata-Modern-Ice"
hyde.ui.cursor_size = 24

-- Fonts
hyde.ui.font = "Cantarell"
hyde.ui.font_size = 10
hyde.ui.document_font = "Cantarell"
hyde.ui.document_font_size = 10
hyde.ui.monospace_font = "CaskaydiaCove Nerd Font Mono"
hyde.ui.monospace_font_size = 9
hyde.ui.notification_font = "Mononoki Nerd Font Mono"
hyde.ui.bar_font = "JetBrainsMono Nerd Font"
hyde.ui.menu_font = "JetBrainsMono Nerd Font"
hyde.ui.font_antialiasing = "rgba"
hyde.ui.font_hinting = ""

-- Extra Themes
hyde.ui.code_theme = ""
hyde.ui.sddm_theme = ""


-- Default values
hyde.define = hyde.define or {}
hyde.define.mod = "SUPER"
hyde.define.quickapps = ""
hyde.define.browser = "hyde-shell open --fall firefox web-browser"
hyde.define.editor = "hyde-shell open --fall code-oss code-editor"
hyde.define.explorer = "hyde-shell open --fall dolphin file-manager"
hyde.define.terminal = "hyde-shell app -T"
hyde.define.lockscreen = "hyde-shell lock-session"
