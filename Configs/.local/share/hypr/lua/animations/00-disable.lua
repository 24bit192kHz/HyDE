local animation = {
    name = "Disabled (No Animations)",
    icon = "󰇄",
    description = "Disable all animations"
}

if not hl then
    return animation
end

hl.animation({leaf = "global", enabled = false})
