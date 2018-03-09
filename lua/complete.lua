--------------------------------------------------
--    LICENSE: 
--     Author: 
--    Version: 
-- CreateTime: 2018-03-04 22:53:58
-- LastUpdate: 2018-03-08 18:36:39
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
local last_req_ctx = ft.context:new()

local items = {}
local cache = {}
local last_pattern = ""


-- 获取匹配上下文
local function _get_context()
	local pos = api.get_curpos()
	local cur_ctx = ft.context:new()
	cur_ctx.bname = api.get_bufname()
	cur_ctx.bno = pos.buf
	cur_ctx.line = pos.line
	cur_ctx.filetype = ft.filetype
	if pos.col <= 1 then
		cur_ctx.typed = ""
	else
		cur_ctx.typed = vim.api.nvim_get_current_line():sub(1, pos.col - 1)
	end

	cur_ctx.start, cur_ctx.ed = string.find(cur_ctx.typed, "[%a_][%w_]*$")
	if cur_ctx.start == nil or cur_ctx.start == 0 then
		cur_ctx.ed = #cur_ctx.typed
		cur_ctx.start = cur_ctx.ed + 1
	end

	return cur_ctx
end

local function _direct_completion()
	if items == nil then
		return
	end

	local pos = api.get_curpos()
	if pos.col <= 1 then
		return
	end

	local typed = vim.api.nvim_get_current_line():sub(1, pos.col - 1)
	local pattern = string.match(typed, "[%a_][%w_]*$")
	if pattern == nil then
		return
	end

	if string.match(pattern, "^" .. last_pattern) ~= nil then
		if cache ~= nil and #cache > 0 then
			cache = fuzzy_match(cache, pattern )
		else
			cache = fuzzy_match(items, pattern )
		end
	else
		cache = fuzzy_match(items, pattern )
	end

	last_pattern = pattern
	if cache == nil then
		return
	end
	api.complete(last_req_ctx.start, cache)
end

local function _handle_completion(ctx, data)
	items = lsp.format_completion(data)
	if items == nil or #items == 0 then
		return
	end

	cache = items

	api.complete(ctx.start, cache)
end

local function _text_changed()
	if ft.filetype == nil then
		return
	end

	local ctx = _get_context()

	len = #ctx.typed
	if len == 0 then
		return
	end

	if ft.trigger_request(ctx.typed) or not ctx:eq(last_req_ctx) then
		items = nil
		cache = nil
		last_pattern = ""
		last_req_ctx = ctx
		lsp.lsp_complete(ctx)
	else
		_direct_completion()
	end
end


complete.text_changed = _text_changed
complete.handle_completion = _handle_completion

return complete
