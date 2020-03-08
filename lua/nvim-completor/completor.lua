--------------------------------------------------
--    LICENSE: MIT
--     Author: Cosson2017
--    Version: 0.3
-- CreateTime: 2019-03-11 11:10:38
-- LastUpdate: 2019-03-11 11:10:38
--       Desc: out interface
--------------------------------------------------

local core = require("nvim-completor/core")
local lsp = require("nvim-completor/lsp")
local state = require("nvim-completor/semantics")

local module = {}

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

-- module.leave = function()
-- 	core.reset()
-- end
-- 
-- module.enter = function()
-- 	state.set_ft()
-- 	core.text_changed()
-- end
-- 
-- module.text_changed = function()
-- 	core.text_changed()
-- end
-- 
-- module.complete_done = function(user_data)
-- 	log.debug("complete done", user_data)
-- 	lsp.apply_complete_user_data(user_data)
-- end
-- 
-- module.add_complete_items = function(ctx, items)
-- 	core.add_complete_items(ctx, items)
-- end
-- 
-- module.add_engine = function(handle, src_kind)
-- 	core.add_src(handle, src_kind)
-- end

-- return module
