--------------------------------------------------
--    LICENSE: MIT
--     Author: Cosson2017
--    Version: 0.1
-- CreateTime: 2018-03-06 11:52:05
-- LastUpdate: 2018-03-19 13:10:54
--       Desc: relative filetype 
--------------------------------------------------

local module = {}

local api = require("api")

local function _cfamily_trigger_pos(str)
	local start = 0
	start = string.find(str, '[%.#][_%w]*$')
	if start ~= nil then
		return start
	end
	start = string.find(str, '->[%w_]*$')
	if star ~= nil then
		return start + 1
	end
	start = string.find(str, '::[%w_]*$')
	if start ~= nil then
		return start + 1
	end
	return string.find(str,'[%w_]+$')
end

local function _lua_trigger_pos(str)
	local start = string.find(str, '[%.:][%w_]*$')
	if start ~= nil then
		return start
	end
	return string.find(str, '[%w_]+$')
end

local function _go_trigger_pos(str)
	local start = string.find(str, '[%.][%w_]*$')
	if start ~= nil then
		return start
	end
	return string.find(str, '[%w_]+$')
end

local function _set_ft()
	_ft = api.get_filetype()

	if _ft == "lua" then
		module.filetype = _ft
		module.trigger_pos = _lua_trigger_pos
	end

	if _ft == "c" or _ft == "cpp" or _ft == "cc" or _ft == "h" or _ft == "hpp" then
		module.filetype = _ft
		module.trigger_pos = _cfamily_trigger_pos
	end

	if _ft == "go" then
		module.filetype = _ft
		module.trigger_pos = _go_trigger_pos
	end
end

module.trigger_pos = nil
module.filetype = nil
module.set_ft = _set_ft

return module

