local utils = require("ww_ap_overlay.utils")
local ww_command_line = require("ww_command_line")
require("ww_ap_overlay.all_portals_overlay")

local M = {}

--- @class Hotkeys
--- @field next string
--- @field prev string
--- @field reset string | nil
--- @field solve string
Hotkeys = {
	next = "Page_Up",
	prev = "Page_Down",
	reset = "F12",
	solve = "F9",
	show_overlay = "N",
	hide_overlay = "M",
}

--- @class OverlayTextConfig
--- @field x number
--- @field y number
--- @field color string | nil
--- @field size number | nil
--- @field depth number | nil
--- @field shader string | nil
OverlayTextConfig = {}

--- @class DstConfig
--- @field x number
--- @field y number
--- @field w number
--- @field h number
DstConfig = {}

--- @class OverlayImageConfig
--- @field dst DstConfig
--- @field depth number | nil
--- @field shader string | nil
OverlayImageConfig = {}

--- @class OverlayConfig
--- @field text OverlayTextConfig
--- @field image OverlayImageConfig | nil
OverlayConfig = {}

--- @class Config
--- @field python_path string | nil
--- @field log_level LogLevel | nil
--- @field clone_path string | nil
--- @field binary_path string | nil
--- @field hotkeys Hotkeys | nil
--- @field ww_cli WwCliConfig
--- @field wayevents_path string
--- @field overlay OverlayConfig
Config = {
	python_path = "/usr/bin/python3",
	clone_path = "~/all-portals-overlay",
	ww_cli = {
		start_key = "BACKSLASH",
		enter_key = "Return",
		look = {
			x = 200,
			y = 200,
			size = 7,
			color = "#FFFFFF",
			completion_color = "#323232",
		},
		commands = {
			add_sh = "apadd",
			remove_sh = "aprm",
			ring = "apring",
		},
	},
	wayevents_path = "~/.local/bin/wayevents",
	hotkeys = Hotkeys,
	overlay = {
		text = {
			x = 1620,
			y = 780,
			size = 7,
			color = "#FFFFFF",
		},
		image = {
			dst = {
				x = 1620,
				y = 780,
				w = 400,
				h = 300,
			},
		},
	},
}

--- @class WwCliLook
--- @field x number
--- @field y number
--- @field size number
--- @field color string
--- @field completion_color string
WwCliLook = {}

--- @class WwCliCommands
--- @field add_sh string
--- @field remove_sh string
--- @field ring string
WwCliCommands = {}

--- @class WwCliConfig
--- @field start_key string
--- @field enter_key string
--- @field look WwCliLook
--- @field commands WwCliCommands
WwCliConfig = {}

--- @param hotkeys Hotkeys
--- @return Hotkeys
local parse_hotkeys = function(hotkeys)
	return {
		next = hotkeys.next or Config.hotkeys.next,
		prev = hotkeys.prev or Config.hotkeys.prev,
		reset = hotkeys.reset or Config.hotkeys.reset,
		solve = hotkeys.solve or Config.hotkeys.solve,
		show_overlay = hotkeys.show_overlay or Config.hotkeys.show_overlay,
		hide_overlay = hotkeys.hide_overlay or Config.hotkeys.hide_overlay,
	}
end

--- @param ww_cli_look WwCliLook
--- @return WwCliLook
local parse_ww_cli_look = function(ww_cli_look)
	return {
		x = ww_cli_look.x or Config.ww_cli.look.x,
		y = ww_cli_look.y or Config.ww_cli.look.y,
		size = ww_cli_look.size or Config.ww_cli.look.size,
		color = ww_cli_look.color or Config.ww_cli.look.color,
		completion_color = ww_cli_look.completion_color or Config.ww_cli.completion_color,
	}
end

--- @param ww_cli_commands WwCliCommands
--- @return WwCliCommands
local parse_ww_cli_commands = function(ww_cli_commands)
	return {
		add_sh = ww_cli_commands.add_sh or Config.ww_cli.commands.add_sh,
		remove_sh = ww_cli_commands.remove_sh or Config.ww_cli.commands.remove_sh,
		ring = ww_cli_commands.ring or Config.ww_cli.commands.ring,
	}
end

--- @param ww_cli_config WwCliConfig
--- @return WwCliConfig
local parse_ww_cli_config = function(ww_cli_config)
	return {
		start_key = ww_cli_config.start_key or Config.ww_cli.start_key,
		enter_key = ww_cli_config.enter_key or Config.ww_cli.enter_key,
		look = parse_ww_cli_look(ww_cli_config.look or Config.ww_cli.look),
		commands = parse_ww_cli_commands(ww_cli_config.commands or Config.ww_cli.commands),
	}
end

