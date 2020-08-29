-- 所有的api都是 0-based

local M = {}

local vapi = vim.api

local mark_ns = vim.api.nvim_create_namespace('nvim_completor')

M.cur_buf = function()
	return vapi.nvim_get_current_buf()
end

M.cur_win = function()
	return vapi.nvim_get_current_win()
end

M.get_cursor = function()
	local cursor = vapi.nvim_win_get_cursor(0)
	cursor[1] = cursor[1] - 1
	return cursor
end

M.set_cursor = function(pos)
	vapi.nvim_win_set_cursor(0, {pos[1] + 1, pos[2]})
end

M.set_extmark = function(mark_id, pos)
	local mid = vapi.nvim_buf_set_extmark(0, mark_ns, mark_id, pos[1], pos[2], {})
	return mid
end

M.get_extmark = function(mark)
	return vapi.nvim_buf_get_extmark_by_id(0, mark_ns, mark)
end

-- -1 前面
-- 0 相等
-- 1 后面
M.pos_relation = function(A, B)
	if A[1] < B[1] then return -1 end
	if A[1] > B[1] then return 1 end
	if A[2] < B[2] then return -1 end
	if A[2] > B[2] then return 1 end
	return 0
end

M.del_marks = function(marks)
	if marks == nil then return end
	local buf_id = M.cur_buf()
	for _, mark in ipairs(marks) do
		vim.api.nvim_buf_del_extmark(buf_id, mark_ns, mark)
	end
end


return M
