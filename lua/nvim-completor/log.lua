--------------------------------------------------
--    LICENSE: MIT
--     Author: Cosson2017
--    Version: 0.3
-- CreateTime: 2018-07-22 07:32:25
-- LastUpdate: 2018-07-22 07:32:25
--       Desc: log
--------------------------------------------------

local module = {}

module.to_string = function(...)
	if select('#', ...) == 0 then
		return ""
	end

	local params = { ... }
	local str = ""
	for _, param in pairs(params) do
		str = str .. vim.api.nvim_call_function("string", {param}) .. " "
	end
	return str
end

module.debug = function(...)
	if select("#", ...) == 0 then
		return
	end

	local line = module.to_string(...)
	vim.api.nvim_call_function('nvim_log#log_debug', {line})
end

module.warn = function(...)
	if select("#", ...) == 0 then
		return
	end
	local line = module.to_string(...)
	vim.api.nvim_call_function('nvim_log#log_warn', {line})
end

module.error = function(...)
	if select("#", ...) == 0 then
		return
	end
	local line = module.to_string(...)
	vim.api.nvim_call_function('nvim_log#log_error', {line})
end

module.info = function(...)
	if select("#", ...) == 0 then
		return
	end
	local line = module.to_string(...)
	vim.api.nvim_call_function('nvim_log#log_info', {line})
end

return module
