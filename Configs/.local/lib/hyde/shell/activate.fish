#!/usr/bin/env fish

set -l HYDE_HYPRLAND_LUA 0
set -x HYPRLAND_CONFIG "$XDG_DATA_HOME/hypr/hyprland.conf"
if test -z "$XDG_DATA_HOME"
    set -x HYPRLAND_CONFIG "$HOME/.local/share/hypr/hyprland.conf"
end

for HYDE_LUA in "$HOME/.local/share/hypr/hyde.lua" /usr/local/share/hypr/hyde.lua /usr/share/hypr/hyde.lua
    if test -f "$HYDE_LUA"
        set HYDE_HYPRLAND_LUA 1
        set -x HYPRLAND_CONFIG "$HYDE_LUA"
        break
    end
end

if test "$HYDE_HYPRLAND_LUA" != 1
    printf 'Missing hyde.lua\n' >&2
    return 1
end

# command -sq is fish-native builtin — fastest possible check
command -sq lua; or begin
    printf 'Missing lua\n' >&2
    return 1
end

command -sq luarocks; or begin
    printf 'Missing luarocks\n' >&2
    return 1
end

if command -sq readelf
    # command -s is fish-native builtin for path lookup
    set -l hyprbin (command -s hyprland 2>/dev/null)
    if test -n "$hyprbin"
        set -l readelf_out (readelf -d "$hyprbin" 2>/dev/null)
        if not string match -q '*NEEDED*lua*' -- $readelf_out
            printf 'Hyprland is not linked against Lua\n' >&2
            return 1
        end
    end
end
