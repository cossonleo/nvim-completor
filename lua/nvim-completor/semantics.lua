
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
	local start, tail = string.find(typed, '[%w_]+$')
	if start ~= nil or tail ~= nil then
		if tail - start + 1 >= private.trigger_len then
			return true
		end
	end
	if private.ft ~= nil and private.ft ~= "" then
		local trigger_patterns = private.lang_trigger_pattern[private.ft]
		if trigger_patterns ~= nil then
			for _, sub in ipairs(trigger_patterns) do
				local pattern = sub .. "[%w_]*$"
				start = string.find(typed, pattern)
				if start ~= nil then
					return true
				end
			end
		end
	end
	return false
end

private.last_word_pos = function(typed)
	if typed == nil or #typed == 0 then
		return nil, nil
	end
	return typed:find("[%w_]+$")
end

private.new_text_pos = function(ctx)
	if ctx == nil then
		return nil
	end

	local front_str = ctx.typed:sub(1, ctx.col)
	local fstart, fend = front_str:find("[%w_]+$")
	if fstart == nil then
		fstart = #front_str + 1
		fend = #front_str + 1
	else
		fend = fend + 1
	end

	local end_str = ctx.typed:sub(ctx.col + 1)
	if #end_str > 0  then
		local _, tt = end_str:find("^[%w_]+")
		if tt ~= nil then
			fend = #front_str + tt + 1
		end
	end
	return fstart, fend
end

module.set_ft = function(ft)
	private.ft = ft
end

module.get_ft = function()
	return private.ft
end

module.set_trigger_len = function(len)
	private.trigger_len = len
end

module.is_fire_complete = private.is_fire_complete
module.last_word_pos = private.last_word_pos
module.new_text_pos = private.new_text_pos

return module

