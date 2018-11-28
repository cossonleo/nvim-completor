--------------------------------------------------
--    LICENSE: MIT
--     Author: Cosson2017
--    Version: 0.2
-- CreateTime: 2018-04-05 14:12:31
-- LastUpdate: 2018-04-05 14:12:31
--       Desc: 
--------------------------------------------------
--
local helper = require("nvim-completor/helper")
local lang = require("nvim-completor/lang-spec")
local log = require("nvim-completor/log")

local module = {}
local private = {}

-- 获取当前上下文 不触发补全的返回nil
module.get_cur_ctx = function()
	local pos = helper.get_curpos()
	if pos.col <= 1 then
		return nil
	end

	--local typed = vim.api.nvim_get_current_line():sub(1, pos.col - 1)
	--local fire_pos, replace_start = lang.trigger_pos(typed)
	--if fire_pos == nil or replace_start == nil then
	--	return nil
	--end

	local cur_ctx = {}
	cur_ctx.bname = helper.get_bufname()
	cur_ctx.bno = pos.buf
	cur_ctx.line = pos.line
	cur_ctx.col = pos.col - 1
	--cur_ctx.col = fire_pos -- 触发补全开始位置
	--cur_ctx.replace_col = replace_start -- 候选开始位置
	--cur_ctx.end_pos = pos.col - 1 -- 当前光标前一个位置
	
	local fire = false
	if lang.gener_complete_start(cur_ctx.col) > 1 then
		fire = true
	end
	
	if fire == false then 
		return nil
	end

	return cur_ctx
end

module.is_sub_ctx = function(src_ctx, sub_ctx)
	if src_ctx == nil or sub_ctx == nil then
		return false
	end

	if src_ctx.bname ~= sub_ctx.bname then
		return false
	end

	if src_ctx.bno ~= sub_ctx.bno then
		return false
	end

	if src_ctx.line ~= sub_ctx.line then
		return false
	end

	if src_ctx.col > sub_ctx.col then
		return false
	end
	
	local line = helper.get_cur_line(src_ctx.col, sub_ctx.col + 1)
	return helper.is_word(line)
end

-- 上下文是否相等
module.ctx_is_equal = function(ctx1, ctx2)
	if ctx1 == nil or ctx2 == nil then
		return false
	end
	if ctx1.bname ~= ctx2.bname then
		return false
	end
	if ctx1.bno ~= ctx2.bno then 
		return false
	end
	if ctx1.line ~= ctx2.line then
		return false
	end
	if ctx1.col ~= ctx2.col then
		return false
	end
	return true
end

return module
