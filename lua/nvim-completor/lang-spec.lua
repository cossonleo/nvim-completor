--------------------------------------------------
--    LICENSE: MIT
--     Author: Cosson2017
--    Version: 0.1
-- CreateTime: 2018-03-06 11:52:05
-- LastUpdate: 2018-03-19 13:10:54
--       Desc: relative filetype 
--------------------------------------------------

local module = {}

local helper = require("nvim-completor/helper")

-- return [start, replace]
local function l_cfamily_trigger_pos(str)
	local start = 0
	start = string.find(str, '[%.#][_%w]*$')
	if start ~= nil then
		return {start, start + 1}
	end
	start = string.find(str, '->[%w_]*$')
	if start ~= nil then
		return {start + 1, start + 2}
	end
	start = string.find(str, '::[%w_]*$')
	if start ~= nil then
		return {start + 1, start + 2}
	end
	start = string.find(str,'[%w_]+$')
	if start ~= nil then
		return {start, start}
	end
	return nil
end

-- return [start, replace]
local function l_lua_trigger_pos(str)
	local start = string.find(str, '[%.:][%w_]*$')
	if start ~= nil then
		return {start, start + 1}
	end

	start = string.find(str, '[%w_]+$')
	if start ~= nil then
		return {start, start}
	end
	return nil
end

local function l_go_trigger_pos(str)
	local start = string.find(str, '[%.][%w_]*$')
	if start ~= nil then
		return {start, start + 1}
	end
	start = string.find(str, '[%w_]+$')
	if start ~= nil then
		return {start, start}
	end
	return nil
	
end

local function l_default_trigger_pos(str)
	local start = string.find(str, '[%w_]+')
	if start ~= nil then
		return {start, start}
	end
	return nil
end

local function e_set_ft()
	local _ft = helper.get_filetype()
	module.trigger_pos = l_default_trigger_pos

	if _ft == "lua" then
		module.trigger_pos = l_lua_trigger_pos
	end

	if _ft == "c" or _ft == "cpp" or _ft == "cc" or _ft == "h" or _ft == "hpp" then
		module.trigger_pos = l_cfamily_trigger_pos
	end

	if _ft == "go" then
		module.trigger_pos = l_go_trigger_pos
	end
end

module.trigger_pos = nil
module.set_ft = e_set_ft

return module

