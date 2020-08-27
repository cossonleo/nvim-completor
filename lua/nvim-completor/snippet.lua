
local log = require("nvim-completor/log")

local M = {}
local mark_ns = vim.api.nvim_create_namespace('nvim_completor')

-- [start_mark_id, end_mark_id)
-- { buf_id = {start_mark_id, end_mark_id}, {start_mark_id, end_mark_id} }
local mark_map = {}

-- -1 前面
-- 0 相等
-- 1 后面
local pos_relation = function(A, B)
	if A[1] < B[1] then return -1 end
	if A[1] > B[1] then return 1 end
	if A[2] < B[2] then return -1 end
	if A[2] > B[2] then return 1 end
	return 0
end

local del_marks = function(marks)
	if marks == nil then return end
	for _, mark in ipairs(marks) do
		vim.api.nvim_buf_del_extmark(buf_id, mark_ns, mark)
	end
end

local convert_step = function(str)
	local s = str:find("%$")
	if not s or s == #str then return str end
	local next_char = str:sub(s+1, s+1)
	if next_char == "{" then
		local front_str = str:sub(1, s-1)
		local after_str = str:sub(s)

		local ms = after_str:match("^%$%b{}")
		if not ms or #ms == 0 then return front_str .. "${", after_str:sub(3) end

		local next_str = after_str:sub(#ms + 1)
		-- local ph = ms:sub(3, -2):match("^[0-9]+:(.+)")
		local ph = ms:sub(3, -2):match("^[0-9]+:(.*)")
		if not ph then return front_str .. ms, next_str end
		return front_str .. ph, next_str, {col = #front_str, len = #ph}
	end

	if '0' <= next_char and next_char <= '9' then
		local front_str = str:sub(1, s-1)
		local after_str = str:sub(s)

		local ms = after_str:match("^%$[0-9]+")
		return front_str .. ms, after_str:sub(#ms + 1), {col = #front_str, len = #ms}
	end

	return str:sub(1, s), str:sub(s + 1)
end

local convert_iter = function(str)
	local iter_str = str
	return function()
		if not iter_str or #iter_str == 0 then return end
		local ret_str, istr, ph = convert_step(iter_str)
		iter_str = istr
		return ret_str, ph
	end
end

M.convert_to_str_item = function(str)
	local phs = {}
	local ret = ""

	for s, ph in convert_iter(str) do
		if ph then ph.col = ph.col + #ret end
		ret = ret .. s
		table.insert(phs, ph)
	end

	print(ret, vim.fn.string(phs))
	print(str)
	return {str = ret, phs = phs}
end

M.create_pos_extmarks = function(phs)
	local buf_id = vim.api.nvim_get_current_buf()
	local marks = mark_map[buf_id] or {}
	for _, ph in ipairs(phs) do
		local start_mark_id = vim.api.nvim_buf_set_extmark(0, mark_ns, 0, ph[1], ph[2], {})
		local end_mark_id = vim.api.nvim_buf_set_extmark(0, mark_ns, 0, ph[1], ph[2] + ph[3], {})
		table.insert(marks, {start_mark_id, end_mark_id})
	end

	-- sort
	-- local pos_debug = {}
	-- for _, p in ipairs(marks) do
	-- 	local A = vim.api.nvim_buf_get_extmark_by_id(0, mark_ns, p[1])
	-- 	local B = vim.api.nvim_buf_get_extmark_by_id(0, mark_ns, p[2])
	-- 	table.insert(pos_debug, {A, B})
	-- end
	-- log.debug("marks: ", vim.fn.string(pos_debug))
	-- table.sort(marks, mark_less)
	mark_map[buf_id] = marks
	log.debug("marks: ", vim.fn.string(marks))
end

M.jump_to_next_pos = function(pos)
	local buf_id = vim.api.nvim_get_current_buf()
	local win_id = vim.api.nvim_get_current_win()
	local cur_pos = pos or vim.api.nvim_win_get_cursor(win_id)
	cur_pos[1] = cur_pos[1] - 1

	log.debug("marks:", mark_map)
	local marks = mark_map[buf_id]
	local del_marks = {}
	local next_pos = nil

	local check = function(i, mark)
		local pos1 = vim.api.nvim_buf_get_extmark_by_id(0, mark_ns, mark[1])
		local pos2 = vim.api.nvim_buf_get_extmark_by_id(0, mark_ns, mark[2])
		log.debug(cur_pos, pos1, pos2)
		if pos_relation(pos1, pos2) ~= -1 then
			table.insert(del_marks, i)
			vim.api.nvim_buf_del_extmark(buf_id, mark_ns, mark[1])
			vim.api.nvim_buf_del_extmark(buf_id, mark_ns, mark[2])
			return
		end

		if pos_relation(cur_pos, pos2) ~= -1 then
			table.insert(del_marks, i)
			vim.api.nvim_buf_del_extmark(buf_id, mark_ns, mark[1])
			vim.api.nvim_buf_del_extmark(buf_id, mark_ns, mark[2])
			return
		end

		-- TODO: 是否做更全面的位置关系判断， 包含， 交叉等关系
		if next_pos and pos_relation(next_pos.pos2, pos2) == -1 then
			return
		end

		next_pos = {i = i, pos1 = pos1, pos2 = pos2, m1 = mark[1], m2 = mark[2]}
	end

	for i, mark in ipairs(marks) do
		check(i, mark)
	end

	if next_pos then table.insert(del_marks, next_pos.i) end
	table.sort(del_marks, function(i1, i2) return i1 > i2 end)
	for _, i in ipairs(del_marks) do
		table.remove(marks, i)
	end
	mark_map[buf_id] = marks

	if next_pos == nil then return end
	local pos1 ,pos2 = next_pos.pos1, next_pos.pos2
	vim.api.nvim_buf_del_extmark(buf_id, mark_ns, next_pos.m1)
	vim.api.nvim_buf_del_extmark(buf_id, mark_ns, next_pos.m2)
	vim.api.nvim_win_set_cursor(win_id, {pos1[1] + 1, pos1[2]})
	local len = pos2[2] - pos1[2]
	local cmd = "<c-o>v" .. len - 1 .. "ld"
	vim.api.nvim_input(cmd)
end

return M
