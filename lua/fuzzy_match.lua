--------------------------------------------------
--    LICENSE: MIT
--     Author: Cosson2017
--    Version: 0.1
-- CreateTime: 2018-03-08 18:36:13
-- LastUpdate: 2018-03-08 18:36:28
--       Desc: 
--------------------------------------------------

local module = {}

-- 是否符合首字母模糊匹配
local function _is_head_match(str, pattern)
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
	local m = 33
	local sum = 0
	for i = 2, plen, 1 do
		if slen - n < plen - i then 
			return 0
		end

		for j = n, slen, 1 do
			n = n + 1
			if str:sub(j,j) == pattern:sub(i, i) then
				sum = sum + 2 ^ (m - n + 1)
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
function module.head_fuzzy_match(items, pattern)
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
		local pir = _is_head_match(lw, lp)
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
	for i = -1, -1 * #sortArray, -1 do
		local index = result[sortArray[i]]
		table.insert(candicates, items[index])
	end
	return candicates
end


--function module.head_fuzzy_match(items, pattern)
--	if items == nil or #items == 0 then
--		return {}
--	end
--
--	if pattern:len() == 0 then
--		return items
--	end
--
--	local lp = string.lower(pattern)
--
--	local result = {}
--	local sortArray = {}
--	for i, v in pairs(items) do
--		local lw = string.lower(v['word'])
--		local pir = _is_head_match(lw, lp)
--		if  pir ~= 0 then
--			local j = i
--			local c = 0
--			while(result[pir] ~= nil) do
--				vim.api.nvim_out_write("result[" .. pir .."] " .. result[pir])
--				local p = result[pir]
--				if items[j]['word'] > items[p]['word'] then
--					result[pir] = j
--					j = p
--				end
--				pir = pir + 1
--				c = c + 1
--				vim.api.nvim_out_write(' count '..c .. '\n')
--				os.execute("sleep 0.5")
--			end
--			result[pir] = j
--			table.insert(sortArray, pir)
--		end
--	end
--	print("sort finish")
--	table.sort(sortArray)
--	local candicates = {}
--	for i, v in ipairs(sortArray) do
--		local index = result[v]
--		table.insert(candicates, items[index])
--	end
--	return candicates
--end

return module
