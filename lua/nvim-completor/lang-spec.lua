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

-- return start, replace
private.lang_trigger_pos_info = function(str)
	local trigger_patterns = private.lang_trigger_pattern[private.ft]
	for _, sub in ipairs(trigger_patterns) do
		local offset = string.len(sub)
		local pattern = private.covert2pattern(sub)
		local start = string.find(str, pattern)
		if start ~= nil then
			return start + offset
		end
	end

	local start = string.find(str,'[%w_]+$')
	if start ~= nil then
		return start
	end
	return nil
end

-- return {trigger_pos, complete_start_pos}
private.default_trigger_pos_info = function(str)
	local start = string.find(str, '%.$')
	if start ~= nil then
		return start + 1
	end

	start = string.find(str, '[%w_]+')
	if start ~= nil then
		return start
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

-- return bool
-- 是否触发补全
module.fire_complete = function(col)
	if col < 1 then
		return false
	end

	if module.fire_postion(col) == 0 then
		return false
	end

	return true
end

-- return num
-- 触发位置
module.fire_postion = function(col)
	if col < 1 then
		return 0
	end
	local typed = helper.get_cur_line(0, col)
	if typed == nil or #typed == 0 then
		return 0
	end

	local pos = private.trigger_pos_info(typed)
	if pos == nil then
		return 0
	end
	if pos <= 0 then
		return 0
	end
	return pos
end

--module.trigger_pos = private.trigger_pos_info
module.gener_complete_start = function(col)
	if col == 1 then
		return 0
	end
	local typed = helper.get_cur_line(0, col)
	if typed == nil or #typed == 0 then
		return 0
	end
	local _, compl_start = private.trigger_pos_info(typed)
	if compl_start == nil then
		return 0
	end
	return compl_start
end

module.is_fire_complete = function(typed)
	return true
end

return module

