--------------------------------------------------
--    LICENSE: MIT
--     Author: Cosson2017
--    Version: 0.1
-- CreateTime: 2018-03-06 11:52:05
-- LastUpdate: 2018-03-19 13:10:54
--       Desc: relative filetype 
--------------------------------------------------

local module = {}
local private = {}

local helper = require("nvim-completor/helper")

private.ft = nil
module.trigger_pos = nil

-- return [start, replace]
private.cfamily_trigger_pos = function(str)
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
private.lua_trigger_pos = function(str)
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

private.go_trigger_pos = function(str)
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

private.default_trigger_pos = function(str)
	local start = string.find(str, '[%w_]+')
	if start ~= nil then
		return {start, start}
	end
	return nil
end

module.set_ft = function()
	l_ft = helper.get_filetype()
	module.trigger_pos = private.default_trigger_pos

	if l_ft == "lua" then
		module.trigger_pos = private.lua_trigger_pos
	end

	if l_ft == "c" or l_ft == "cpp" or l_ft == "cc" or l_ft == "h" or l_ft == "hpp" then
		module.trigger_pos = private.cfamily_trigger_pos
	end

	if l_ft == "go" then
		module.trigger_pos = private.go_trigger_pos
	end
end

module.get_ft = function()
	return l_ft
end

return module

