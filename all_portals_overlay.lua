local waywall = require("waywall")
local utils = require("ww_ap_overlay.utils")
local json = require("json.json")

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
--- @field __ring_cmd string
--- @field __solve_cmd string
--- @field __reset_cmd string
--- @field __next_cmd string
--- @field __prev_cmd string
--- @field __add_sh_cmd string
--- @field __remove_sh_cmd string
--- @field __overlay_image_path string
--- @field __cfg Config
--- @field __strongholds Strongholds
--- @field __output_obj SceneObj
--- @field __output_img SceneObj
--- @field __solved boolean
--- @field new fun(cfg: Config): AllPortalsOverlay | nil
--- @field parse_current_strongholds_for_output fun(self): string
--- @field read_session_strongholds fun(self, filepath: string)
--- @field strongholds_is_full fun(strongholds: Strongholds): boolean
--- @field solve fun(self)
--- @field input_stronghold fun(self, args: string[])
--- @field check_ring fun(self, args: string[])
--- @field reset fun(self)
--- @field next fun(self)
--- @field prev fun(self)
--- @field overlay_update fun(self)
--- @field overlay_hide fun(self)
AllPortalsOverlay = {}

AllPortalsOverlay.new = function(cfg)
	local self = setmetatable({}, { __index = AllPortalsOverlay })
	self.__cfg = cfg
	self.__solved = false
	local ring_cmd = ""
	local solve_cmd = ""
	local reset_cmd = ""
	local next_cmd = ""
	local prev_cmd = ""
	local overlay_image_path = ""
	local add_sh_cmd = ""
	local remove_sh_cmd = ""
	if cfg.binary_path ~= nil and cfg.binary_path ~= "" then
		ring_cmd = cfg.binary_path .. " ring"
		solve_cmd = cfg.binary_path .. " --wayevents solver --headless"
		reset_cmd = cfg.binary_path .. " --wayevents reset"
		next_cmd = cfg.binary_path .. " --wayevents next --wayevents"
		prev_cmd = cfg.binary_path .. " --wayevents prev"
		add_sh_cmd = cfg.binary_path .. " add-measurement"
		remove_sh_cmd = cfg.binary_path .. " remove-measurement"
		local parent_dir = utils.get_parent_dir(cfg.binary_path)
		if not parent_dir then
			return nil
		end
		overlay_image_path = parent_dir .. "/all-portals-overlay.png"
		self:read_session_strongholds(cfg.binary_path .. "/.session")
	else
		ring_cmd = cfg.python_path .. " " .. cfg.clone_path .. "/main.py ring"
		solve_cmd = cfg.python_path .. " " .. cfg.clone_path .. "/main.py --wayevents solver --headless"
		reset_cmd = cfg.python_path .. " " .. cfg.clone_path .. "/main.py --wayevents reset"
		next_cmd = cfg.python_path .. " " .. cfg.clone_path .. "/main.py --wayevents next"
		prev_cmd = cfg.python_path .. " " .. cfg.clone_path .. "/main.py --wayevents prev"
		overlay_image_path = cfg.clone_path .. "/all-portals-overlay.png"
		add_sh_cmd = cfg.python_path .. " " .. cfg.clone_path .. "/main.py add-measurement"
		remove_sh_cmd = cfg.python_path .. " " .. cfg.clone_path .. "/main.py remove-measurement"
		self:read_session_strongholds(cfg.clone_path .. "/.session")
	end
	self.__ring_cmd = ring_cmd
	self.__solve_cmd = solve_cmd
	self.__reset_cmd = reset_cmd
	self.__next_cmd = next_cmd
	self.__prev_cmd = prev_cmd
	self.__overlay_image_path = overlay_image_path
	self.__strongholds = self.__strongholds or Strongholds
	self.__add_sh_cmd = add_sh_cmd
	self.__remove_sh_cmd = remove_sh_cmd
	self.__output_obj = nil
	self.__output_img = nil
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

function AllPortalsOverlay:parse_current_strongholds_for_output()
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
	return "Current SHs\n" .. output
end

