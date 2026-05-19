-- All values should be nil here. Set actual defaults in variables.lua.


local ui_state = {
    hyde_theme = nil,

    -- gtk
    gtk_theme = nil,
    icon_theme = nil,
    color_scheme = nil,
    button_layout = nil, -- colon separated list of buttons

    -- Cursor
    cursor_theme = nil,
    cursor_size = nil,

    -- Fonts
    font = nil,
    font_size = nil,
    document_font = nil,
    document_font_size = nil,
    monospace_font = nil,
    monospace_font_size = nil,
    notification_font = nil,
    bar_font = nil,
    menu_font = nil,
    font_antialiasing = nil,
    font_hinting = nil,

    -- Extra Themes
    code_theme = nil,
    sddm_theme = nil,
}


local function clean(t)
    local out = {}
    if type(t) ~= "table" then
        return out
    end

    for k, v in pairs(t) do
        if v ~= nil and not (type(v) == "string" and v == "") then
            out[k] = v
        end
    end
    return out
end

local function load(t)
    local clean_t = clean(t)
    for k, v in pairs(clean_t) do
        hyde.ui[k] = v
    end
    return hyde.ui
end

_G.hyde = _G.hyde or {}
hyde.ui = clean(ui)
hyde.ui.load = load
return hyde.ui
