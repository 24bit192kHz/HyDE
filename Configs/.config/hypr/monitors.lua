-- Official Hyprland 0.55+ monitor rules:
-- https://wiki.hypr.land/Configuring/Basics/Monitors/
-- Position uses scaled+transformed size: DP-1 2560x1080 + transform 1 is 1080 wide.
-- Dual 10-bit / XB30 on this NVIDIA card leaves one or both outputs DPMS-off.
-- nwg-displays will clobber this file: after Apply, keep bitdepth=8 / cm=srgb.

hl.monitor({
	output = "DP-1",
	mode = "2560x1080@99.94",
	position = "0x0",
	scale = 1,
	transform = 1,
	bitdepth = 8,
	cm = "srgb",
	disabled = false,
})

hl.monitor({
	output = "DP-2",
	mode = "3440x1440@240.09",
	position = "1080x757",
	scale = 1,
	bitdepth = 8,
	cm = "srgb",
	disabled = false,
})

hl.monitor({
	output = "",
	mode = "preferred",
	position = "auto",
	scale = 1,
})
