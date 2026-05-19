
local start = {}

-- Command names for start actions. Each function is a getter when called without
-- an argument, and a setter when called with one.
local command_keys = {
    "dbus_share_picker",
    "systemd_share_picker",
    "xdg_portal_reset",
    "auth_dialogue",
    "idle_daemon",
    "blue_light_filter_daemon",
    "text_clipboard",
    "image_clipboard",
    "clipboard_persist",
    "wallpaper",
    "bar",
    "notifications",
    "battery_notify",
    "applet_network_manager",
    "applet_removable_media",
    "applet_bluetooth",
    "hyde_config"
}

for _, key in ipairs(command_keys) do
    start[key] = function(val)
        if val ~= nil then
            start["_" .. key] = val
        end
        return start["_" .. key]
    end
end

_G.hyde = _G.hyde or {}
_G.hyde.start = start

return start
