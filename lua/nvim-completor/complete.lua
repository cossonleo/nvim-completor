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

-- 上一次触发补全的上下文
private.ctx = nil
-- 补全引擎
private.complete_engines = {}
-- incomplete
private.incomplete = false

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
		return
	end

	for i, v in pairs(fts) do
		if type(v) == "string" then
			if private.complete_engines[v] == nil then
				private.complete_engines[v] = {}
				table.insert(private.complete_engines[v], handle)
			end
		end
	end

	log.debug("new engine add")
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
	log.debug("text changed")
	if private.complete_engines == nil or #private.complete_engines == 0 then
		log.debug("text_changed: complete engines is nil")
		return
	end

	--if lang.get_ft() == nil then
	--	log.debug("text_changed: file type is nil")
	--	return
	--end

	local ctx = context.get_cur_ctx()
	if ctx == nil then -- 终止补全
		log.debug("text_changed: ctx is nil")
		private.ctx = nil
		private.incomplete = false
		return
	end

	if context.ctx_is_equal(ctx, private.ctx) == false then
		private.incomplete = false
		private.ctx = ctx
	elseif private.incomplete then
		private.ctx.col = private.ctx.end_pos
	else
		module.text_changedp()
		return
	end

	-- 补全
	for i, handle in ipairs(private.complete_engines) do
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
		for i, handle in pairs(handles) do
			handle(private.ctx)
		end
	end
end

-- triggered when popmenu is show
module.text_changedp = function()
	log.debug("text changedp")
	cm.select_candidate()
end

return module
