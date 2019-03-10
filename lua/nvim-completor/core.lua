--------------------------------------------------
--    LICENSE: MIT
--     Author: Cosson2017
--    Version: 0.3
-- CreateTime: 2019-03-06 11:22:55
-- LastUpdate: 2019-03-06 11:22:55
--       Desc: core of complete framework
--------------------------------------------------

local p_helper = require("nvim-completor/helper")
local p_state = require("nvim-completor/state")
local log = require("nvim-completor/log")
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
	if self == nil or ctx == nil then
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

	if self.col == ctx.col and self.typed == ctx.typed then
		return ""
	end

	local typed1 = self.typed:sub(1, self.col)
	local typed2 = ctx.typed:sub(1, self.col)
	if typed1 ~= typed2 then
		return nil
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

-- 不做任何检查
--function context:typed_changes(ctx)
--	return ctx.typed:sub(self.col, ctx.col - 1)
--end

function context:new()
	local typed = vim.api.nvim_get_current_line()
	if typed == nil or string.len(typed) == 0 then
		return nil
	end

	local pos = p_helper.get_curpos()
	if pos.col <= 1 then
		return nil
	end

	local front_typed = typed:sub(1, pos.col - 1)
	if p_state.is_fire_complete(front_typed) == false then
		return nil
	end

	local ctx = {}
	setmetatable(ctx, {__index = self})
	ctx.bname = p_helper.get_bufname()
	ctx.bno = pos.buf
	ctx.line = pos.line
	ctx.col = pos.col
	ctx.typed = typed
	ctx.incomplete = false

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

function complete_engine:add_src(handle, src_kind)
	if handle == nil then
		return
	end

	if type(handle) ~= "function" then
		return
	end

	if self.src == nil then
		self.src = {}
	end

	if src_kind == nil or #src_kind == 0 then
		if self.src["common"] == nil then
			self.src["common"] = {}
		end
		table.insert(self.src["common"], handle)
		log.debug("new engine for common is add")
		return
	end

	if self.src[src_kind] == nil then
		self.src[src_kind] = {}
	end

	table.insert(self.src[src_kind], handle)

	--log.debug("new engine for %s is add", p_helper.table_to_string(fts))

	--if fts[1] == "all" then
	--	-- 去重
	--	for i, v in pairs(self.src) do
	--		if type(i) == "number" then
	--			if handle == v then
	--				return
	--			end
	--		else
	--			local handles = self.src[i]
	--			if handles ~= nil and #handles > 0 then
	--				for j, h in pairs(handles) do
	--					if h == handle then
	--						-- 去重
	--						table.remove(handles, j)
	--					end
	--				end
	--			end
	--		end
	--	end
	--	table.insert(self.src, handle)
	--	log.debug("new engine for all is add")
	--	return
	--end

	--for _, v in pairs(fts) do
	--	if type(v) == "string" then
	--		if self.src[v] == nil then
	--			self.src[v] = {}
	--		end
	--		if #self.src[v] > 0 then
	--			for j, h in pairs(self.src[v]) do
	--				if h == handle then
	--					table.remove(self.src, j)
	--				end
	--			end
	--		end
	--		table.insert(self.src[v], handle)
	--	end
	--end

	-- log.debug("new engine for %s is add", p_helper.table_to_string(fts))
end

function complete_engine:text_changed()
	if not complete_src:has_complete_src() then
		log.debug("text_changed: no complete src")
		return
	end

	local ctx = context:new()
	if ctx == nil then -- 终止补全
		log.debug("text_changed: ctx is nil")
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
	if ctx == nil or items == nil or #items == 0 then
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
	log.debug(self.matches.items)
	p_helper.complete(self.ctx.col, self.matches.items)
end

local module = {}

module.text_changed = function()
	complete_engine:text_changed()
end

module.leave = function()
	complete_engine:reset()
end

module.enter = function()
	p_state.set_ft()
	module.text_changed()
end

module.complete_done = function(ud)
	local user_data = p_helper.json_decode(ud)
	if user_data == nil then
		return
	end
	if user_data.line == nil then
		return
	end
	local bno = user_data.bno
	local line = user_data.line
	local content = user_data.content
	local col = user_data.col

	vim.api.nvim_buf_set_lines(bno, line, line + 1, false, {content})
end

module.add_complete_items = function(ctx, items)
	complete_engine:add_complete_items(ctx, items)
end

module.add_engine = function(handle, src_kind)
	complete_src:add_src(handle, src_kind)
end

return module
