-- hyde/meta.lua
-- A simple metadata store for Hyde.

local M = {
    values = {}
}

setmetatable(
    M,
    {
        __call = function(self, name, value)
            if type(name) ~= "string" then
                return nil
            end

            if value == nil then
                return self.values[name]
            end

            self.values[name] = value
            return self.values[name]
        end
    }
)

-- Explicit hyde.meta API
function M.get(name)
    if type(name) ~= "string" then
        return nil
    end
    return M(name)
end

function M.set(name, value)
    if type(name) ~= "string" then
        return nil
    end
    return M(name, value)
end

_G.hyde = _G.hyde or {}
_G.hyde.meta = M

return M
