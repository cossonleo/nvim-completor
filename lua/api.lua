--------------------------------------------------
--    LICENSE: MIT
--     Author: Cosson2017
--    Version: 0.1
-- CreateTime: 2018-03-06 11:38:17
-- LastUpdate: 2018-03-06 11:38:17
--       Desc: 
--------------------------------------------------

-- module name
local api = {}



-- row: 都是从1开始
-- getcurpos: col 从1开始 符合lua的下标
-- nvim_win_get_cursor: col 从0开始 
function api.get_curpos()
	local pos = vim.api.nvim_call_function('getcurpos', {})
	return {buf=pos[1], line=pos[2], col=pos[3]}
end

-- 获取buf的文件类型
function api.get_filetype()
	local pos = api.get_curpos()
	return vim.api.nvim_buf_get_option(pos['buf'], 'filetype')
end

-- 获取buf的全路径文件名
function api.get_bufname()
	--return vim.api.nvim_call_function('buffer_name', {'%'})
	return vim.api.nvim_call_function('expand', {'%:p'})
end

function api.complete(start, items)
	vim.api.nvim_call_function('complete', {start, items})
end

function api.lsp_complete(server_name, ctx)
	vim.api.nvim_call_function('complete#lsp_complete', {server_name, ctx})
end

function api.get_whitelist_servers()
	return vim.api.nvim_call_function('lsp#get_whitelisted_servers', {})
end

return api
