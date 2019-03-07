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
	eq = function(pre_ctx, last_ctx)
		if pre_ctx.incomplete == false then
			return false
		end
		if pre_ctx == nil or last_ctx == nil then
			return false
		end

		if pre_ctx.bname ~= last_ctx.bname then
			return false
		end

		if pre_ctx.bno ~= last_ctx.bno then
			return false
		end

		if pre_ctx.line ~= last_ctx.line then
			return false
		end

		if pre_ctx.col > last_ctx.col then
			return false
		end

		local typed1 = pre_ctx.typed:sub(1, pre_ctx.col)
		local typed2 = last_ctx.typed:sub(1, pre_ctx.col)
		if typed1 ~= typed2 then
			return false
		end

		if pre_ctx.col == last_ctx.col then
			return true
		end
		local typed3 = last_ctx.typed:sub(pre_ctx.col + 1, last_ctx.col)
		return helper.is_word(typed3)
	end
	,
	new = function()
		local typed = vim.api.nvim_get_current_line()
		if typed == nil or string.len(typed) == 0 then
			return nil
		end

		local pos = helper.get_curpos()
		if pos.col <= 1 then
			return nil
		end

		local ctx = {}
		ctx.bname = helper.get_bufname()
		ctx.bno = pos.buf
		ctx.line = pos.line
		ctx.col = pos.col - 1
		ctx.typed = typed
		ctx.incomplete = false

		if string:len(ctx.typed) == 0 then
			return nil
		end
		-- TODO 是否出发补全，这里待改
		if lang.fire_complete(ctx.col) == false then
			return nil
		end
		return ctx
	end
}


local complete_engine = {
	ctx = nil,
	src = {},

	add_src = function(handle, ...)
		local this = complete_engine
		if handle == nil then
			return
		end

		if type(handle) ~= "function" then
			return
		end

		local fts = { ... }
		if #fts == 0 then
			if this.src["common"] == nil then
				this.src["common"] = {}
			end
			table.insert(this.src["common"], handle)
			log.debug("new engine for common is add")
			return
		end

		if fts[1] == "all" then
			-- 去重
			for i, v in pairs(this.src) do
				if type(i) == "number" then
					if handle == v then
						return
					end
				else
					local handles = this.src[i]
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
			table.insert(this.src, handle)
			log.debug("new engine for all is add")
			return
		end

		for _, v in pairs(fts) do
			if type(v) == "string" then
				if this.src[v] == nil then
					this.src[v] = {}
				end
				if #this.src[v] > 0 then
					for j, h in pairs(this.src[v]) do
						if h == handle then
							table.remove(this.src, j)
						end
					end
				end
				table.insert(this.src[v], handle)
			end
		end

		log.debug("new engine for %s is add", helper.table_to_string(fts))
	end,

	text_changed = function()
		local this = complete_engine
		if this.src == nil or #this.src == 0 then
			log.debug("text_changed: complete engines is nil")
			cm.reset()
			return
		end

		local ctx = context.new()
		if ctx == nil then -- 终止补全
			log.debug("text_changed: ctx is nil")
			this.reset()
			cm.reset()
			return
		end

		if this.incomplete then
			this.incomplete = false
			this.ctx = ctx
		elseif context.is_sub_ctx(this.ctx, ctx) then
			cm.rematch_cdandidate(this.ctx)
			return
		else
			this.incomplete = false
			this.ctx = ctx
		end

		cm.reset()
		-- 补全
		for _, handle in ipairs(this.src) do
			handle(this.ctx)
		end

		local handles = nil
		local cur_ft = lang.get_ft()
		if cur_ft == nil then
			handles = this.src["common"]
		else
			handles = this.src[cur_ft]
			if handles == nil or #handles == 0 then
				handles = this.src["common"]
			end
		end

		if handles ~= nil and #handles > 0 then
			for _, handle in pairs(handles) do
				handle(this.ctx)
			end
		end
	end
}
