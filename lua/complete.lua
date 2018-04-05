--------------------------------------------------
--    LICENSE: MIT
--     Author: Cosson2017
--    Version: 0.2
-- CreateTime: 2018-03-04 22:53:58
-- LastUpdate: 2018-03-19 13:10:38
--       Desc: 
--------------------------------------------------

local util = require("util")
local api = require("api")
local fuzzy = require("fuzzy_match")
local trigger = require("trigger")
local context = require("context")
local lsp = require("complete-lsp")
-- module name
local complete = {}

-- 匹配方法
local fuzzy_match = fuzzy.head_fuzzy_match

local last_req_ctx = context.context:new()
local items = nil
local cache = nil
local last_pattern = nil

local function _direct_completion()
	if api.menu_selected() then
		return
	end
	if items == nil or #items.items == 0 then
		return
	end

	local pos = api.get_curpos()
	local typed = ""

	if pos.col > 1 then
		typed = vim.api.nvim_get_current_line():sub(1, pos.col - 1)
	end

	local pattern = string.match(typed, "[%a_][%w_]*$")

	if pattern == nil or last_pattern == nil or string.match(pattern, "^" .. last_pattern) == nil then
		cache = items.items
	end

	if pattern ~= nil then
		cache = fuzzy_match(cache, pattern)
	end
	last_pattern = pattern
	api.complete(items.start, cache)
	return ''
end

local function _handle_completion(ctx, data)
	items = lsp.format_completion(data)
	if #items.items == 0 then
		return
	end

	local ctx = context.get_context()
	if not ctx:eq(last_req_ctx) then
		last_req_ctx = context.context:new()
		cache = nil
		last_pattern = nil
		items = nil
		return
	end
	cache = items.items

	if items.start == -1 then
		items.start = string.find(ctx.typed, '[%a_][%w_]*$')
		if items.start == nil then
			items.start = ctx.trigger_pos + 1
		end
	else
		items.start = items.start
	end
	api.complete(items.start, cache)
	return ''
end

local function _text_changed()
	if trigger.filetype == nil then
		return
	end

	local ctx = context.get_context()
	len = #ctx.typed
	if len == 0 then
		return
	end

	if ctx:eq(last_req_ctx) then
		_direct_completion()
	elseif ctx.trigger_pos ~= 0 then --or not ctx:eq(last_req_ctx) then
		items = nil
		cache = nil
		last_pattern = nil
		last_req_ctx = ctx
		lsp.lsp_complete(ctx)
	end
end

function _reset_default()
	items = nil
	cache = nil
	last_pattern = nil
	last_req_ctx = context.context:new()
end

complete.text_changed = _text_changed
complete.handle_completion = _handle_completion
complete.direct_complete = _direct_completion
complete.reset_default = _reset_default

return complete
