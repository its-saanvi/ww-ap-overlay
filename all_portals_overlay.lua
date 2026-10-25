local waywall = require("waywall")
local utils = require("ww_ap_overlay.utils")
local json = require("ww_ap_overlay.json.json")

local M = {}

--- @class Strongholds
--- @field [1] {[1]: number, [2]: number} | nil
--- @field [2] {[1]: number, [2]: number} | nil
--- @field [3] {[1]: number, [2]: number} | nil
--- @field [4] {[1]: number, [2]: number} | nil
--- @field [5] {[1]: number, [2]: number} | nil
--- @field [6] {[1]: number, [2]: number} | nil
--- @field [7] {[1]: number, [2]: number} | nil
--- @field [8] {[1]: number, [2]: number} | nil
Strongholds = {
	[1] = nil,
	[2] = nil,
	[3] = nil,
	[4] = nil,
	[5] = nil,
	[6] = nil,
	[7] = nil,
	[8] = nil,
}

--- @class SceneObj
--- @field close fun(self)
--- @field get_depth fun(self): number
--- @field set_depth fun(self, depth: number)
SceneObj = {}

--- @class AllPortalsOverlay
--- @field __server_cmd string
--- @field __ring_cmd string
--- @field __solve_cmd string
--- @field __reset_cmd string
--- @field __next_cmd string
--- @field __prev_cmd string
--- @field __overlay_image_path string
--- @field __cfg Config
--- @field __strongholds Strongholds
--- @field __output_obj SceneObj
--- @field __output_img SceneObj
--- @field new fun(cfg: Config): AllPortalsOverlay | nil
--- @field strongholds_is_full fun(strongholds: Strongholds): boolean
--- @field start_server fun(self)
--- @field solve fun(self)
--- @field input_next_stronghold fun(self, args: string[])
--- @field check_ring fun(self, args: string[])
--- @field reset fun(self)
--- @field next fun(self)
--- @field prev fun(self)
--- @field overlay_update fun(self)
--- @field overlay_hide fun(self)
AllPortalsOverlay = {}

AllPortalsOverlay.new = function(cfg)
	local self = setmetatable({}, { __index = AllPortalsOverlay })
	local server_cmd = ""
	local ring_cmd = ""
	local solve_cmd = ""
	local reset_cmd = ""
	local next_cmd = ""
	local prev_cmd = ""
	local overlay_image_path = ""
	if cfg.overlay_binary ~= nil and cfg.overlay_binary ~= "" then
		server_cmd = cfg.overlay_binary .. " server"
		ring_cmd = cfg.overlay_binary .. " ring"
		solve_cmd = cfg.overlay_binary .. " solver --headless"
		reset_cmd = cfg.overlay_binary .. " reset"
		next_cmd = cfg.overlay_binary .. " next"
		prev_cmd = cfg.overlay_binary .. " prev"
		local parent_dir = utils.get_parent_dir(cfg.overlay_binary)
		if not parent_dir then
			return nil
		end
		overlay_image_path = parent_dir .. "/all-portals-overlay.png"
	else
		server_cmd = cfg.python_path .. " " .. cfg.overlay_path .. "/main.py server"
		ring_cmd = cfg.python_path .. " " .. cfg.overlay_path .. "/main.py ring"
		solve_cmd = cfg.python_path .. " " .. cfg.overlay_path .. "/main.py solver --headless"
		reset_cmd = cfg.python_path .. " " .. cfg.overlay_path .. "/main.py reset"
		next_cmd = cfg.python_path .. " " .. cfg.overlay_path .. "/main.py next"
		prev_cmd = cfg.python_path .. " " .. cfg.overlay_path .. "/main.py prev"
		overlay_image_path = cfg.overlay_path .. "/all-portals-overlay.png"
	end
	if not server_cmd or not ring_cmd or not solve_cmd then
		Log:error("No overlay_binary or overlay_path set. Please set either one of them.")
		return nil
	end
	self.__server_cmd = server_cmd
	self.__ring_cmd = ring_cmd
	self.__solve_cmd = solve_cmd
	self.__reset_cmd = reset_cmd
	self.__next_cmd = next_cmd
	self.__prev_cmd = prev_cmd
	self.__overlay_image_path = overlay_image_path
	self.__strongholds = Strongholds
	self.__output_obj = nil
	self.__output_img = nil
	self.__cfg = cfg
	return self
end

AllPortalsOverlay.strongholds_is_full = function(strongholds)
	for _, stronghold in ipairs(strongholds) do
		if stronghold == nil or type(stronghold) ~= "table" or stronghold[1] == nil or stronghold[2] == nil then
			return false
		end
	end
	return #strongholds == 8
end

