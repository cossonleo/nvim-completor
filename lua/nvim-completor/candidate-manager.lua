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

private.ctx = nil -- 当前上下文环境
private.candidate = {} -- 当前候选
private.candidate_cache = {} -- 模糊匹配时，缩小匹配范围
private.last_pattern = nil

-- 触发或更新补全选项
private.match_complete = function()
	local str = p_helper.get_cur_line(private.ctx.replace_col)
	log.debug("str: %s", str)

	local pattern = string.match(str, "[%a_][%w_]*$")

	if pattern == nil or private.last_pattern == nil or string.match(pattern, "^" .. private.last_pattern) == nil then
		private.candidate_cache = private.candidate
	end

	if pattern ~= nil then
		private.candidate_cache = p_helper.head_fuzzy_match(private.candidate_cache, pattern)
	end
	private.last_pattern = pattern

	if private.candidate_cache == nil or #private.candidate_cache == 0 then
		return
	end
	p_helper.complete(private.ctx.replace_col, private.candidate_cache)
end

-- 新的候选
module.add_candidate = function(ctx, candi)
	if ctx == nil or candi == nil or #candi == 0 then
		return
	end

	if p_context.ctx_is_equal(ctx, private.ctx) == false then
		private.ctx = ctx
		private.candidate = candi
	else
		for i, v in pairs(candi) do
			table.insert(private.candidate, v)
		end
	end

	private.candidate_cache = private.candidate
	private.match_complete()
end


module.select_candidate = function()
	if private.ctx == nil then
		return
	end

	private.match_complete()
end

return module
