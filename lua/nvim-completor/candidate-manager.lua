--------------------------------------------------
--    LICENSE: 
--     Author: 
--    Version: 
-- CreateTime: 2018-07-21 07:39:54
-- LastUpdate: 2018-07-21 07:39:54
--       Desc: 
--------------------------------------------------

local module = {}

local p_context = require("nvim-completor/context")
local p_helper = require("nvim-completor/helper")
local log = require("nvim-completor/log")

local l_ctx = nil -- 当前上下文环境
local l_candidate = nil -- 当前候选
local l_cadidate_cache = nil -- 模糊匹配时，缩小匹配范围
local l_last_pattern = nil

-- 触发或更新补全选项
local function l_match_complete()
	--local str = p_helper.get_cur_line(l_ctx.col)

	--log.debug("match: %d", #l_candidate_cache)
	--local pattern = string.match(str, "[%a_][%w_]*$")

	--if pattern == nil or l_last_pattern == nil or string.match(pattern, "^" .. l_last_pattern) == nil then
	--	l_cadidate_cache = l_candidate
	--end

	--if pattern ~= nil then
	--	l_cadidate_cache = p_helper.head_fuzzy_match(l_cadidate_cache, pattern)
	--end
	--l_last_pattern = pattern

	l_candidate_cache = l_candidate
	log.debug("candi len")
	p_helper.complete(l_ctx.replace_col, l_cadidate)
	return ''
end

-- 新的候选
local function e_add_candidate(ctx, candi)
	if ctx == nil or candi == nil or #candi == 0 then
		return
	end

	if l_candidate == nil or p_context.ctx_is_equal(ctx, l_ctx) == false then
		l_ctx = ctx
		l_candidate = candi
	else
		for i, v in ipairs(candi) do
			table.insert(l_candidate, v)
		end
	end

	p_helper.complete(l_ctx.replace_col, l_cadidate)
	return ''
	--l_match_complete()
end


local function e_select_candidate()
	l_match_complete()
end

module.add_candidate = e_add_candidate
module.select_candidate = e_select_candidate

return module
