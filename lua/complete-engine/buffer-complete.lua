--------------------------------------------------
--    LICENSE: 
--     Author: 
--    Version: 
-- CreateTime: 2018-07-25 20:00:04
-- LastUpdate: 2018-07-25 20:00:04
--       Desc: 
--------------------------------------------------

local module = {}
local private = {}

local helper = require("nvim-completor/helper")
local ncm = require("nvim-completor/complete")
local log = require("nvim-completor/log")

private.buffer_words = {}

private.buffer = nil

private.on_buffer_enter = function()
	private.init_words()
end

private.on_buffer_change = function()
end

private.init_words = function()
--nvim_buf_line_count({buffer})                          *nvim_buf_line_count()*
--nvim_buf_get_lines({buffer}, {start}, {end}, {strict_indexing})
--	local pos = helper.get_curpos()
	private.buffer = vim.api.nvim_get_current_buf()
	local lines = vim.api.nvim_buf_get_lines(private.buffer, 0, -1, 0)
	for i, v in	ipairs(lines) do
		private.buffer_words[i] = {}
		local check_repeat = {}
		for w in string.gmatch(v, "[%w_]+") do
			if check_repeat[w] == nil then
				check_repeat[w] = 1
				table.insert(private.buffer_words[i], w)
			end
		end
	end
end

private.refresh_words = function()
	private.buffer = vim.api.nvim_get_current_buf()
	local pos = helper.get_curpos()
	local lines = vim.api.nvim_buf_get_lines(private.buffer, 0, -1, 0)
	if #lines < pos.line then
		return
	end
	private.buffer_words[pos.line] = {}
	local check_repeat = {}
	for w in string.gmatch(lines[pos.line], "[%w_]+") do
		if check_repeat[w] == nil then
			check_repeat[w] = 1
			table.insert(private.buffer_words[pos.line], w)
		end
	end
end

private.buffer_complete = function(ctx)
	log.debug("buffer cm trigger")

	local typed = helper.get_line_last_word(ctx.col)
	if typed == nil or string.len(typed) == 0 then
		private.refresh_words()
		return
	end

	local check_repeat = {}
	local candi = {}
	for k, lines in pairs(private.buffer_words) do
		for i, w in ipairs(lines) do
			if check_repeat[w] == nil then
				check_repeat[w] = 1
				table.insert(candi, {word = w, abbr = w, menu = "buf", icase = 1, dup = 0 })
			end
		end
	end
end

ncm.add_engine(private.buffer_complete, "common")
log.info("add buffer complete success")
