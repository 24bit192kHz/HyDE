local hs = hyde.config.start or {}

hl.on(
	"hyprland.start",
	function()
		hl.exec_cmd(hs.dbus_share_picker)
		hl.exec_cmd(hs.systemd_share_picker)
		hl.exec_cmd("uwsm finalize") -- * optional
		hl.exec_cmd(hs.wallpaper)
		hl.exec_cmd(hs.bar)
		hl.exec_cmd(hs.blue_light_filter_daemon)
		hl.exec_cmd(hs.notifications)
		hl.exec_cmd(hs.auth_dialogue)

		hl.exec_cmd(hs.text_clipboard)
		hl.exec_cmd(hs.image_clipboard)
		hl.exec_cmd(hs.clipboard_persist)
		hl.exec_cmd(hs.idle_daemon)
		hl.exec_cmd(hs.battery_notify)
		hl.exec_cmd(hs.applet_network_manager)
		hl.exec_cmd(hs.applet_removable_media)
		hl.exec_cmd(hs.applet_bluetooth)
		hl.exec_cmd(hs.hyde_config)
	end
)
