--------------------------------------------------
--    LICENSE: MIT
--     Author: Cosson2017
--    Version: 0.1
-- CreateTime: 2018-03-04 21:13:44
-- LastUpdate: 2018-03-04 21:13:44
--       Desc: 
--------------------------------------------------

local util = {}

-- 判断字符是不是key字符
local is_word_char = function(char)
	--if string.match(char, '[a-zA-Z0-9_]+') == char then
	if string.match(char, '[%w_]+') == char then
		return true
	end
	return false
end

-- 最后一个key开始的位置
util.last_word_start = function(str)
	local len = string.len(str)
	for i = -1, -1 * len, -1 do
		if str:sub(i, i) == '.' then
			return len + i + 2
		end

		if is_word_char(str:sub(i,i)) == false then
			return len + i + 2
		end
	end
	return 1
end

-- 字符串模糊匹配
util.head_fuzzy_match = function(str, pattern)
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

return util
