--------------------------------------------------
--    LICENSE: MIT
--     Author: Cosson2017
--    Version: 0.2
-- CreateTime: 2018-04-05 14:12:31
-- LastUpdate: 2018-04-05 14:12:31
--       Desc: 
--------------------------------------------------
--
local api = require("api")
local trigger = require("trigger")

local module = {}

-- 获取当前上下文
local function func_get_cur_ctx()
	local pos = api.get_curpos()
	local cur_ctx = {}
	cur_ctx.bname = api.get_bufname()
	cur_ctx.bno = pos.buf
	cur_ctx.line = pos.line
	cur_ctx.col = pos.col -- 光标所在列
	--cur_ctx.filetype = trigger.filetype
	--cur_ctx.typed = vim.api.nvim_get_current_line():sub(1, pos.col - 1)
	--cur_ctx.trigger_pos = trigger.trigger_pos(cur_ctx.typed)
	return cur_ctx
end

-- 上下文是否相等
local function func_ctx_is_equal(ctx1, ctx2)
	if ctx1.bname ~= ctx2.bname then
		return false
	end
	if ctx1.bno ~= ctx2.bno then 
		return false
	end
	if ctx1.line ~= ctx2.line then
		return false
	end
	if ctx1.col == ctx2.col then
		return true
	end

	local str = ""
	if ctx1.col < ctx2.col then
		str = api.get_cur_line(ctx1.col, ctx2.col)
	else
		str = api.get_cur_line(ctx1.col, ctx2.col)
	end
	--if ctx1.filetype ~= ctx2.filetype then
	--	return false
	--end
	--if ctx1.trigger_pos == 0 or ctx2.trigger_pos == 0 or ctx1.trigger_pos ~= ctx2.trigger_pos then
	--	return false
	--end

	--if ctx1.typed:sub(1, ctx1.trigger_pos) ~= ctx2.typed:sub(1, ctx2.trigger_pos) then
	--	return false
	--end

	return true
end

return module
