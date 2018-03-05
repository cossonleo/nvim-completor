--------------------------------------------------
--    LICENSE: 
--     Author: 
--    Version: 
-- CreateTime: 2018-03-04 22:53:58
-- LastUpdate: 2018-03-04 22:53:58
--       Desc: 
--------------------------------------------------

local util = require("util")
local complete = {}

local items = {}
local anypattern = '[%w_]'

complete.fuzzy_match = function(items, pattern)
	if pattern:len() == 0 then
		return items
	end

	local candicates = {}
	for i, v in ipairs(items) do
		if util.head_fuzzy_match(v, pattern) then
			candicates:insert(v)
		end
	end
	return candicates
end

return complete
