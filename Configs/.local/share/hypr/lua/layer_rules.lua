

-- # // █░░ ▄▀█ █▄█ █▀▀ █▀█   █▀█ █░█ █░░ █▀▀ █▀
-- # // █▄▄ █▀█ ░█░ ██▄ █▀▄   █▀▄ █▄█ █▄▄ ██▄ ▄█

hl.layer_rule({
  name = "hyde_layer_blur",
  match = { namespace = "^(rofi|notifications|swaync-(notification-window|control-center)|waybar|logout_dialog)$" },
  blur = true,
})

hl.layer_rule({
  name = "hyde_layer_ignore_alpha",
  match = { namespace = "^(rofi|notifications|swaync-(notification-window|control-center)|logout_dialog|waybar|selection)$" },
  ignore_alpha = true,
})

hl.layer_rule({
  match = { namespace = "selection" },
  no_anim = true,
})

hl.layer_rule ({
    name = "hyde_layer_blur",
    match = { namespace = "^(rofi|notifications|swaync-(notification-window|control-center)|waybar|logout_dialog)$" },
    blur = true
})

hl.layer_rule ({
    name = "hyde_layer_ignore_alpha",
    match = { namespace = "^(rofi|notifications|swaync-(notification-window|control-center)|logout_dialog|waybar|selection)$" },
    ignore_alpha = true
})

hl.layer_rule ({
    name = "hyde_layer_no_anim",
    no_anim = true,
    match = { namespace = "selection" }
})
