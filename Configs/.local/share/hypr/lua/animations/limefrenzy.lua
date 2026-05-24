local animation = {
    name = "LimeFrenzy",
    icon = "",
    description = "LimeFrenzy animation profile for Hyprland"
}

if not hl then
    return animation
end

hl.curve("default", {type = "bezier", points = {{0.12, 0.92}, {0.08, 1.0}}})
hl.curve("wind", {type = "bezier", points = {{0.12, 0.92}, {0.08, 1.0}}})
hl.curve("overshot", {type = "bezier", points = {{0.18, 0.95}, {0.22, 1.03}}})
hl.curve("liner", {type = "bezier", points = {{1, 1}, {1, 1}}})

hl.animation({leaf = "layersIn", enabled = true, speed = 4, bezier = "default", style = "popin"})
hl.animation({leaf = "layersOut", enabled = true, speed = 4, bezier = "default", style = "popin"})
hl.animation({leaf = "fadeLayersIn", enabled = true, speed = 7, bezier = "default"})
hl.animation({leaf = "fadeLayersOut", enabled = true, speed = 7, bezier = "default"})
hl.animation({leaf = "workspacesIn", enabled = true, speed = 5, bezier = "overshot", style = "slidevert"})
hl.animation({leaf = "workspacesOut", enabled = true, speed = 5, bezier = "overshot", style = "slidevert"})
hl.animation({leaf = "specialWorkspace", enabled = true, speed = 5, bezier = "overshot", style = "slidevert"})
hl.animation({leaf = "windows", enabled = true, speed = 5, bezier = "wind", style = "popin 60%"})
hl.animation({leaf = "windowsIn", enabled = true, speed = 6, bezier = "overshot", style = "popin 60%"})
hl.animation({leaf = "windowsOut", enabled = true, speed = 4, bezier = "overshot", style = "popin 60%"})
hl.animation({leaf = "windowsMove", enabled = true, speed = 4, bezier = "overshot", style = "slide"})
hl.animation({leaf = "layers", enabled = true, speed = 4, bezier = "default", style = "popin"})
hl.animation({leaf = "fadeIn", enabled = true, speed = 7, bezier = "default"})
hl.animation({leaf = "fadeOut", enabled = true, speed = 7, bezier = "default"})
hl.animation({leaf = "fadeSwitch", enabled = true, speed = 7, bezier = "default"})
hl.animation({leaf = "fadeShadow", enabled = true, speed = 7, bezier = "default"})
hl.animation({leaf = "fadeDim", enabled = true, speed = 7, bezier = "default"})
hl.animation({leaf = "fadeLayers", enabled = true, speed = 7, bezier = "default"})
hl.animation({leaf = "workspaces", enabled = true, speed = 5, bezier = "overshot", style = "slidevert"})
hl.animation({leaf = "border", enabled = true, speed = 1, bezier = "liner"})
hl.animation({leaf = "borderangle", enabled = true, speed = 24, bezier = "liner", style = "loop"})
hl.animation({leaf = "specialWorkspaceIn", enabled = true, speed = 5, bezier = "overshot", style = "slidevert"})
hl.animation({leaf = "specialWorkspaceOut", enabled = true, speed = 5, bezier = "overshot", style = "slidevert"})
