--------------------------------------------------
--    LICENSE: 
--     Author: 
--    Version: 
-- CreateTime: 2018-07-22 07:32:25
-- LastUpdate: 2018-07-22 07:32:25
--       Desc: 
--------------------------------------------------

local module = {}

module.debug = function(...)
	if select("#", ...) == 0 then
		return
	end
	local line = string.format(...)
	vim.api.nvim_call_function('nvim_completor#log_debug', {line})
end

return module
