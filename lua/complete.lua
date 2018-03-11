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
local items = nil
local cache = nil
local last_pattern = nil


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
	if api.pumvisible() then
		return
	end
	if items == nil or #items == 0 then
		vim.api.nvim_out_write("items is empty \n")
		return
	end

	local pos = api.get_curpos()
	local typed = ""

	if pos.col > 1 then
		typed = vim.api.nvim_get_current_line():sub(1, pos.col - 1)
	end

	local pattern = string.match(typed, "[%a_][%w_]*$")
	if pattern == nil then
		last_pattern = nil
		cache = items
		api.complete(last_req_ctx.start, items)
		return ''
	else
		if last_pattern == nil or
			string.match(pattern, "^" .. last_pattern) == nil
			then
			last_pattern = pattern
			cache = fuzzy_match(items, pattern )
			api.complete(last_req_ctx.start, cache)
			return ''
		end

		--cache = fuzzy_match(cache, pattern)
		cache = fuzzy_match(items, pattern)
		last_pattern = pattern
		api.complete(last_req_ctx.start, cache)
		return ''
	end

	return ''

	--if last_pattern == nil or last_pattern == "" then
	--	last_pattern = pattern
	--	cache = fuzzy_match(items, pattern )

	--	api.complete(last_req_ctx.start, cache)
	--	return
	--end

	--if cache == nil or #cache == 0 then
	--	cache = fuzzy_match(items, pattern )
	--end

	--if string.match(pattern, "^" .. last_pattern) ~= nil then
	--	cache = fuzzy_match(cache, pattern )
	--end

	--if #cache == 0 then
	--	print(5)
	--	return
	--end
	--last_pattern = pattern
	--api.complete(last_req_ctx.start, cache)
end

local function _handle_completion(ctx, data)
	items = lsp.format_completion(data)
	if items == nil or #items == 0 then
		return
	end

	local ctx = _get_context()
	if not ctx:eq(last_req_ctx) then
		last_req_ctx = ft.context:new()
		cache = nil
		last_pattern = nil
		items = nil
		vim.api.nvim_out_write("complete ctx change\n")
		return
	end
	cache = items
	vim.api.nvim_out_write("completion items find " .. #items .. "\n")
	api.complete(ctx.start, cache)
	return ''
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

	if ft.is_request(ctx.typed) then --or not ctx:eq(last_req_ctx) then
		items = nil
		cache = nil
		last_pattern = nil
		last_req_ctx = ctx
		lsp.lsp_complete(ctx)
	elseif ctx:eq(last_req_ctx) then
		_direct_completion()
	end
end

function _reset_default()
	items = nil
	cache = nil
	last_pattern = nil
	last_req_ctx = ft.context:new()
end

complete.text_changed = _text_changed
complete.handle_completion = _handle_completion
complete.direct_complete = _direct_completion
complete.reset_default = _reset_default

return complete
