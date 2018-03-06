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
local complete = {}

local items = {}
local anypattern = '[%w_]'
local ctx = {}

local ctx = {}

function complete.context()
	local pos = api.get_curpos()
	local ft = api.get_filetype()
	local bufname = api.get_bufname()
	local pre_input = api.cursor_pre_content()
	local start = util.last_word_start(pre_input)
	local lctx = {bname=bufname, bno=pos["buf"], line=pos["line"], ft=ft, typed=pre_input, start=start}
	return lctx
end

complete.fuzzy_match = function(items, pattern)
	if pattern:len() == 0 then
		return items
	end

	local candicates = {}
	for i, v in ipairs(items) do
		if util.head_fuzzy_match(v, pattern) then
			candicates:insert(v)
		end
	end
	return candicates
end

local function calc_cur_ctx()
	local buf = vim.api.nvim_get_current_buf()
	local ft = vim.api.nvim_buf_get_option(buf, 'filetype')
	local win = vim.api.nvim_get_current_win()
	local curpos = vim.api.nvim_call_function('getcurpos', {}) -- 带前面的特殊符
-- nvim_win_get_cursor() 不带前面的特殊
	local curpos = vim.api.nvim_call_function('getline', {curpos[2]})

	local line = vim.api.nvim_get_current_line()
end

return complete
