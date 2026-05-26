-- # -----------------------------------------------------
-- # macOS-like animation profile for Hyprland
-- # -----------------------------------------------------

local animation = {
    name = "MacOS",
    icon = "",
    description = "macOS-like springy popin and smooth fades."
}

if not hl then
    return animation
end

hl.curve("macOpen", {type = "spring", mass = 1, stiffness = 110, dampening = 16})
hl.curve("macBounce", {type = "spring", mass = 1, stiffness = 80, dampening = 10})
hl.curve("macSmooth", {type = "bezier", points = {{0.25, 0.1}, {0.25, 1.0}}})
hl.animation({leaf = "fadeIn", enabled = true, speed = 8, bezier = "default"})
hl.animation({leaf = "fadeOut", enabled = true, speed = 8, bezier = "default"})
hl.animation({leaf = "fadeSwitch", enabled = true, speed = 8, bezier = "default"})
hl.animation({leaf = "fadeShadow", enabled = true, speed = 8, bezier = "default"})
hl.animation({leaf = "fadeDim", enabled = true, speed = 8, bezier = "default"})
hl.animation({leaf = "fadeLayers", enabled = true, speed = 8, bezier = "default"})
hl.animation({leaf = "fadeLayersIn", enabled = true, speed = 8, bezier = "default"})
hl.animation({leaf = "fadeLayersOut", enabled = true, speed = 8, bezier = "default"})
hl.animation({leaf = "fadePopups", enabled = true, speed = 8, bezier = "default"})
hl.animation({leaf = "fadePopupsIn", enabled = true, speed = 8, bezier = "default"})
hl.animation({leaf = "fadePopupsOut", enabled = true, speed = 8, bezier = "default"})
hl.animation({leaf = "fadeDpms", enabled = true, speed = 8, bezier = "default"})
hl.animation({leaf = "windows", enabled = true, speed = 8, spring = "macOpen", style = "popin 90%"})
hl.animation({leaf = "windowsIn", enabled = true, speed = 8, spring = "macOpen", style = "popin 90%"})
hl.animation({leaf = "windowsOut", enabled = true, speed = 7, spring = "macBounce", style = "popin 90%"})
hl.animation({leaf = "windowsMove", enabled = true, speed = 5, bezier = "macSmooth", style = "slide"})
hl.animation({leaf = "border", enabled = true, speed = 1, bezier = "default"})
hl.animation({leaf = "borderangle", enabled = true, speed = 30, bezier = "default", style = "once"})
hl.animation({leaf = "fade", enabled = true, speed = 8, bezier = "default"})
hl.animation({leaf = "workspaces", enabled = true, speed = 6, bezier = "macSmooth", style = "slidefade 20%"})
hl.animation({leaf = "workspacesIn", enabled = true, speed = 6, bezier = "macSmooth", style = "slidefade 20%"})
hl.animation({leaf = "workspacesOut", enabled = true, speed = 6, bezier = "macSmooth", style = "slidefade 20%"})
hl.animation({leaf = "specialWorkspace", enabled = true, speed = 6, bezier = "macSmooth", style = "slidefade 20%"})
hl.animation({leaf = "specialWorkspaceIn", enabled = true, speed = 6, bezier = "macSmooth", style = "slidefade 20%"})
hl.animation({leaf = "specialWorkspaceOut", enabled = true, speed = 6, bezier = "macSmooth", style = "slidefade 20%"})
hl.animation({leaf = "zoomFactor", enabled = true, speed = 7, bezier = "default"})
hl.animation({leaf = "monitorAdded", enabled = true, speed = 7, bezier = "default"})
