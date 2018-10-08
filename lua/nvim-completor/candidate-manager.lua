--------------------------------------------------
--    LICENSE: 
--     Author: 
--    Version: 
-- CreateTime: 2018-07-21 07:39:54
-- LastUpdate: 2018-07-21 07:39:54
--       Desc: 
--------------------------------------------------

local module = {}
local private = {}

local p_context = require("nvim-completor/context")
local p_helper = require("nvim-completor/helper")
local log = require("nvim-completor/log")
local fuzzy = require("nvim-completor/fuzzy-match")

private.ctx = nil -- 当前上下文环境
private.candidate = {} -- 当前候选
private.candidate_cache = {} -- 模糊匹配时，缩小匹配范围
private.last_pattern = nil

-- 重置状态
module.reset = function()
	private.ctx = nil -- 当前上下文环境
	private.candidate = {} -- 当前候选
	private.candidate_cache = {} -- 模糊匹配时，缩小匹配范围
	private.last_pattern = nil
end

private.print_t = function(t)
	local str = ""
	for _, data in ipairs(t) do
		str = str .. data.word .. ","
	end
	return str
end

-- 触发或更新补全选项
private.trigger_complete = function(is_changedp)
	--local str = p_helper.get_cur_line(private.ctx.replace_col)
	--local pattern = string.match(str, "[%a_][%w_]*$")
	local pattern = p_helper.get_cur_line(private.ctx.replace_col)

	if is_changedp and pattern ~= nil and private.last_pattern ~= nil and pattern == private.last_pattern then
		return
	end

	--log.debug("origin candi: %s", private.print_t(private.candidate))
	--if pattern == nil or private.last_pattern == nil or string.match(pattern, "^" .. private.last_pattern) == nil then
	if pattern == nil or private.last_pattern == nil or p_helper.has_prefix(pattern, private.last_pattern) == nil then
		private.candidate_cache = private.candidate
	end
	if #private.candidate_cache == 0 then
		return
	end

	if pattern ~= nil then
		private.candidate_cache = fuzzy.filter_completion_items(pattern, private.candidate_cache)
	end
	private.last_pattern = pattern

	if private.candidate_cache == nil or #private.candidate_cache == 0 then
		return
	end
	p_helper.complete(private.ctx.replace_col, private.candidate_cache)
end

-- 新的候选
module.add_candidate = function(ctx, candi)
	if ctx == nil then
		return
	end

	if p_context.ctx_is_equal(ctx, private.ctx) == false then
		private.ctx = ctx
		private.candidate = candi
	else
		for _, v in pairs(candi) do
			table.insert(private.candidate, v)
		end
	end

	private.candidate_cache = private.candidate
	private.trigger_complete(false)
end

module.rematch_cdandidate = function(ctx)
	if not p_context.ctx_is_equal(private.ctx, ctx) then
		return
	end

	private.trigger_complete(true)
end

return module
