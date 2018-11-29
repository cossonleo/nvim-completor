--------------------------------------------------
--    LICENSE: 
--     Author: 
--    Version: 
-- CreateTime: 2018-11-29 11:07:47
-- LastUpdate: 2018-11-29 11:07:47
--       Desc: 
--------------------------------------------------

local module = {}
local private = {}

module.convert_to_vim_completion = function(word, abbr, menu)
	if word == nil then
		return nil
	end
	if abbr == nil then
		abbr = word
	end
	if menu == nil then
		menu = "key"
	end
	return {word = word, abbr = abbr, menu = menu, icase = 1, dup = 0}
end

return module
