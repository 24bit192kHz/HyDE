
-- hyde/define.lua
-- Centralized default values and an apply function

local define = {
	mod = "SUPER",
	quickapps = "",
	browser = "hyde-shell open --fall firefox web-browser",
	editor = "hyde-shell open --fall code-oss text-editor",
	explorer = "hyde-shell open --fall dolphin file-manager",
	terminal = "hyde-shell app -T",
	lockscreen = "hyprlock",
}

function define.apply(target)
	target = target or {}
	for k, v in pairs(define) do
		if k ~= "apply" then
			target[k] = v
		end
	end
	return target
end

hyde = hyde or {}
hyde.define = define

return define
