local animation = {
    name = "Disabled (No Animations)",
    icon = "󰇄",
    description = "Disable all animations"
}

if not hl then
    return animation
end

-- To disable all animations, we need to disable them all EXPLICITLY, there is no global toggle for this (yet)
hl.animation({leaf = "global", enabled = false})
hl.animation({leaf = "windows", enabled = false})
hl.animation({leaf = "windowsIn", enabled = false})
hl.animation({leaf = "windowsOut", enabled = false})
hl.animation({leaf = "windowsMove", enabled = false})
hl.animation({leaf = "layers", enabled = false})
hl.animation({leaf = "layersIn", enabled = false})
hl.animation({leaf = "layersOut", enabled = false})
hl.animation({leaf = "fade", enabled = false})
hl.animation({leaf = "fadeIn", enabled = false})
hl.animation({leaf = "fadeOut", enabled = false})
hl.animation({leaf = "fadeSwitch", enabled = false})
hl.animation({leaf = "fadeShadow", enabled = false})
hl.animation({leaf = "fadeDim", enabled = false})
hl.animation({leaf = "fadeLayers", enabled = false})
hl.animation({leaf = "fadeLayersIn", enabled = false})
hl.animation({leaf = "fadeLayersOut", enabled = false})
hl.animation({leaf = "fadePopups", enabled = false})
hl.animation({leaf = "fadePopupsIn", enabled = false})
hl.animation({leaf = "fadePopupsOut", enabled = false})
hl.animation({leaf = "fadeDpms", enabled = false})
hl.animation({leaf = "border", enabled = false})
hl.animation({leaf = "borderangle", enabled = false, style = "once"}) -- Historically, borderangle loop was the only animation that would still run even if global animations were disabled, so we need to set it to "once" to prevent it from running at all
hl.animation({leaf = "workspaces", enabled = false})
hl.animation({leaf = "workspacesIn", enabled = false})
hl.animation({leaf = "workspacesOut", enabled = false})
hl.animation({leaf = "specialWorkspace", enabled = false})
hl.animation({leaf = "specialWorkspaceIn", enabled = false})
hl.animation({leaf = "specialWorkspaceOut", enabled = false})
hl.animation({leaf = "zoomFactor", enabled = false})
hl.animation({leaf = "monitorAdded", enabled = false})
