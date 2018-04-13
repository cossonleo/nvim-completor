--------------------------------------------------
--    LICENSE: MIT
--     Author: Cosson2017
--    Version: 0.1
-- CreateTime: 2018-04-05 14:12:31
-- LastUpdate: 2018-04-05 14:12:31
--       Desc: 
--------------------------------------------------
--
local api = require("api")
local trigger = require("trigger")

local module = {}

module.context = {
	bname = "",
	bno = 0,
	line = 0,
	filetype = "",
	typed = "",
	trigger_pos = 0,
}

function module.context:new(ctx)
	if ctx == nil then
		ctx = {}
		ctx.bname = ""
		ctx.bno = 0
		ctx.line = 0
		ctx.filetype = ""
		ctx.typed = ""
		ctx.trigger_pos = 0
	end

	setmetatable(ctx, self)
	self.__index = self
	return ctx
end

function module.context:eq(ctx)
	if self.bname ~= ctx.bname then
		return false
	end
	if self.bno ~= ctx.bno then 
		return false
	end
	if self.line ~= ctx.line then
		return false
	end
	if self.filetype ~= ctx.filetype then
		return false
	end
	if self.trigger_pos == 0 or ctx.trigger_pos == 0 or self.trigger_pos ~= ctx.trigger_pos then
		return false
	end

	if self.typed:sub(1, self.trigger_pos) ~= ctx.typed:sub(1, ctx.trigger_pos) then
		return false
	end

	return true
end

function module.get_context()
	local pos = api.get_curpos()
	local cur_ctx = module.context:new()
	cur_ctx.bname = api.get_bufname()
	cur_ctx.bno = pos.buf
	cur_ctx.line = pos.line
	cur_ctx.filetype = trigger.filetype
	cur_ctx.typed = vim.api.nvim_get_current_line():sub(1, pos.col - 1)
	cur_ctx.trigger_pos = trigger.trigger_pos(cur_ctx.typed)
	return cur_ctx
end

return module
