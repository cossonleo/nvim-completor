--------------------------------------------------
--    LICENSE: MIT
--     Author: Cosson2017
--    Version: 0.3
-- CreateTime: 2019-03-06 11:22:55
-- LastUpdate: 2019-03-06 11:22:55
--       Desc: core of complete framework
--------------------------------------------------

local p_helper = require("nvim-completor/helper")
local p_state = require("nvim-completor/semantics")
local fuzzy = require("nvim-completor/fuzzy-match")

local complete_src = {
	public = {},
	kindless = {},
}

function complete_src:add_src(handle, kind)
	if kind == nil or kind == "" then
		table.insert(self.kindless, handle)
		return
	end

	if kind == "public" then
		table.insert(self.public, handle)
		return
	end

	if self[kind] == nil then
		self[kind] = {}
	end
	table.insert(self[kind], handle)
end

function complete_src:has_complete_src()
	local cur_ft = p_state.get_ft()
	if cur_ft == nil or cur_ft == "" then
		if #self.kindless > 0 then
			return true
		end
		return false
	end

	if #self.public > 0 then
		return true
	end

	if self[cur_ft] ~= nil and #self[cur_ft] > 0 then
		return true
	end

	return false
end

function complete_src:call_src(ctx)
	local cur_ft = p_state.get_ft()
	if cur_ft == nil or cur_ft == "" then
		for _, handle in pairs(self.kindless) do
			handle(ctx)
		end
		return
	end

	for  _, handle in pairs(self.public) do
		handle(ctx)
	end

	local handles = self[cur_ft]
	if handles ~= nil then
		for _, handle in pairs(handles) do
			handle(ctx)
		end
	end

end

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
	local typed = vim.api.nvim_eval("getline('.')")
	if typed == nil or string.len(typed) == 0 then
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


local complete_engine = {
	ctx = nil,
	complete_items = nil,
	matches = nil,
}

function complete_engine:reset()
	self.ctx = nil
	self.complete_items = nil
	self.matches = nil
end

function complete_engine:text_changed()
	if not complete_src:has_complete_src() then
		return
	end

	local ctx = context:new()
	if ctx == nil then -- 终止补全
		self:reset()
		return
	end

	if self.ctx ~= nil and not self.ctx.incomplete then
		local offset_typed = self.ctx:offset_typed(ctx)
		if offset_typed == "" then
			return
		end

		if offset_typed ~= nil then
			self:refresh_matches(offset_typed)
			return
		end
	end

	self:reset()
	self.ctx = ctx
	complete_src:call_src(ctx)
end

function complete_engine:add_complete_items(ctx, items)
	if not (self.ctx and ctx and items and #items == 0) then
		return
	end
	

	if not self.ctx:eq(ctx) then
		return
	end

	self.ctx.incomplete = ctx.incomplete

	if self.complete_items == nil then
		self.complete_items = {}
	end

	for _, v in pairs(items) do
		table.insert(self.complete_items, v)
	end

	self:init_matches()
	return
end

function complete_engine:init_matches()
	if self.complete_items == nil or #self.complete_items == 0 then
		return
	end

	local cur_ctx = context:new()
	if cur_ctx == nil then
		return
	end

	local offset_type = self.ctx:offset_typed(cur_ctx)
	if offset_type == nil then
		return
	end

	if self.matches == nil then
		self.matches = {}
	end
	self.matches.pre_offset = offset_type

	local add_matches = fuzzy.filter_completion_items(offset_type, self.complete_items)
	self.matches.items = add_matches
	self:call_vim_complete()
	return
end


function complete_engine:refresh_matches(offset)
	local matches = self.complete_items
	if self.matches ~= nil and self.matches.pre_offset ~= nil  and #self.matches.pre_offset > 0 then
		if  p_helper.has_prefix(offset, self.matches.pre_offset) then
			matches = self.matches.items
		end
	end

	if self.matches == nil then
		self.matches = {}
	end
	self.matches.pre_offset = offset
	if matches == nil or #matches == 0 then
		return
	end

	local add_matches = fuzzy.filter_completion_items(self.matches.pre_offset, self.complete_items)
	self.matches.items = add_matches
	self:call_vim_complete()
end


function complete_engine:call_vim_complete()
	if self.matches.items == nil or #self.matches.items == 0 then
		return
	end
	p_helper.complete(self.ctx.col + 1, self.matches.items)
end


return {
	reset = function() complete_engine:reset() end,
	text_changed = function() complete_engine:text_changed() end,
	add_complete_items = function(ctx, items) complete_engine:add_complete_items(ctx, items) end,
	add_src = function(handle, src_kind) complete_src:add_src(handle, src_kind) end,
}
