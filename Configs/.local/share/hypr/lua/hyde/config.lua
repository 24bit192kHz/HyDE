-- config.lua

-- Main Hyprland Lua config file
-- This is loaded before any other files
-- And Users can declare there config in ~/.config/hypr/hyprland.lua
-- TODO: Make a way to generate a stub

_G.hyde = _G.hyde or {}
hyde.config = hyde.config or {}
hyde.config.window = hyde.config.window or {}

hyde.config.window.float_size_bounds = {
    enabled = true, -- Enable or disable the float size bounds feature
    scale = 0.95, -- Scale factor for the maximum size relative to the usable monitor area (0.95 means 95% of usable area)
    force_center = true -- If true, windows that exceed bounds will be resized and centered on the monitor. If false, they will only be resized but keep their position.
}

hyde.config.window.float_follow_cursor = {
    enabled = true,
    mode = "default", -- "default" centers the window on the cursor, "quadrant" opens in the opposite quadrant
}


hyde.config.monitor = {
    -- 1% Top/Bottom, 1% Left/Right
    edge_margin = {0.01}  -- Can be a single value or a table of 1-4 values for different edges
    -- edge_margin = {0.01, 0.01} -- 1% Top/Bottom, 1% Left/Right
    -- edge_margin = {0.01, 0.01, 0.01}  -- 1% Top, 1% Left/Right, 1% Bottom
    -- edge_margin = {0.01, 0.01, 0.01, 0.01} -- 1% Top, 1% Right, 1% Bottom, 1% Left
}

hyde.config.anim = {
    speed_multiplier = 1.0
}


-- Set like this
-- hyde.config.window.float_follow_cursor.enabled = true
-- hyde.config.window.float_follow_cursor.edge_margin.left = 50
-- hyde.config.window.float_follow_cursor.edge_margin.right = 50
-- hyde.config.window.float_follow_cursor.edge_margin.up = 50
-- hyde.config.window.float_follow_cursor.edge_margin.down = 50
