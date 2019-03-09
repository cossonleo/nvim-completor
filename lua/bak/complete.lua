--------------------------------------------------
--    LICENSE: MIT
--     Author: Cosson2017
--    Version: 0.2
-- CreateTime: 2018-03-04 22:53:58
-- LastUpdate: 2018-03-19 13:10:38
--       Desc: 
--------------------------------------------------

local module = {}
local private = {}

local lang = require("nvim-completor/lang-spec")
local context = require("nvim-completor/context")
local cm = require("nvim-completor/candidate-manager")
local log = require("nvim-completor/log")
local helper = require("nvim-completor/helper")

-- 上一次触发补全的上下文
private.ctx = nil
-- 补全引擎
private.complete_engines = {}
-- incomplete
private.incomplete = false

-- 重置状态
private.reset = function()
	private.ctx = nil
	private.incomplete = false
end

-- 添加引擎
module.add_engine = function(handle, ...)
	if handle == nil then
		return
	end

	if type(handle) ~= "function" then
		return
	end

	local fts = { ... }
	if #fts == 0 then
		if private.complete_engines["common"] == nil then
			private.complete_engines["common"] = {}
		end
		table.insert(private.complete_engines["common"], handle)
		log.debug("new engine for common is add")
		return
	end

	if fts[1] == "all" then
		-- 去重
		for i, v in pairs(private.complete_engines) do
			if type(i) == "number" then
				if handle == v then
					return
				end
			else
				local handles = private.complete_engines[i]
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
		table.insert(private.complete_engines, handle)
		log.debug("new engine for all is add")
		return
	end

	for _, v in pairs(fts) do
		if type(v) == "string" then
			if private.complete_engines[v] == nil then
				private.complete_engines[v] = {}
			end
			if #private.complete_engines[v] > 0 then
				for j, h in pairs(private.complete_engines[v]) do
					if h == handle then
						table.remove(private.complete_engines, j)
					end
				end
			end
			table.insert(private.complete_engines[v], handle)
		end
	end

	log.debug("new engine for %s is add", helper.table_to_string(fts))
end

-- 添加补全候选
module.add_candidate = function(ctx, candidates, inc)
	if inc ~= nil and inc == true then
		private.incomplete = true
	end
	cm.add_candidate(ctx, candidates)
end

-- triggered when popmenu is not show
module.text_changed = function()
	if private.complete_engines == nil or #private.complete_engines == 0 then
		log.debug("text_changed: complete engines is nil")
		cm.reset()
		return
	end

	local ctx = context.get_cur_ctx()
	if ctx == nil then -- 终止补全
		log.debug("text_changed: ctx is nil")
		private.reset()
		cm.reset()
		return
	end

	if private.incomplete then
		private.incomplete = false
		private.ctx = ctx
	elseif context.is_sub_ctx(private.ctx, ctx) then
		cm.rematch_cdandidate(private.ctx)
		return
	else
		private.incomplete = false
		private.ctx = ctx
	end

	cm.reset()
	-- 补全
	for _, handle in ipairs(private.complete_engines) do
		handle(private.ctx)
	end

	local handles = nil
	local cur_ft = lang.get_ft()
	if cur_ft == nil then
		handles = private.complete_engines["common"]
	else
		handles = private.complete_engines[cur_ft]
		if handles == nil or #handles == 0 then
			handles = private.complete_engines["common"]
		end
	end

	if handles ~= nil and #handles > 0 then
		for _, handle in pairs(handles) do
			handle(private.ctx)
		end
	end
end

-- triggered when popmenu is show
module.text_changedp = function()
	log.debug("text changedp")
	cm.rematch_cdandidate(private.ctx)
end

module.leave = function()
	cm.reset()
	private.reset()
end

module.enter = function()
	lang.set_ft()
	module.text_changed()
end

return module