function AllPortalsOverlay:start_server()
	waywall.exec(self.__server_cmd)
	Log:info("AP Overlay Server has started (or see error log below :p)!")
end

function AllPortalsOverlay:solve()
	local stronghold_json_path = ""
	if self.__cfg.overlay_binary and self.__cfg.overlay_binary ~= "" then
		local parent_dir = utils.get_parent_dir(self.__cfg.overlay_binary)
		if not parent_dir then
			return
		end
		stronghold_json_path = parent_dir .. "/strongholds.json"
	else
		stronghold_json_path = self.__cfg.overlay_path .. "/strongholds.json"
	end
	if not self.strongholds_is_full(self.__strongholds) then
		Log:error("Strongholds.json does not have 8 strongholds.")
		return
	end
	local stronghold_json, err = io.open(stronghold_json_path, "w")
	if not stronghold_json then
		Log:error("Could not open strongholds.json. Error: " .. err)
		return
	end
	stronghold_json:write(json.encode(self.__strongholds))
	stronghold_json:flush()
	stronghold_json:close()
	if self.__output_obj then
		self.__output_obj:close()
		self.__output_obj = nil
	end
	waywall.exec(self.__solve_cmd)
end

function AllPortalsOverlay:input_next_stronghold(args)
	if self.strongholds_is_full(self.__strongholds) then
		Log:error("Strongholds.json already has 8 strongholds.")
		return
	end
	if #args ~= 3 then
		Log:error("Invalid number of arguments. Expected 3, got " .. #args)
		return
	end
	local ring_number = tonumber(args[1])
	if not ring_number then
		Log:error("Invalid ring number. Expected a number, got " .. args[1])
		return
	end
	local x = tonumber(args[2])
	if not x then
		Log:error("Invalid x coordinate. Expected a number, got " .. args[2])
		return
	end
	local y = tonumber(args[3])
	if not y then
		Log:error("Invalid y coordinate. Expected a number, got " .. args[3])
		return
	end
	self.__strongholds[ring_number] = { x, y }
	local output = ""
	for i = 1, 8 do
		if self.__strongholds[i] then
			output = output .. i .. " " .. self.__strongholds[i][1] .. " " .. self.__strongholds[i][2] .. "\n"
		end
	end

	if self.__output_obj then
		self.__output_obj:close()
		self.__output_obj = nil
	end
	self.__output_obj = waywall.text("Current SHs\n" .. output, self.__cfg.overlay.text)
end

function AllPortalsOverlay:check_ring(args)
	if #args ~= 2 then
		Log:error("Invalid number of arguments. Expected 2, got " .. #args)
		return
	end
	local x = tonumber(args[1])
	if not x then
		Log:error("Invalid x coordinate. Expected a number, got " .. args[2])
		return
	end
	local y = tonumber(args[2])
	if not y then
		Log:error("Invalid y coordinate. Expected a number, got " .. args[3])
		return
	end
	local handle = io.popen(self.__ring_cmd .. " " .. x .. " " .. y)
	if not handle then
		Log:error("Ring command failed. Could not run ring command.")
		return
	end
	local output = handle:read("*a")
	handle:close()
	if output == "" then
		Log:error("Ring command failed. Please check the log.")
		return
	end
	if self.__output_obj then
		self.__output_obj:close()
		self.__output_obj = nil
	end
	self._output_obj = waywall.text(output, self.__cfg.overlay.text)
end

function AllPortalsOverlay:reset()
	self:overlay_hide()
	local handle = io.popen(self.__reset_cmd)
	if not handle then
		Log:error("Could not run reset command. Error: " .. handle)
		return
	end
	handle:close()
	self.__strongholds = Strongholds
	if self.__output_obj then
		self.__output_obj:close()
		self.__output_obj = nil
	end
	self:overlay_update()
end

function AllPortalsOverlay:next()
	self:overlay_hide()
	local handle = io.popen(self.__next_cmd)
	if not handle then
		Log:error("Could not run next command. Error: " .. handle)
		return
	end
	handle:close()
	self:overlay_update()
end

function AllPortalsOverlay:prev()
	self:overlay_hide()
	local handle = io.popen(self.__prev_cmd)
	if not handle then
		Log:error("Could not run prev command. Error: " .. handle)
		return
	end
	handle:close()
	self:overlay_update()
end

function AllPortalsOverlay:overlay_update()
	self:overlay_hide()
	utils.make_curl_request_for_image()
	self.__output_img = waywall.image(self.__overlay_image_path, self.__cfg.overlay.image)
end

function AllPortalsOverlay:overlay_hide()
	if self.__output_img then
		self.__output_img:close()
		self.__output_img = nil
	end
end

return M
