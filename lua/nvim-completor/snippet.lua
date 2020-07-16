
-- local log = require("nvim-completor/log")

local M = {}
local mark_ns = vim.api.nvim_create_namespace('nvim_completor')

-- [start_mark_id, end_mark_id)
-- { buf_id = {start_mark_id, end_mark_id}, {start_mark_id, end_mark_id} }
local mark_map = {}

local compare_mark = function(extmark1, extmark2)
	local pos1 = vim.api.nvim_buf_get_extmark_by_id(0, mark_ns, extmark1[1])
	local pos2 = vim.api.nvim_buf_get_extmark_by_id(0, mark_ns, extmark2[1])
	if #pos2 then return true end
	if #pos1 then return false end
	if pos1[1] < pos2[1] then return true end
	if pos1[1] > pos2[1] then return false end
	if pos1[2] <= pos2[2] then return true end
	return false
end

local compare_pos = function(pos1, pos2)
	if pos1[1] < pos2[1] then return true end
	if pos1[1] > pos2[1] then return false end
	if pos1[2] <= pos2[2] then return true end
	return false
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
		local ph = ms:sub(3, -2):match("^[0-9]+:(.+)")
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
	local cur_id = vim.api.nvim_get_current_buf()
	local marks = mark_map[cur_id] or {}
	for _, ph in ipairs(phs) do
		local start_mark_id = vim.api.nvim_buf_set_extmark(0, mark_ns, 0, ph[1], ph[2], {})
		local end_mark_id = vim.api.nvim_buf_set_extmark(0, mark_ns, 0, ph[1], ph[2] + ph[3], {})
		table.insert(marks, {start_mark_id, end_mark_id})
	end

	-- sort
	table.sort(marks, compare_mark)
	mark_map[cur_id] = marks
end

M.jump_to_next_pos = function(pos)
	local cur_id = vim.api.nvim_get_current_buf()
	local win_id = vim.api.nvim_get_current_win()
	local cur_pos = pos or vim.api.nvim_win_get_cursor(win_id)
	cur_pos[1] = cur_pos[1] - 1

	local marks = mark_map[cur_id]
	local del_marks = {}
	for i, mark in ipairs(marks) do
		local pos1 = vim.api.nvim_buf_get_extmark_by_id(0, mark_ns, mark[1])
		local pos2 = vim.api.nvim_buf_get_extmark_by_id(0, mark_ns, mark[2])
		if compare_pos(pos2, pos1) then
			table.insert(del_marks, i)
			vim.api.nvim_buf_del_extmark(cur_id, mark_ns, mark[1])
			vim.api.nvim_buf_del_extmark(cur_id, mark_ns, mark[2])
		elseif compare_pos(cur_pos, pos1) then
			table.insert(del_marks, i)
			vim.api.nvim_buf_del_extmark(cur_id, mark_ns, mark[1])
			vim.api.nvim_buf_del_extmark(cur_id, mark_ns, mark[2])

			local line_content = vim.api.nvim_buf_get_lines(cur_id, pos1[1], pos1[1] + 1, false)
			print("....", line_content)
			-- line_content = line_content:sub(1, pos1[1]) .. line_content:sub(pos[2] + 1)
			-- vim.api.nvim_buf_set_lines(cur_id, pos1[1], pos[1] + 1, {line_content}, false)
			-- vim.api.nvim_win_set_cursor(cur_id, {pos1[1] + 1, pos1[2]})
		end
	end

	for _, i in ipairs(del_marks) do
		table.remove(marks, i)
	end
	mark_map[cur_id] = marks
end

return M
