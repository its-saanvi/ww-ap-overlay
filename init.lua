local utils = require("ww_ap_overlay.utils")
local waywall = require("waywall")
local ww_command_line = require("ww_command_line")
local all_portals_overlay = require("ww_ap_overlay.all_portals_overlay")

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
--- @field overlay_path string | nil
--- @field overlay_binary string | nil
--- @field hotkeys Hotkeys | nil
--- @field ww_cli WwCliConfig
--- @field overlay OverlayConfig
Config = {
	python_path = "/usr/bin/python3",
	overlay_path = "~/all-portals-overlay",
	ww_cli = {
		start_key = "BACKSLASH",
		enter_key = "Return",
		look = {
			x = 200,
			y = 200,
			size = 7,
			color = "#FFFFFF",
		},
	},
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
WwCliLook = {}

--- @class WwCliConfig
--- @field start_key string
--- @field enter_key string
--- @field look WwCliLook
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
	}
end

--- @param ww_cli_config WwCliConfig
--- @return WwCliConfig
local parse_ww_cli_config = function(ww_cli_config)
	return {
		start_key = ww_cli_config.start_key or Config.ww_cli.start_key,
		enter_key = ww_cli_config.enter_key or Config.ww_cli.enter_key,
		look = parse_ww_cli_look(ww_cli_config.look or Config.ww_cli.look),
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
		overlay_path = utils.normalize_path(cfg.overlay_path or Config.overlay_path),
		overlay_binary = utils.normalize_path(cfg.overlay_binary or Config.overlay_binary),
		hotkeys = cfg.hotkeys and parse_hotkeys(cfg.hotkeys) or Config.hotkeys,
		ww_cli = parse_ww_cli_config(cfg.ww_cli or Config.ww_cli),
		overlay = cfg.overlay and parse_overlay_config(cfg.overlay) or Config.overlay,
	}
	-- Check if overlay_path and python_path are set OR overlay_binary is set.
	if (not config.overlay_path or not config.python_path) and not config.overlay_binary then
		Log:error("No overlay_path or python_path set. Please set one of them.")
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

	local ap_overlay = AllPortalsOverlay.new(user_config)
	if not ap_overlay then
		Log:error("Could not create AllPortalsOverlay instance.")
		return
	end
	waywall.listen("load", function()
		ap_overlay:start_server()
	end)

	local ww_cli_cfg = {
		start_key = user_config.ww_cli.start_key,
		enter_key = user_config.ww_cli.enter_key,
		look = {
			x = user_config.ww_cli.look.x,
			y = user_config.ww_cli.look.y,
			size = user_config.ww_cli.look.size,
			color = user_config.ww_cli.look.color,
		},
		commands = {
			-- apnextsh <ring number> <x> <y>
			["apnextsh"] = function(args)
				ap_overlay:input_next_stronghold(args)
			end,
			-- apring <x> <y>
			["apring"] = function(args)
				ap_overlay:check_ring(args)
			end,
		},
		arbitrary_command = function(key) end,
	}
	config.actions[user_config.hotkeys.next] = function()
		ap_overlay:next()
	end
	config.actions[user_config.hotkeys.prev] = function()
		ap_overlay:prev()
	end
	config.actions[user_config.hotkeys.reset] = function()
		ap_overlay:reset()
	end
	config.actions[user_config.hotkeys.solve] = function()
		ap_overlay:solve()
	end
	config.actions[user_config.hotkeys.show_overlay] = function()
		ap_overlay:overlay_update()
	end
	config.actions[user_config.hotkeys.hide_overlay] = function()
		ap_overlay:overlay_hide()
	end
	ww_command_line.setup(config, ww_cli_cfg)
end

return M
