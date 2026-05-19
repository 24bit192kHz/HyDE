-- Helper functions for consistent keycombo formatting

local function trim(str)
    return str and str:gsub("^%s+", ""):gsub("%s+$", "") or ""
end

local function normalize(keycombo)
    if type(keycombo) ~= "string" then
        return ""
    end
    return trim(keycombo:gsub("%s*%+%s*", "+"))
end

hyde = hyde or {}
hyde.binds = hyde.binds or {}

hyde.binds.dedup = hyde.binds.dedup == nil and false or hyde.binds.dedup

hyde.binds.normalize = normalize

local orig_add = hl.bind

hl.bind = function(keycombo, action, ...)
    if hyde.binds.dedup then
        -- local normalized = hyde.binds.normalize(keycombo)
        hl.unbind(hyde.binds.normalize(keycombo))
    end

    return orig_add(keycombo, action, ...)
end
