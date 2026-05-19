-- hyde/utils.lua

local util = {}

-- Safely require a module only if it exists in package.path.
-- Returns the module if loaded, or nil if the module does not exist.
function util.check_require(module_name)
  if type(module_name) ~= "string" then
    return nil
  end

  local filename = package.searchpath(module_name, package.path)
  if filename then
    return require(module_name)
  end

  return nil
end

_G.hyde = _G.hyde or {}
_G.hyde.utils = util
_G.check_require = util.check_require

return util
