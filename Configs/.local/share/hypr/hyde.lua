--!      ░▒▒▒░░░▓▓           ___________
--!    ░░▒▒▒░░░░░▓▓        //___________/
--!   ░░▒▒▒░░░░░▓▓     _   _ _    _ _____
--!   ░░▒▒░░░░░▓▓▓▓▓▓ | | | | |  | |  __/
--!    ░▒▒░░░░▓▓   ▓▓ | |_| | |_/ /| |___
--!     ░▒▒░░▓▓   ▓▓   \__  |____/ |____/
--!       ░▒▓▓   ▓▓  //____/

-- // ██████╗░░█████╗░  ███╗░░██╗░█████╗░████████╗  ███████╗██████╗░██╗████████╗
-- // ██╔══██╗██╔══██╗  ████╗░██║██╔══██╗╚══██╔══╝  ██╔════╝██╔══██╗██║╚══██╔══╝
-- // ██║░░██║██║░░██║  ██╔██╗██║██║░░██║░░░██║░░░  █████╗░░██║░░██║██║░░░██║░░░
-- // ██║░░██║██║░░██║  ██║╚████║██║░░██║░░░██║░░░  ██╔══╝░░██║░░██║██║░░░██║░░░
-- // ██████╔╝╚█████╔╝  ██║░╚███║╚█████╔╝░░░██║░░░  ███████╗██████╔╝██║░░░██║░░░
-- // ╚═════╝░░╚════╝░  ╚═╝░░╚══╝░╚════╝░░░░╚═╝░░░  ╚══════╝╚═════╝░╚═╝░░░╚═╝░░░

hyde = hyde or {}
hyde.path = require("lua.hyde.path")

local pkg_paths = {
	hyde.path.state .. "/?.lua", -- Lua state
	hyde.path.lib .. "/?.lua", -- lib scripts
	hyde.path.lib .. "/luautils/?.lua", -- lib scripts
	hyde.path.share .. "/../hypr/lua/?.lua", -- Existing dir
	hyde.path.state .. "/lua_env/share/lua/5.5/?.lua", -- virtual env for lua
	hyde.path.state .. "/lua_env/share/lua/5.5/?/init.lua", -- virtual env for lua
	hyde.path.config .. "/hypr/?.lua", -- expose main users config
}

package.path = package.path .. ";" .. table.concat(pkg_paths, ";") .. ";"
package.cpath = package.cpath .. ";" .. hyde.path.state .. "/lua_env/lib/lua/5.5/?.so" -- virtual env shared objects

-- Let's call it early so we can use it in other files
require("hyde.utils")
require("hyde.env")
require("hyde.meta")
require("hyde.ui")
require("hyde.start")
require("hyde.define")
require("hyde.binds")
require("hyde.dispatcher")
require("hyde.animations")
require("hyde.config")
require("hyde.handlers")
-- require("hyde.hyprctl")

-- * Variables
require("variables")
-- * Default values
require("defaults")
--* Window rules
require("window_rules")
--* Layer rules
require("layer_rules")
-- * Environment variable Setup
require("env")
-- * Binds
require("key_binds")
-- * Event handlers for more DE like experience
require("events")
--* Dynamic Stuff example theming and variable handlings
require("dynamic")
--* HyDE's startup overridable too!
require("start_up")
-- --* user now can have this file
check_require("hyprland")
-- --* workflows configuration overrides everything
check_require("lua_state.workflows")
