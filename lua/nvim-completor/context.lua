--------------------------------------------------
--    LICENSE: 
--     Author: 
--    Version: 
-- CreateTime: 2020-03-08 16:56:35
-- LastUpdate: 2020-03-08 16:56:35
--       Desc: 
--------------------------------------------------

local snippet = require("nvim-completor/snippet")
local api = require("nvim-completor/api")

local _min_fire_len = 2

local _semantics_fire_pattern = {
	cpp = {"->", "::", "#", "%."},
	c = {"->", "::", "#", "%."},
	rust = {"%.", "::"},
	lua = {"%.", ":"},
	go = {"%."},
	javascript = {"%."},
	php = {"%.", "->"},
	html = {"<"},
}

-- position_param = {}
local context = {
	changedtick = 0,
	buf = 0,
	pos = {},
	typed = "",
	marks = {},
}

-- self > ctx
-- self 相对 ctx的偏移输入
-- 若不是偏移输入则返回nil
function context:offset_typed(ctx)
	if not self or not ctx then return nil end
	if self.buf == 0  or self.buf ~= ctx.buf then
		return nil
	end
	if self.pos[1] ~= ctx.pos[1] then return nil end
	if ctx.pos[2] >= self.pos[2] then return nil end
	local front_typed = ctx:typed_to_cursor()
	if not vim.startswith(self.typed, front_typed) then
		return nil
	end
	local offset_typed = self.typed:sub(ctx.pos[2] + 1, self.pos[2])
	local check = offset_typed:match('[%w_]+')
	if check and offset_typed == check then
		return check
	end
	return nil
end

function context:typed_to_cursor()
	return self.typed:sub(1, self.pos[2])
end

function context:can_fire_complete()
	local ft = vim.bo.filetype
	if ft == "" then
		return false
	end

	local typed = self.typed:sub(1, self.pos[2])
	local suffix = typed:match('[%w_]+$')
	if suffix and #suffix >= _min_fire_len then
		return true
	end

	local trigger_patterns = _semantics_fire_pattern[ft]
	if not trigger_patterns then
		return false
	end

	for _, sub in ipairs(trigger_patterns) do
		local pattern = sub .. "[%w_]*$"
		if typed:match(pattern) then
			return true
		end
	end
	return false
end

function context:restore_ctx()
	snippet.restore_ctx(self)
end

function _new()
	local ctx = {}
	ctx.changedtick = vim.b.changedtick
	ctx.buf = api.cur_buf()
	ctx.typed = api.cur_line()
	ctx.pos = api.cur_pos()
	ctx.marks = snippet.get_curline_marks(ctx.pos[1])
	setmetatable(ctx, {__index = context})
	return ctx
end

return {new = _new}
