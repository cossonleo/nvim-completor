--------------------------------------------------
--    LICENSE: MIT
--     Author: Cosson2017
--    Version: 0.2
-- CreateTime: 2018-03-04 22:53:58
-- LastUpdate: 2018-03-19 13:10:38
--       Desc: 
--------------------------------------------------

local module = {}

local lang = require("nvim-completor/lang-spec")
local context = require("nvim-completor/context")
local cm = require("nvim-completor/candidate-manager")
local log = require("nvim-completor/log")

-- 上一次触发补全的上下文
local l_ctx = nil
-- 补全引擎
local l_complete_engines = {}
-- incomplete
local l_incomplete = nil

--local function _direct_completion()
--	if api.menu_selected() then
--		return
--	end
--	if items == nil or #items.items == 0 then
--		return
--	end
--
--	local pos = api.get_curpos()
--	local typed = ""
--
--	if pos.col > 1 then
--		typed = vim.api.nvim_get_current_line():sub(1, pos.col - 1)
--	end
--
--	local pattern = string.match(typed, "[%a_][%w_]*$")
--
--	if pattern == nil or last_pattern == nil or string.match(pattern, "^" .. last_pattern) == nil then
--		cache = items.items
--	end
--
--	if pattern ~= nil then
--		cache = fuzzy_match(cache, pattern)
--	end
--	last_pattern = pattern
--	api.complete(items.start, cache)
--	return ''
--end

--local function _handle_completion(ctx, data)
--
--	local ctx = context.get_context()
--	if not ctx:eq(last_req_ctx) then
--		last_req_ctx = context.context:new()
--		cache = nil
--		last_pattern = nil
--		items = nil
--		return
--	end
--	cache = items.items
--
--	if items.start == -1 then
--		items.start = string.find(ctx.typed, '[%a_][%w_]*$')
--		if items.start == nil then
--			items.start = ctx.trigger_pos + 1
--		end
--	else
--		items.start = items.start
--	end
--	_direct_completion()
--	--api.complete(items.start, cache)
--	return ''
--end

-- 添加引擎
local function e_add_complete_engine(handle)
	if handle == nil then
		return
	end

	table.insert(l_complete_engines, handle)
	log.debug("new engine add")
end

-- 添加补全候选
local function e_add_candidate(ctx, candidates, inc)
	if inc ~= nil and inc == true then
		l_incomplete.ctx = ctx
	end
	cm.add_candidate(ctx, candidates)
end

local function e_text_changed()
	log.debug("text changed")
	if l_complete_engines == nil or #l_complete_engines == 0 then
		log.debug("1")
		return
	end

	if lang.get_ft() == nil then
		log.debug("2")
		return
	end

	local ctx = context.get_cur_ctx()
	if ctx == nil then -- 终止补全
		log.debug("3")
		l_ctx = nil
		return
	end

	if context.ctx_is_equal(ctx, l_ctx) == true then
		if l_incomplete == nil then
			log.debug("4")
			return
		end

		if context.ctx_is_equl(l_incomplete.ctx, ctx) == false then
			l_incomplete = nil
			log.debug("5")
			return
		end

		l_ctx.col = ctx.end_pos
	else
		l_ctx = ctx
	end

	l_incomplete = nil

	-- 补全
	log.debug("start complete")
	for i, handle in ipairs(l_complete_engines) do
		log.debug("handle %d", i)
		handle(l_ctx)
	end
end

local function e_text_changedp()
	cm.select_candidate()
end

module.text_changed = e_text_changed
module.text_changedp = e_text_changedp
module.add_candidate = e_add_candidate
module.add_engine = e_add_complete_engine

return module
