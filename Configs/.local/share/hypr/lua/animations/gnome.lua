local animation = {
    name = "GNOME",
    icon = "",
    description = "GNOME-like window animation profile for Hyprland"
}

if not hl then
    return animation
end

hl.curve("gnomeOpen", {type = "spring", mass = 1, stiffness = 100, dampening = 14})
hl.curve("gnomeClose", {type = "spring", mass = 1, stiffness = 90, dampening = 16})
hl.curve("gnomeFade", {type = "bezier", points = {{0.25, 0.1}, {0.25, 1.0}}})

hl.animation({leaf = "windows", enabled = true, speed = 7, spring = "gnomeOpen", style = "popin 80%"})
hl.animation({leaf = "windowsIn", enabled = true, speed = 7, spring = "gnomeOpen", style = "popin 80%"})
hl.animation({leaf = "windowsOut", enabled = true, speed = 6, spring = "gnomeClose", style = "popin 80%"})
hl.animation({leaf = "windowsMove", enabled = true, speed = 5, bezier = "gnomeFade", style = "slide"})
hl.animation({leaf = "border", enabled = true, speed = 1, bezier = "default"})
hl.animation({leaf = "borderangle", enabled = true, speed = 30, bezier = "default", style = "once"})
hl.animation({leaf = "fade", enabled = true, speed = 9, bezier = "default"})
hl.animation({leaf = "workspaces", enabled = true, speed = 6, bezier = "gnomeFade", style = "slidefade 20%"})
hl.animation({leaf = "workspacesIn", enabled = true, speed = 6, bezier = "gnomeFade", style = "slidefade 20%"})
hl.animation({leaf = "workspacesOut", enabled = true, speed = 6, bezier = "gnomeFade", style = "slidefade 20%"})
hl.animation({leaf = "specialWorkspace", enabled = true, speed = 6, bezier = "gnomeFade", style = "slidefade 20%"})
hl.animation({leaf = "specialWorkspaceIn", enabled = true, speed = 6, bezier = "gnomeFade", style = "slidefade 20%"})
hl.animation({leaf = "specialWorkspaceOut", enabled = true, speed = 6, bezier = "gnomeFade", style = "slidefade 20%"})
hl.animation({leaf = "zoomFactor", enabled = true, speed = 7, bezier = "default"})
hl.animation({leaf = "monitorAdded", enabled = true, speed = 7, bezier = "default"})

return animation
