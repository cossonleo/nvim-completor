--------------------------------------------------
--    LICENSE: MIT
--     Author: Cosson2017
--    Version: 0.3
-- CreateTime: 2019-03-06 11:22:55
-- LastUpdate: 2019-03-06 11:22:55
--       Desc: core of complete framework
--------------------------------------------------

local helper = require("nvim-completor/helper")
local lang = require("nvim-completor/lang-spec")
local log = require("nvim-completor/log")

local context = {
	col = 0,
	line = 0,
	bname = "",
	bno = "",
	incomplete = false,
	typed = "",
}

function context:eq(ctx)
	if self.incomplete == true then
		return false
	end

	if self.bname ~= ctx.bname then
		return false
	end

	if self.bno ~= ctx.bno then
		return false
	end

	if self.line ~= ctx.line then
		return false
	end

	if self.col > ctx.col then
		return false
	end

	if self.col == ctx.col and self.typed == ctx.typed then
		return true
	end

	local typed1 = self.typed:sub(1, self.col)
	local typed2 = ctx.typed:sub(1, self.col)
	if typed1 ~= typed2 then
		return false
	end

	local typed3 = ctx.typed:sub(self.col + 1, ctx.col)
	return helper.is_word(typed3)
end

-- 不做任何检查
function context:typed_changes(ctx)
	return ctx.typed:sub(self.col, ctx.col - 1)
end

function context:new()
	local typed = vim.api.nvim_get_current_line()
	if typed == nil or string.len(typed) == 0 then
		return nil
	end

	local pos = helper.get_curpos()
	if pos.col <= 1 then
		return nil
	end

	local front_typed = typed:sub(1, pos.col - 1)
	if lang.is_fire_complete(front_typed) == false then
		return nil
	end

	local ctx = {}
	setmetatable(ctx, {__index = self})
	ctx.bname = helper.get_bufname()
	ctx.bno = pos.buf
	ctx.line = pos.line
	ctx.col = pos.col
	ctx.typed = typed
	ctx.incomplete = false

	return ctx
end


local complete_engine = {
	src = nil,
	ctx = nil,
	complete_items = nil,
	matches = nil,
}

function complete_engine:reset()
	self.ctx = nil
	self.complete_items = nil
	self.matches = nil
end

function complete_engine:add_src(handle, ...)
	if handle == nil then
		return
	end

	if type(handle) ~= "function" then
		return
	end

	if self.src == nil then
		self.src = {}
	end
	local fts = { ... }
	if #fts == 0 then
		if self.src["common"] == nil then
			self.src["common"] = {}
		end
		table.insert(self.src["common"], handle)
		log.debug("new engine for common is add")
		return
	end

	if fts[1] == "all" then
		-- 去重
		for i, v in pairs(self.src) do
			if type(i) == "number" then
				if handle == v then
					return
				end
			else
				local handles = self.src[i]
				if handles ~= nil and #handles > 0 then
					for j, h in pairs(handles) do
						if h == handle then
							-- 去重
							table.remove(handles, j)
						end
					end
				end
			end
		end
		table.insert(self.src, handle)
		log.debug("new engine for all is add")
		return
	end

	for _, v in pairs(fts) do
		if type(v) == "string" then
			if self.src[v] == nil then
				self.src[v] = {}
			end
			if #self.src[v] > 0 then
				for j, h in pairs(self.src[v]) do
					if h == handle then
						table.remove(self.src, j)
					end
				end
			end
			table.insert(self.src[v], handle)
		end
	end

	log.debug("new engine for %s is add", helper.table_to_string(fts))
end

function complete_engine:text_changed()
	if self.src == nil or #self.src == 0 then
		log.debug("text_changed: complete engines is nil")
		return
	end

	local ctx = context.new()
	if ctx == nil then -- 终止补全
		log.debug("text_changed: ctx is nil")
		self.reset()
		return
	end

	if self.ctx ~= nil and self.ctx:eq(ctx) then
		self.refresh_matches(ctx)
		return
	end

	self.reset()
	self.ctx = ctx
	self:call_src()
end

function complete_engine:call_src()
	local handles = nil
	local cur_ft = lang.get_ft()
	if cur_ft == nil then
		handles = self.src["common"]
	else
		handles = self.src[cur_ft]
		if handles == nil or #handles == 0 then
			handles = self.src["common"]
		end
	end

	if handles ~= nil and #handles > 0 then
		for _, handle in pairs(handles) do
			handle(self.ctx)
		end
	end
end


function complete_engine:refresh_matches(ctx)
end
