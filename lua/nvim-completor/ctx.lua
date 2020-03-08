--------------------------------------------------
--    LICENSE: 
--     Author: 
--    Version: 
-- CreateTime: 2020-03-08 16:56:35
-- LastUpdate: 2020-03-08 16:56:35
--       Desc: 
--------------------------------------------------

local api = vim.api

local context = {
	col = 0,
	line = 0,
	bname = "",
	bno = "",
	incomplete = false,
	typed = "",
}

function context:offset_typed(ctx)
	if not (self and ctx) then
		return nil
	end

	if self.bname ~= ctx.bname then
		return nil
	end

	if self.bno ~= ctx.bno then
		return nil
	end

	if self.line ~= ctx.line then
		return nil
	end

	if self.col > ctx.col then
		return nil
	end

	local typed1 = self.typed:sub(1, self.col)
	local typed2 = ctx.typed:sub(1, self.col)
	if typed1 ~= typed2 then
		return nil
	end
	if self.col == ctx.col then
		return ""
	end

	local typed3 = ctx.typed:sub(self.col + 1, ctx.col)
	if not p_helper.is_word(typed3) then
		return nil
	end
	return typed3
end

-- self: origin, ctx: offset_ctx
function context:is_offset_ctx(ctx)
	if self.incomplete == true then
		return false
	end

	local offset_typed = self:offset_typed(ctx)
	if offset_typed == nil or #offset_typed == 0 then
		return false
	end

	return true
end

function context:eq(ctx)
	if self.bname ~= ctx.bname then
		return false
	end

	if self.bno ~= ctx.bno then
		return false
	end

	if self.line ~= ctx.line then
		return false
	end

	if self.col ~= ctx.col then
		return false
	end

	if self.typed ~= ctx.typed then
		return false
	end

	return true
end

function context:new()
	--local typed = vim.api.nvim_get_current_line()
	local typed = api.nvim_get_current_line()
	if not (typed and #typed == 0) then
		return nil
	end
	local pos = p_helper.get_curpos()
	if pos.col < 2 then
		return nil
	end

	local last_char_pos = pos.col - 1

	local front_typed = typed:sub(1, last_char_pos)
	if p_state.is_fire_complete(front_typed) == false then
		return nil
	end

	local ctx = {}
	ctx.bname = p_helper.get_bufname()
	ctx.bno = pos.buf
	ctx.line = pos.line
	ctx.col = last_char_pos
	ctx.typed = typed
	ctx.incomplete = false
	setmetatable(ctx, {__index = self})

	return ctx
end
