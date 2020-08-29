
local log = require("nvim-completor/log")
local api = require("nvim-completor/api")

-----
-- TODO 封装1-based api 到 0-based api
-----

local M = {}

-- [start_mark_id, end_mark_id)
-- { buf_id = {start_mark_id, end_mark_id}, {start_mark_id, end_mark_id} }
local mark_map = {}

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
	local buf_id = api.cur_buf()
	local marks = mark_map[buf_id] or {}
	for _, ph in ipairs(phs) do
		local start_mark_id = api.set_extmark(0, ph)
		local end_mark_id = api.set_extmark(0, {ph[1], ph[2] + ph[3]})
		table.insert(marks, {start_mark_id, end_mark_id})
	end

	mark_map[buf_id] = marks
	log.debug("marks: ", vim.fn.string(marks))
end

M.jump_to_next_pos = function(pos)
	local buf_id = api.cur_buf()
	local win_id = api.cur_win()
	local cur_pos = pos or api.get_cursor()

	log.debug("marks:", mark_map)
	local marks = mark_map[buf_id]
	local del_marks = {}
	local next_pos = nil

	local check = function(i, mark)
		local pos1 = api.get_extmark(mark[1])
		local pos2 = api.get_extmark(mark[2])
		log.debug(cur_pos, pos1, pos2)
		if api.pos_relation(pos1, pos2) ~= -1 then
			table.insert(del_marks, i)
			api.del_marks(mark)
			return
		end

		if api.pos_relation(cur_pos, pos2) ~= -1 then
			table.insert(del_marks, i)
			api.del_marks(mark)
			return
		end

		-- TODO: 是否做更全面的位置关系判断， 包含， 交叉等关系
		if next_pos and api.pos_relation(next_pos.pos2, pos2) == -1 then
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
	api.del_marks({next_pos.m1, next_pos.m2})
	api.set_cursor(pos1)
	local len = pos2[2] - pos1[2]
	local cmd = "<c-o>v" .. len - 1 .. "ld"
	vim.api.nvim_input(cmd)
end

-- edit: { new_text = {line1, line2}, head = { line, col } , tail = {line, col} }
local apply_edit = function(ctx, edit)
	
end

-- edit: { new_text = {line1, line2}, head = { line, col } , tail = {line, col} }
-- eidts: {edit}
M.apply_edits = function(ctx, edits)
	table.sort(edits, function(e1, e2)
		if e1.head[1] > e2.head[1] then return true end
		if e1.head[1] < e2.head[1] then return false end
		if e1.head[2] > e2.head[2] then return true end
		if e1.head[2] < e2.head[2] then return false end
		return true
	end)

	for _, e in ipairs(edits) do
	end
end

M.get_curline_marks = function(line)
	local buf = api.cur_buf()
	local marks = mark_map[buf]
	if marks == nil then return {} end

	-- {{ mark_id = xx, col = xx }}
	local cur_marks = {}
	for _, mark in ipairs(marks) do
		local pos1 = api.get_extmark(mark[1])
		local pos2 = api.get_extmark(mark[2])
		if pos1[1] == line then
			table.insert(cur_marks, {mark_id = mark[1], col = pos1[2]})
			table.insert(cur_marks, {mark_id = mark[2], col = pos2[2]})
		end
	end

	return cur_marks
end

return M
