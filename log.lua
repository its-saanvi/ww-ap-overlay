local waywall = require("waywall")
local M = {}

--- @enum LogLevel
LogLevel = {
	ERROR = 0,
	WARN = 1,
	INFO = 2,
	DEBUG = 3,
}

--- @class Logger
--- @field __log fun(self, msg: string)
--- @field __log_error fun(self, msg: string)
--- @field __output_obj SceneObj
--- @field __cfg Config
--- @field level LogLevel
--- @field debug fun(self, msg: string)
--- @field info fun(self, msg: string)
--- @field warn fun(self, msg: string)
--- @field error fun(self, msg: string)
--- @field close_error_output fun(self)
Logger = {}

function Logger:__log_error(msg)
	if self.__output_obj ~= nil then
		self.__output_obj:close()
		self.__output_obj = nil
	end
	self.__output_obj = waywall.text(msg, {
		x = 0,
		y = 0,
		size = 2,
		color = "#F7768E",
	})
	waywall.sleep(5000)
	if self.__output_obj ~= nil then
		self.__output_obj:close()
		self.__output_obj = nil
	end
	error(msg)
end

function Logger:__log(msg)
	print(msg)
end

function Logger.new(cfg)
	local self = setmetatable({}, { __index = Logger })
	self.level = LogLevel.DEBUG
	self.__cfg = cfg
	return self
end

function Logger:debug(msg)
	if self.level >= LogLevel.DEBUG then
		self:__log(msg)
	end
end

function Logger:info(msg)
	if self.level >= LogLevel.INFO then
		self:__log(msg)
	end
end

function Logger:warn(msg)
	if self.level >= LogLevel.WARN then
		self:__log(msg)
	end
end

function Logger:error(msg)
	if self.level >= LogLevel.ERROR then
		self:__log_error(msg)
	end
end

--- @type Logger
Log = Logger:new()

return M
