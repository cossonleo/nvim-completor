--------------------------------------------------
--    LICENSE: 
--     Author: 
--    Version: 
-- CreateTime: 2018-03-04 22:53:58
-- LastUpdate: 2018-03-04 22:53:58
--       Desc: 
--------------------------------------------------

local util = require("util")
local api = require("api")
local fuzzy = require("fuzzy_match")
local ft = require("ft")
-- module name
local complete = {}

-- 匹配方法
local fuzzy_match = fuzzy.head_fuzzy_match

local ctx = api.context:new()

-- 获取匹配上下文
local function get_context()
	local pos = api.get_curpos()
	local cur_ctx = api.context:new()

	cur_ctx.bname = api.get_bufname()
	cur_ctx.bno = pos['buf']
	cur_ctx.line = pos['line']
	cur_ctx.ft = api.get_filetype()
	cur_ctx.typed = api.cursor_pre_content()
	cur_ctx.start = util.last_word_start(cur_ctx.typed)

	return cur_ctx
end

local function _text_changed()
	local pre_input = api.cursor_pre_content()
	local plen = pre_input:len()
	local lchar = pre_input:sub(plen,plen)
	if ft.trigger(lchar) == false then
		return
	end

	cur_ctx = get_context()
	if ctx:eq(cur_ctx) == false then
		ctx = cur_ctx
		api.complete(cur_ctx.start, {"false"})
	else
		api.complete(cur_ctx.start, {"true"})
	end
end

complete.text_changed = _text_changed

return complete
