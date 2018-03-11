--------------------------------------------------
--    LICENSE: MIT
--     Author: Cosson2017
--    Version: 0.1
-- CreateTime: 2018-03-08 18:36:13
-- LastUpdate: 2018-03-08 18:36:28
--       Desc: 
--------------------------------------------------

local fuzzy = {}

-- 是否符合首字母模糊匹配
local function _is_head_match(str, pattern)
	slen = str:len()
	plen = pattern:len()
	if slen < plen then
		return false
	end

	if str:sub(1,1) ~= pattern:sub(1,1) then
		return false
	end

	if plen == 1 then
		return true
	end

	n = 2
	for i = 2, plen, 1 do
		if slen - n < plen - i then 
			return false
		end

		for j = n, slen, 1 do
			n = n + 1
			if str:sub(j,j) == pattern:sub(i, i) then
				break
			end
			if j == slen then
				return false
			end
			if slen - j < plen - i then
				return false
			end
		end
	end
	return true
end

-- @items: table
-- @pattern:
-- return: table
function fuzzy.head_fuzzy_match(items, pattern)
	if items == nil or #items == 0 then
		return {}
	end

	if pattern:len() == 0 then
		return items
	end

	lp = string.lower(pattern)

	local candicates = {}
	for i, v in pairs(items) do
		lw = string.lower(v['word'])
		if  _is_head_match(lw, lp) then
			table.insert(candicates, v)
		end
	end
	return candicates
end

return fuzzy