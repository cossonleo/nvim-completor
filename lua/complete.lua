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
local lsp = require("complete-lsp")
-- module name
local complete = {}

-- 匹配方法
local fuzzy_match = fuzzy.head_fuzzy_match
local ctx = api.context:new()

local items = {}
local cache = {}


-- 获取匹配上下文
local function _get_context()
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

local function _direct_completion(old_ctx)
	-- TODO
	--
	if items == nil then
		return
	end

	local tlen = ctx.typed:len()
	if ctx.start <= tlen then
		local pattern = ctx.typed:sub(ctx.start, tlen)
		cache = fuzzy_match(items, pattern )
	end
	api.complete(ctx.start, cache)
end

local function _handle_completion(ctx, data)
	items = lsp.format_completion(data)
	if items == nil then
		api.echo_log("items is nil")
		return
	end

	cache = items
	local tlen = ctx.typed:len()
	if ctx.start <= tlen then 
		local pattern = ctx.typed:sub(ctx.start, tlen)
		cache = fuzzy_match(items, pattern)
	end

	api.complete(ctx.start, cache)
end

local cg = 0
local ng = 0
local function _text_changed()
	local pre_input = api.cursor_pre_content()
	local plen = pre_input:len()
	local lchar = pre_input:sub(plen,plen)
	if ft.trigger(lchar) == false then
		return
	end

	old = ctx
	ctx = _get_context()
	if ctx:eq(old) == false then
		items = nil
		lsp.lsp_complete(ctx)
		cg = cg + 1
		print("cg", cg)
	else
		_direct_completion(old)	
		ng = ng + 1
		print("ng", ng)
	end
end


complete.text_changed = _text_changed
complete.handle_completion = _handle_completion

return complete
