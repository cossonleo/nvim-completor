--------------------------------------------------
--    LICENSE: 
--     Author: 
--    Version: 
-- CreateTime: 2018-07-22 07:32:25
-- LastUpdate: 2018-07-22 07:32:25
--       Desc: 
--------------------------------------------------

local module = {}

local function e_debug(...)
	if select("#", ...) == 0 then
		return
	end
	local line = string.format(...)
	vim.api.nvim_call_function('nvim_completor#log_debug', {line})
end

module.debug = e_debug
return module
