--------------------------------------------------
--    LICENSE: 
--     Author: 
--    Version: 
-- CreateTime: 2018-07-21 07:39:54
-- LastUpdate: 2018-07-21 07:39:54
--       Desc: 
--------------------------------------------------

local module = {}

local l_ctx = nil -- 当前上下文环境
local l_candidate = nil -- 当前候选
local cache = nil
local last_pattern = nil

-- 是否符合首字母模糊匹配
local function func_is_head_match(str, pattern)
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
local function func_head_fuzzy_match(items, pattern)
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
		local pir = func_is_head_match(lw, lp)
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

-- 新的候选
local function func_add_candidate(ctx, candi)
	if l_ctx == nil then
		l_ctx = ctx
		l_candidate = candi
	end

	func_match_complete()
end

-- 触发或更新补全选项
local function func_match_complete()
end

module.head_fuzzy_match = func_head_fuzzy_match
module.add_candidate = func_add_candidate

return module
