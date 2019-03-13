
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
private.trigger_len = 2

private.lang_trigger_pattern = {
	cpp = {"->", "::", "#", "%."},
	c = {"->", "::", "#", "%."},
	rust = {"%.", "::"},
	lua = {"%.", ":"},
	go = {"%."},
	javascript = {"%."},
	php = {"%.", "->"},
	html = {"<"},
}

private.is_fire_complete = function(typed)
	if private.ft ~= nil and private.ft ~= "" then
		local trigger_patterns = private.lang_trigger_pattern[private.ft]
		if trigger_patterns ~= nil then
			for _, sub in ipairs(trigger_patterns) do
				local start = string.find(typed, sub.."$")
				if start ~= nil then
					return true
				end
			end
		end
	end

	local start, tail = string.find(typed, '[%w_]+$')
	if start == nil or tail == nil then
		return false
	end

	if tail - start + 1 < private.trigger_len then
		return false
	end

	return true
end

module.set_ft = function()
	private.ft = helper.get_filetype()
end

module.get_ft = function()
	return private.ft
end

module.set_trigger_len = function(len)
	private.trigger_len = len
end

module.is_fire_complete = private.is_fire_complete

return module

