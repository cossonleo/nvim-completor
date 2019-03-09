--------------------------------------------------
--    LICENSE: MIT
--     Author: Cosson2017
--    Version: 0.2
-- CreateTime: 2018-03-06 11:38:17
-- LastUpdate: 2018-03-18 18:18:01
--       Desc: 
--------------------------------------------------

-- module name
local module = {}
local private = {}

local log = require("nvim-completor/log")

---- 获取当前行内容
---- start：开始列 如果nil，则设置为1
---- ed：结束列 如果nil, 则设置为到光标前一个位置
---- [start, ed]
---- return: str
--module.get_cur_line = function(start, ed)
--	-- nvim_get_current_buf()
--	-- nvim_get_current_line()
--	-- nvim_buf_get_lines({buffer}, {start}, {end}, {strict_indexing})
--	local st = 1
--	local tail = 1
--	if start ~= nil then
--		st = start
--	end
--
--	if ed == nil then
--		local cp = module.get_curpos()
--		tail = cp.col - 1
--	else
--		tail = ed
--	end
--
--	if  tail < st then
--		return ""
--	end
--
--	local typed = vim.api.nvim_get_current_line()
--	if typed == nil or #typed <= 0 or #typed < st then
--		return ""
--	end
--	local str = string.sub(typed, st, tail)
--	if str == nil then
--		return ""
--	end
--	return str
--end
--
-- 获取当前行内容
-- return: str
module.get_cur_line = function(start, ed)
	-- nvim_get_current_buf()
	-- nvim_get_current_line()
	-- nvim_buf_get_lines({buffer}, {start}, {end}, {strict_indexing})
	local st = 1
	local tail = 1
	if start ~= nil then
		st = start
	end

	if ed == nil then
		local cp = module.get_curpos()
		tail = cp.col - 1
	else
		tail = ed
	end

	if  tail < st then
		return ""
	end

	local typed = vim.api.nvim_get_current_line()
	if typed == nil or #typed <= 0 or #typed < st then
		return ""
	end
	local str = string.sub(typed, st, tail)
	if str == nil then
		return ""
	end
	return str
end

-- capture end [1, ed]
module.get_line_last_word = function(ed)
	-- [1, ed]
	local typed = module.get_cur_line(1, ed)
	return string.match(typed, '[%w_]+$')
end

-- row: 都是从1开始
-- getcurpos: col 从1开始 符合lua的下标
-- nvim_win_get_cursor: col 从0开始
module.get_curpos = function()
	local pos = vim.api.nvim_call_function('getcurpos', {})
	return {buf=pos[1], line=pos[2], col=pos[3]}
end

-- 获取buf的文件类型
module.get_filetype = function()
	local pos = module.get_curpos()
	return vim.api.nvim_buf_get_option(pos['buf'], 'filetype')
end

-- 获取buf的全路径文件名
module.get_bufname = function()
	--return vim.api.nvim_call_function('buffer_name', {'%'})
	return vim.api.nvim_call_function('expand', {'%:p'})
end

module.complete = function(start, items)
	--print(items)
	vim.api.nvim_call_function('nvim_completor#on_complete', {start, items})
end


module.dict_len = function(dict)
	local count = 0
	for k, v in pairs(dict) do
		count = count + 1
	end
	return count
end

module.menu_selected = function()
	local sl = vim.api.nvim_call_function('nvim_completor#menu_selected', {})
	if sl == 1 then
		return true
	end
	return false
end

-- word is [%w_]
module.is_word = function(str)
	if str == nil then
		return false
	end
	if type(str) ~= "string" then
		return false
	end

	local len = #str
	if len == 0 then
		return false
	end

	local st, ed = string.find(str, '[%w_]+')
	if st ~= 1 or ed ~= len then
		return false
	end
	return true
end

-- 判断字符是不是key字符
module.is_word_char = function(char)
	--if string.match(char, '[a-zA-Z0-9_]+') == char then
	if string.match(char, '[%w_]+') == char then
		return true
	end
	return false
end

module.has_prefix = function(str, pre)
	if str == nil or pre == nil then
		return false
	end
	
	if #str < #pre then
		return false
	end

	for i = 1, #pre, 1 do
		local sc = string.sub(str, i, i)
		local pc = string.sub(pre, i, i)
		if sc ~= pc then
			return false
		end
	end
	return true
end

module.table_to_string = function(t)
	if t == nil then
		return ""
	end
	if type(t) ~= "table" then
		return ""
	end
	if #t == 0 then
		return "{}"
	end

	local str = "{ "
	for i, v in pairs(t) do
		str = str .. "[" .. i .. "]" .. "=" .. v .. ","
	end

	local len = string.len(str)
	str = string.sub(str, 1, len - 1)
	str = str .. "}"
	return str
end
return module
