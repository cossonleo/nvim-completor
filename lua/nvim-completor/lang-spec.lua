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

private.lang_trigger_pattern = {
	cpp = {"->", "::", "#", "."},
	c = {"->", "::", "#", "."},
	rust = {".", "::"},
	lua = {".", ":"},
	go = {"."},
	javascript = {".", "$"},
	php = {".", "->"},
	html = {"<"},
}
private.lang_trigger_pattern["cpp"] = {"->", "::", "#", "."}

private.covert2pattern = function(str)
	if str == "." then
		return "%.$"
	elseif str == "$" then
		return "%$$"
	end

	return str .. "$"
end

-- return [start, replace]
private.lang_trigger_pos_info = function(str)
	local trigger_patterns = private.lang_trigger_pattern[private.ft]
	for _, sub in ipairs(trigger_patterns) do
		local offset = string.len(sub) - 1
		local pattern = private.covert2pattern(sub)
		local start = string.find(str, pattern)
		if start ~= nil then
			return {start + offset, start + offset + 1}
		end
	end

	local start = string.find(str,'[%w_]+$')
	if start ~= nil then
		return {start, start}
	end
	return nil
end

-- return {trigger_pos, complete_start_pos}
private.default_trigger_pos_info = function(str)
	local start = string.find(str, '[%.][_%w]*$')
	if start ~= nil then
		return {start, start + 1}
	end

	start = string.find(str, '[%w_]+')
	if start ~= nil then
		return {start, start}
	end

	return nil
end

private.trigger_pos_info = function(str)
	local trigger_patterns = private.lang_trigger_pattern[private.ft]
	if trigger_patterns == nil then
		return private.default_trigger_pos_info(str)
	end
	return private.lang_trigger_pos_info(str)
end

module.set_ft = function()
	private.ft = helper.get_filetype()
end

module.get_ft = function()
	return private.ft
end

module.trigger_pos = private.trigger_pos_info

return module

