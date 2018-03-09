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

local function _completion_start(str)
	local start, ed = string.find(str, "[%a_][%w_]*$")
	if start == nil then
		return #str + 1
	end
end

-- 最后一个key开始的位置
util.completion_start = _completion_start

return util
