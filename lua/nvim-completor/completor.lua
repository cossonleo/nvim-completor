--------------------------------------------------
--    LICENSE: MIT
--     Author: Cosson2017
--    Version: 0.3
-- CreateTime: 2019-03-11 11:10:38
-- LastUpdate: 2019-03-11 11:10:38
--       Desc: out interface
--------------------------------------------------

local complete_src = require("nvim-completor/src-manager")
local lsp = require("nvim-completor/lsp")
local context = require("nvim-completor/context")
local fuzzy = require("nvim-completor/fuzzy-match")
local log = require("nvim-completor/log")

local module = {}

local complete_engine = {
	ctx = nil,
	complete_items = nil,
	incomplete = nil,
}

function complete_engine:reset()
	self.ctx = nil
	self.complete_items = nil
	self.incomplete = nil
end

function complete_engine:text_changed(ctx)
	if not complete_src:has_complete_src() then
		return
	end

	if not ctx:can_fire_complete() then
		return
	end

	local offset = ctx:offset_typed(self.ctx)
	if (offset and not self.incomplete) or vim.deep_equal(ctx, self.ctx) then
		complete_engine:refresh_complete(ctx)
		return
	end

	if not offset then
		self:reset()
		self.ctx = ctx
	end
	log.debug("call src")
	complete_src:call_src(ctx)
end

function complete_engine:add_complete_items(ctx, items, incomplete)
	if not items or #items == 0 then
		return
	end

	local offset = ctx:offset_typed(self.ctx)
	if not vim.deep_equal(self.ctx, ctx) and not offset then
		return
	end

	if offset then
		self:convert_items_to_self_ctx(items, offset)
	end

	self.incomplete = incomplete

	if self.complete_items == nil then
		self.complete_items = {}
	end

	for _, v in pairs(items) do
		table.insert(self.complete_items, v)
	end

	self:refresh_complete()
	return
end

function complete_engine:refresh_complete(ctx)
	local cur_ctx = ctx or context:new()
	local offset = cur_ctx:offset_typed(self.ctx)
	local matches = {}
	if offset then
		matches = fuzzy.filter_completion_items(offset, self.complete_items)
	elseif vim.deep_equal(cur_ctx, self.ctx) then
		matches = self.complete_items
	else
		self:reset()
		return
	end

	local mode = vim.api.nvim_get_mode().mode
	if mode == "i" or mode == "ic" or mode == "ix" then
		vim.fn.complete(self.ctx.pos.position.character+1, matches)
	end
end

-- 由于self.ctx 与 ctx的col可能不一样
-- 则需要将新增item转换成当前ctx, 以达到显示正确
function complete_engine:convert_items_to_self_ctx(items, offset)
	for _, item in pairs(items) do
		item.word = offset .. item.word
	end
end


return {
	reset = function() complete_engine:reset() end,
	text_changed = function(ctx) complete_engine:text_changed(ctx) end,
	add_complete_items = function(ctx, items, incomplete) complete_engine:add_complete_items(ctx, items, incomplete) end,
}

