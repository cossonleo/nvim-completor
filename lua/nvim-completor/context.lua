--------------------------------------------------
--    LICENSE: 
--     Author: 
--    Version: 
-- CreateTime: 2020-03-08 16:56:35
-- LastUpdate: 2020-03-08 16:56:35
--       Desc: 
--------------------------------------------------

local semantics = require("nvim-completor/semantics")
local api = vim.api

-- position_param = {}
local context = {
	pos = {},
	typed = "",
}

-- self > ctx
-- self 相对 ctx的偏移输入
-- 若不是偏移输入则返回nil
function context:offset_typed(ctx)
	if not (self and ctx) then
		return nil
	end
	if self.pos.textDocument.uri ~= ctx.pos.textDocument.uri then
		return nil
	end
	if self.pos.position.line ~= ctx.pos.position.line then
		return nil
	end
	if ctx.pos.position.character >= self.pos.position.character then
		return nil
	end
	local front_typed = ctx:typed_to_cursor()
	if not vim.startswith(self.typed, front_typed) then
		return nil
	end
	local offset_typed = self.typed:sub(ctx.pos.position.character + 1, self.pos.position.character)
	local check = offset_typed:match('[%w_]+')
	if check and offset_typed == check then
		return check
	end
	return nil
end

function context:typed_to_cursor()
	return self.typed:sub(1, self.pos.position.character)
end

function context:can_fire_complete()
	local typed = self.typed:sub(1, self.pos.position.character)
	return semantics.is_fire_complete(typed)
end

function context:new()
	local ctx = {}
	ctx.typed = api.nvim_get_current_line()
	ctx.pos = vim.lsp.util.make_position_params()
	setmetatable(ctx, {__index = self})
	return ctx
end

return context
