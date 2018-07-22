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

local log = require("nvim-completor/log")

-- 获取当前行内容
-- start：开始列 如果nil，则设置为1
-- ed：结束列 如果nil, 则设置为到光标前一个位置
-- [start, ed)
-- return: str
local function l_get_cur_line(start, ed)
	-- nvim_get_current_buf()
	-- nvim_get_current_line()
	-- nvim_buf_get_lines({buffer}, {start}, {end}, {strict_indexing})
	if start == nil then
		start = 1
	end

	if ed == nil then
		local cp = l_get_curpos()
		ed = cp.col - 1
	end

	local ctn = vim.api.nvim_get_current_line()
	local str = string.sub(ctx, start, ed - 1)
	return str
end

-- row: 都是从1开始
-- getcurpos: col 从1开始 符合lua的下标
-- nvim_win_get_cursor: col 从0开始 
local function l_get_curpos()
	local pos = vim.api.nvim_call_function('getcurpos', {})
	return {buf=pos[1], line=pos[2], col=pos[3]}
end

-- 获取buf的文件类型
local function l_get_filetype()
	local pos = l_get_curpos()
	return vim.api.nvim_buf_get_option(pos['buf'], 'filetype')
end

-- 获取buf的全路径文件名
local function l_get_bufname()
	--return vim.api.nvim_call_function('buffer_name', {'%'})
	return vim.api.nvim_call_function('expand', {'%:p'})
end

local function l_complete(start, items)
    vim.api.nvim_call_function('nvim_completor#on_complete', {start, items})
end


local function l_dict_len(dict)
	local count = 0
	for k, v in pairs(dict) do
		count = count + 1
	end
	return count
end

local function l_menu_selected()
	local sl = vim.api.nvim_call_function('nvim_completor#menu_selected', {})
	if sl == 1 then
		return true
	end
	return false
end


-- 判断字符是不是key字符
local function l_is_word_char(char)
	--if string.match(char, '[a-zA-Z0-9_]+') == char then
	if string.match(char, '[%w_]+') == char then
		return true
	end
	return false
end


-- 是否符合首字母模糊匹配
local function l_is_head_match(str, pattern)
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
local function l_head_fuzzy_match(items, pattern)
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
		local pir = l_is_head_match(lw, lp)
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

module.get_cur_line = l_get_cur_line
module.get_curpos = l_get_curpos
module.get_filetype = l_get_filetype
module.get_bufname = l_get_bufname
module.complete = l_complete
module.dict_len = l_dict_len
module.menu_selected = l_menu_selected
module.head_fuzzy_match = l_head_fuzzy_match

return module
