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

-- 获取当前行内容
-- start：开始列 如果nil，则设置为1
-- ed：结束列 如果nil, 则设置为到光标前一个位置
-- [start, ed)
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

	local ctn = vim.api.nvim_get_current_line()
	if ctn == nil or #ctn <= 0 or #ctn < st then
		return ""
	end
	local str = string.sub(ctn, st, tail)
	return str
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
	log.debug("item len")
	print(items)
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


-- 判断字符是不是key字符
module.is_word_char = function(char)
	--if string.match(char, '[a-zA-Z0-9_]+') == char then
	if string.match(char, '[%w_]+') == char then
		return true
	end
	return false
end


-- 是否符合首字母模糊匹配
module.is_head_match = function(str, pattern)
	slen = str:len()
	plen = pattern:len()
	if slen < plen then
		return 0
	end

	if str:sub(1,1) ~= pattern:sub(1,1) then
		return 0
	end

	if plen == 1 then
		return slen
	end

	local n = 2
	local m = 46  -- 2 ^ m 	当m <= 46时是整数
	local sum = 0 -- sum max 2 ^ 46 - 1
	for i = 2, plen, 1 do
		if slen - n < plen - i then 
			return 0
		end

		for j = n, slen, 1 do
			n = n + 1
			if str:sub(j,j) == pattern:sub(i, i) then
				if n < m + 1 then
					sum = sum + 2 ^ (m - n + 1)
				end
				break
			end
			if j == slen then
				return 0
			end
			if slen - j < plen - i then
				return 0
			end
		end
	end
	return sum
end

-- @items: table
-- @pattern:
-- return: table
module.head_fuzzy_match = function(items, pattern)
	if items == nil or #items == 0 then
		return {}
	end

	if pattern:len() == 0 then
		return items
	end

	local lp = string.lower(pattern)

	local result = {}
	local sortArray = {}
	for i, v in pairs(items) do
		local lw = string.lower(v['word'])
		local pir = module.is_head_match(lw, lp)
		if  pir ~= 0 then
			local j = i
			while(result[pir] ~= nil) do
				local p = result[pir]
				if items[j]['word'] > items[p]['word'] then
					result[pir] = j
					j = p
				end
				pir = pir + 1
			end
			result[pir] = j
			table.insert(sortArray, pir)
		end
	end
	table.sort(sortArray)
	local candicates = {}

	for i = 1, #sortArray, 1 do
		local index = result[sortArray[i]]
		table.insert(candicates,1, items[index])
	end
	return candicates
end
return module
