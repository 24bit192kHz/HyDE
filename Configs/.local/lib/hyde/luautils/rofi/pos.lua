local hyprctl = require("luautils.hypr.hyprctl")

local M = {}

function M.get_rofi_pos()
    local cursor = hyprctl.cursorpos()
    local monitors = hyprctl.monitors()

    if not cursor or not monitors then
        return {x = 0, y = 0, str = ""}
    end

    local function logical(mon)
        local w, h = mon.width, mon.height
        if (mon.transform or 0) % 2 ~= 0 then
            w, h = h, w
        end
        return w, h
    end

    local mon = hyprctl.get_active_monitor()
    for _, candidate in ipairs(monitors) do
        local w, h = logical(candidate)
        local mx, my = candidate.x or 0, candidate.y or 0
        if cursor.x >= mx and cursor.x < mx + w and cursor.y >= my and cursor.y < my + h then
            mon = candidate
            break
        end
    end

    if not mon then
        return {x = 0, y = 0, str = ""}
    end

    local scale = mon.scale or 1
    local inv_scale = 1 / scale
    local w, h = logical(mon)

    local rel_x = cursor.x - (mon.x or 0)
    local rel_y = cursor.y - (mon.y or 0)
    if rel_x < 0 then rel_x = 0 end
    if rel_y < 0 then rel_y = 0 end
    if rel_x > w then rel_x = w end
    if rel_y > h then rel_y = h end

    local cfg_m = (hyde and hyde.config and hyde.config.monitor and hyde.config.monitor.edge_margin) or {0}
    local u, r, d, l = 0, 0, 0, 0
    local n = #cfg_m
    if n == 1 then
        u, r, d, l = cfg_m[1], cfg_m[1], cfg_m[1], cfg_m[1]
    elseif n == 2 then
        u, d = cfg_m[1], cfg_m[1]
        r, l = cfg_m[2], cfg_m[2]
    elseif n >= 4 then
        u, r, d, l = cfg_m[1], cfg_m[2], cfg_m[3], cfg_m[4]
    end

    local res = mon.reserved or {0, 0, 0, 0}
    local safe_top = ((res[2] or res.top or 0) + (u * h)) * inv_scale
    local safe_bot = ((res[4] or res.bottom or 0) + (d * h)) * inv_scale
    local safe_lft = ((res[1] or res.left or 0) + (l * w)) * inv_scale
    local safe_rgt = ((res[3] or res.right or 0) + (r * w)) * inv_scale

    local l_w, l_h = w * inv_scale, h * inv_scale

    local x_dir = (rel_x >= (l_w / 2)) and "east" or "west"
    local y_dir = (rel_y >= (l_h / 2)) and "south" or "north"

    local x_off = (x_dir == "east") and -(l_w - rel_x - safe_rgt) or (rel_x - safe_lft)
    local y_off = (y_dir == "south") and -(l_h - rel_y - safe_bot) or (rel_y - safe_top)

    local pos_str =
        string.format(
        'configuration{monitor:"%s";}window{location:%s %s;anchor:%s %s;x-offset:%dpx;y-offset:%dpx;}',
        mon.name or "",
        x_dir,
        y_dir,
        x_dir,
        y_dir,
        math.floor(x_off),
        math.floor(y_off)
    )

    return {x = x_off, y = y_off, str = pos_str}
end

return M
