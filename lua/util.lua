--------------------------------------------------
--    LICENSE: MIT
--     Author: Cosson2017
--    Version: 0.1
-- CreateTime: 2018-03-04 21:13:44
-- LastUpdate: 2018-03-06 11:51:13
--       Desc: 
--------------------------------------------------

local util = {}

-- 判断字符是不是key字符
local function is_word_char(char)
	--if string.match(char, '[a-zA-Z0-9_]+') == char then
	if string.match(char, '[%w_]+') == char then
		return true
	end
	return false
end

local function _last_word_start(str)
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

-- 最后一个key开始的位置
util.last_word_start = _last_word_start

return util
