--------------------------------------------------
--    LICENSE: MIT
--     Author: Cosson2017
--    Version: 0.1
-- CreateTime: 2018-03-06 11:52:05
-- LastUpdate: 2018-03-06 11:52:05
--       Desc: relative filetype 
--------------------------------------------------

local ft = {}

local api = require("api")

local function normal_trigger(str)
	if string.match(str, '[%w_.]+') ~= nil then
		return true
	end

	return false

end

local function go_trigger(str)
	return false
end

local function cfamily_trigger(str)
	return false
end

local function _trigger(str)
	if normal_trigger(str) then
		return true
	end

	-- TODO this is relative filetype
	
	return false
end

ft.trigger = _trigger

return ft