--- @param overlay_text_config OverlayTextConfig
--- @return OverlayTextConfig
local parse_overlay_text_config = function(overlay_text_config)
	return {
		x = overlay_text_config.x or Config.overlay.text.x,
		y = overlay_text_config.y or Config.overlay.text.y,
		size = overlay_text_config.size or Config.overlay.text.size,
		color = overlay_text_config.color or Config.overlay.text.color,
	}
end

--- @param dst_config DstConfig
--- @return DstConfig
local parse_dst_config = function(dst_config)
	return {
		x = dst_config.x or Config.overlay.image.dst.x,
		y = dst_config.y or Config.overlay.image.dst.y,
		w = dst_config.w or Config.overlay.image.dst.w,
		h = dst_config.h or Config.overlay.image.dst.h,
	}
end

--- @param overlay_image_config OverlayImageConfig
--- @return OverlayImageConfig
local parse_overlay_image_config = function(overlay_image_config)
	return {
		dst = overlay_image_config.dst and parse_dst_config(overlay_image_config.dst) or Config.overlay.image.dst,
		depth = overlay_image_config.depth or Config.overlay.image.depth,
		shader = overlay_image_config.shader or Config.overlay.image.shader,
	}
end

--- @param overlay_config OverlayConfig
--- @return OverlayConfig
local parse_overlay_config = function(overlay_config)
	return {
		text = overlay_config.text and parse_overlay_text_config(overlay_config.text) or Config.overlay.text,
		image = overlay_config.image and parse_overlay_image_config(overlay_config.image) or Config.overlay.image,
	}
end

--- @param cfg Config
--- @return Config | nil
local parse_config = function(cfg)
	local config = {
		python_path = utils.normalize_path(cfg.python_path or Config.python_path),
		clone_path = utils.normalize_path(cfg.clone_path or Config.clone_path),
		binary_path = utils.normalize_path(cfg.binary_path or Config.binary_path),
		hotkeys = cfg.hotkeys and parse_hotkeys(cfg.hotkeys) or Config.hotkeys,
		ww_cli = parse_ww_cli_config(cfg.ww_cli or Config.ww_cli),
		wayevents_path = cfg.wayevents_path or Config.wayevents_path,
		overlay = cfg.overlay and parse_overlay_config(cfg.overlay) or Config.overlay,
	}
	-- Check if clone_path and python_path are set OR binary_path is set.
	if (not config.clone_path or not config.python_path) and not config.binary_path then
		Log:error("No clone_path and python_path or binary_path set. Please set one of them.")
		return nil
	end
	return config
end

M.setup = function(config, cfg)
	local user_config = parse_config(cfg)
	if not user_config then
		Log:error("Could not parse config.")
		return
	end

	local path = os.getenv("PATH")
	local home = os.getenv("HOME")
	if home == nil or path == nil then
		Log:error("No $HOME or $PATH set.")
		return
	end
	os.setenv("PATH", path .. ":" .. home .. "/.local/bin" .. ":" .. home .. "/.cargo/bin")
	local events = require("wayevents.init")({
		autoinstall = "prebuilt",
	})

	local ap_overlay = AllPortalsOverlay.new(user_config)
	if not ap_overlay then
		Log:error("Could not create AllPortalsOverlay instance.")
		return
	end

	events.listen("update", function()
		ap_overlay:overlay_update()
	end)

	local ww_cli_cfg = {
		start_key = user_config.ww_cli.start_key,
		enter_key = user_config.ww_cli.enter_key,
		look = user_config.ww_cli.look,
		commands = {
			-- apadd <x> <y> <ring_number: optional>
			[user_config.ww_cli.commands.add_sh] = function(args)
				ap_overlay:input_stronghold(args)
			end,
			-- aprm <ring number: optional>
			[user_config.ww_cli.commands.remove_sh] = function(args)
				ap_overlay:remove_stronghold(args)
			end,
			-- apring <x> <y>
			[user_config.ww_cli.commands.ring] = function(args)
				ap_overlay:check_ring(args)
			end,
		},
		add_inputs = {
			["minus"] = "-",
		},
		arbitrary_command = function(key) end,
	}
	config.actions[user_config.hotkeys.next] = function()
		ap_overlay:next()
		return false
	end
	config.actions[user_config.hotkeys.prev] = function()
		ap_overlay:prev()
		return false
	end
	config.actions[user_config.hotkeys.reset] = function()
		ap_overlay:reset()
		return false
	end
	config.actions[user_config.hotkeys.solve] = function()
		ap_overlay:solve()
		return false
	end
	config.actions[user_config.hotkeys.show_overlay] = function()
		ap_overlay:overlay_update()
		return false
	end
	config.actions[user_config.hotkeys.hide_overlay] = function()
		ap_overlay:overlay_hide()
		return false
	end
	ww_command_line.setup(config, ww_cli_cfg)
end

return M
