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

api.context = {
	bname = "",
	bno = 0,
	line = 0,
	ft = "",
	typed = "",
	start = 0,
}

function api.context:new(ctx)
	if ctx == nil then
		ctx = {}
		ctx.bname = ""
		ctx.bno = 0
		ctx.line = 0
		ctx.ft = ""
		ctx.typed = ""
		ctx.start = 0
	end

	setmetatable(ctx, self)
	self.__index = self
	return ctx
end

function api.context:eq(ctx)
	if self.bname ~= ctx.bname then
		return false
	end
	if self.bno ~= ctx.bno then 
		return false
	end
	if self.line ~= ctx.line then
		return false
	end
	if self.ft ~= ctx.ft then
		return false
	end
	if self.start ~= ctx.start then
		return false
	end

	local st = self.start
	if self.typed:sub(st, st) ~= ctx.typed:sub(st, st) then
		return false
	end
	return true
end



-- row: 都是从1开始
-- getcurpos: col 从1开始 符合lua的下标
-- nvim_win_get_cursor: col 从0开始 
function api.get_curpos()
	local pos = vim.api.nvim_call_function('getcurpos', {})
	return {buf=pos[1], line=pos[2], col=pos[3]}
end

-- 获取当前行光标之前的内容
function api.cursor_pre_content()
	local pos = api.get_curpos()
	local pe = pos['col']
	if pe > 1 then
		pe = pe -1
	end

	-- return vim.api.nvim_call_function('getline', {'.'}):sub(1, pe)
	return vim.api.nvim_get_current_line():sub(1, pe)
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

function api.echo_log(str)
	local e = "echo '" .. str .. "'"
	vim.api.nvim_command(e)
end

return api
