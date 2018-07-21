--------------------------------------------------
--    LICENSE: MIT
--     Author: Cosson2017
--    Version: 0.2
-- CreateTime: 2018-03-06 11:38:17
-- LastUpdate: 2018-03-18 18:18:01
--       Desc: 
--------------------------------------------------

-- module name
local api = {}

-- 获取当前行内容
-- start：开始列
-- ed：结束列
-- [start, ed)
-- return: str
function api.get_cur_line(start, ed)
	-- nvim_get_current_buf()
	-- nvim_get_current_line()
	-- nvim_buf_get_lines({buffer}, {start}, {end}, {strict_indexing})
	local ctn = vim.api.nvim_get_current_line()
	local str = string.sub(ctx, start, ed - 1)
	return str
end

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
    vim.api.nvim_call_function('lsp_completor#on_complete', {start, items})
end

function api.lsp_complete(server_name, ctx)
	vim.api.nvim_call_function('lsp_completor#lsp_complete', {server_name, ctx})
end

function api.get_whitelist_servers()
	return vim.api.nvim_call_function('lsp#get_whitelisted_servers', {})
end

local function _dic_len(dict)
	local count = 0
	for k, v in pairs(dict) do
		count = count + 1
	end
	return count
end

function api.menu_selected()
	local sl = vim.api.nvim_call_function('lsp_completor#menu_selected', {})
	if sl == 1 then
		return true
	end
	return false
end

api.dict_len = _dic_len

return api