function AllPortalsOverlay:read_session_strongholds(filepath)
	local handle = io.open(filepath, "r")
	if handle == nil then
		return
	end
	--- @type string | nil
	local sh_line_contents = handle:read("*l")
	if sh_line_contents == nil then
		return
	end
	local sh_contents = json.decode(sh_line_contents)
	if sh_contents == nil then
		return
	end
	self.__strongholds = sh_contents
end

function AllPortalsOverlay:solve()
	if not self.strongholds_is_full(self.__strongholds) then
		return
	end
	if self.__output_obj then
		self.__output_obj:close()
		self.__output_obj = nil
	end
	waywall.exec(self.__solve_cmd)
	self:overlay_update()
	self.__solved = true
end

function AllPortalsOverlay:input_stronghold(args)
	if #args ~= 2 and #args ~= 3 then
		Log:error("Invalid number of arguments. Expected 2 or 3, got " .. #args)
		return
	end
	local x = tonumber(args[1])
	if not x and x ~= 0 then
		Log:error("Invalid x coordinate. Expected a number, got " .. args[2])
		return
	end
	local y = tonumber(args[2])
	if not y and y ~= 0 then
		Log:error("Invalid y coordinate. Expected a number, got " .. args[3])
		return
	end
	local ring_number = tonumber(args[3])
	if not ring_number then
		-- Infer ring_number by checking last nil value in the strongholds list
		for i = 1, 8 do
			local stronghold = self.__strongholds[i]
			if stronghold == nil then
				ring_number = i
				break
			end
		end
		if not ring_number then
			Log:error(
				"Could not infer ring_number.\nEither the session strongholds are full or something really bad happened. Report this issue."
			)
			return
		end
	end
	self.__strongholds[ring_number] = { x, y }
	waywall.exec(self.__add_sh_cmd .. " " .. ring_number .. " " .. x .. " " .. y)
	self.__output_obj = waywall.text(self:parse_current_strongholds_for_output(), self.__cfg.overlay.text)
end

function AllPortalsOverlay:remove_stronghold(args)
	local ring_number = tonumber(args[1])
	if not ring_number then
		-- Infer ring number as the last element of self.__strongholds
		ring_number = #self.__strongholds
		if not ring_number then
			Log:error(
				"Could not infer ring_number.\nEither the session strongholds are full or something really bad happened. Report this issue."
			)
			return
		end
	end
	self.__strongholds[ring_number] = nil
	waywall.exec(self.__remove_sh_cmd .. " " .. ring_number)
	self.__output_obj = waywall.text(self:parse_current_strongholds_for_output(), self.__cfg.overlay.text)
end

function AllPortalsOverlay:check_ring(args)
	if #args ~= 2 then
		Log:error("Invalid number of arguments. Expected 2, got " .. #args)
		return
	end
	local x = tonumber(args[1])
	if not x and x ~= 0 then
		Log:error("Invalid x coordinate. Expected a number, got " .. args[2])
		return
	end
	local y = tonumber(args[2])
	if not y and y ~= 0 then
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
	self.__strongholds = Strongholds
	local handle = io.popen(self.__reset_cmd)
	if not handle then
		Log:error("Could not run reset command. Error: " .. handle)
		return
	end
	handle:close()
	if self.__output_obj then
		self.__output_obj:close()
		self.__output_obj = nil
	end
	self.__solved = false
end

function AllPortalsOverlay:next()
	local handle = io.popen(self.__next_cmd)
	if not handle then
		Log:error("Could not run next command. Error: " .. handle)
		return
	end
	handle:close()
end

function AllPortalsOverlay:prev()
	local handle = io.popen(self.__prev_cmd)
	if not handle then
		Log:error("Could not run prev command. Error: " .. handle)
		return
	end
	handle:close()
end

function AllPortalsOverlay:overlay_update()
	self:overlay_hide()
	if not self.__solved then
		self.__output_obj = waywall.text(self:parse_current_strongholds_for_output(), self.__cfg.overlay.text)
	else
		self.__output_img = waywall.image(self.__overlay_image_path, self.__cfg.overlay.image)
	end
end

function AllPortalsOverlay:overlay_hide()
	if self.__output_obj then
		self.__output_obj:close()
		self.__output_obj = nil
	end
	if self.__output_img then
		self.__output_img:close()
		self.__output_img = nil
	end
end

return M
