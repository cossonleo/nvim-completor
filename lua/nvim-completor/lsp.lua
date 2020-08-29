--------------------------------------------------
--    LICENSE: MIT
--     Author: Cosson2017
--    Version: 0.3
-- CreateTime: 2019-03-07 13:35:53
-- LastUpdate: 2019-03-07 13:35:53
--       Desc: lsp parse
--------------------------------------------------

-- local semantics = require("nvim-completor/semantics")
local protocol = require('vim.lsp.protocol')
local log = require("nvim-completor/log")
local snippet = require("nvim-completor/snippet")
local api = require("nvim-completor/api")

local module = {}

-- lsp range pos: zero-base
local function lsp2vim_item(ctx, complete_item)
    -- local abbr = complete_item.label
	local word = ""

	-- 组装user_data
	local user_data = {}
	if complete_item.textEdit and complete_item.textEdit.newText then
		local apply_text = {}
		apply_text.typed = ctx.typed
		apply_text.line = ctx.pos.position.line
		apply_text.col = ctx.pos.position.character
		apply_text.edits = {complete_item.textEdit}
		if complete_item.additionalTextEdits and #complete_item.additionalTextEdits > 0 then
			vim.list_extend(apply_text.edits, complete_item.additionalTextEdits)
		end
		user_data = apply_text
		word = complete_item.textEdit and complete_item.textEdit.newText
	else
		word = complete_item.insertText or complete_item.label
		-- lua lsp 出现重复前部 若其他lsp server出现其他情况， 则需要加判断
		local trigger_str = ctx:typed_to_cursor():match('[%w_]+$')
		if trigger_str and vim.startswith(word, trigger_str) then
			word = word:sub(#trigger_str + 1)
		end
		-- abbr = ctx:typed_to_cursor():match('[%w_]*$') .. abbr
	--else
	--	word = complete_item.insertText
	end

    local info = ' '
    local documentation = complete_item.documentation
    if documentation then
      if type(documentation) == 'string' and documentation ~= '' then
        info = documentation
      elseif type(documentation) == 'table' and type(documentation.value) == 'string' then
        info = documentation.value
      end
    end

    return {
      word = word,
      abbr = complete_item.label,
      kind = protocol.CompletionItemKind[complete_item.kind] or '',
      menu = complete_item.detail or '',
      info = info,
      icase = 1,
      dup = 1,
      empty = 1,
	  user_data = vim.fn.json_encode(user_data),
    }

end

local function sort_by_key(fn)
  return function(a,b)
    local ka, kb = fn(a), fn(b)
    assert(#ka == #kb)
    for i = 1, #ka do
      if ka[i] ~= kb[i] then
        return ka[i] < kb[i]
      end
    end
    -- every value must have been equal here, which means it's not less than.
    return false
  end
end

local edit_sort_key = sort_by_key(function(e)
  return {e.A[1], e.A[2], e.i}
end)

-- 计算光标位置
local function calc_cursor(e, cursor)
	if e.B[1] < cursor[1] then
		cursor[1] = cursor[1] + #e.lines - (e.B[1] - e.A[1] + 1)
		return cursor
	end

	if e.B[1] == cursor[1] and e.B[2] <= cursor[2] then
		if e.A[1] == e.B[1] and (#e.lines == 1) then
			cursor[2] = cursor[2] + #e.lines[1] - (e.B[2] - e.A[2])
			return cursor
		end

		cursor[1] = cursor[1] + #e.lines - (e.B[1] - e.A[1] + 1)
		cursor[2] = cursor[2] + #e.lines[#e.lines] - e.B[2]
	end

	return cursor
end

local function apply_edit_on_select(ctx, text_edit)
end

local function apply_complete_edits(ctx, text_edits, on_select)
	local bufnr = 0
	local ctx_line = ctx[1]
	local ctx_col = ctx[2]
	local ctx_typed = ctx[3]
	log.trace('apply_complete_edits', ctx, text_edits)
	if not next(text_edits) then return end

	if on_select then
		local e = text_edits[1]
		local head = e.range.start.character
		local tail = e.range['end'].character
		local new_text = vim.split(e.newText, '\n', true)[1]
		new_text = snippet.convert_to_str_item(new_text).str
		local new_col = head + #new_text
		new_text = (ctx_typed:sub(1, head) or '') .. new_text .. (ctx_typed:sub(tail + 1) or '')
		vim.api.nvim_buf_set_lines(bufnr, ctx_line, ctx_line + 1, false, {new_text})
		api.set_cursor({ctx_line, new_col})
		return
	end

	local start_line, finish_line = math.huge, -1
	local cleaned = {}
	for i, e in ipairs(text_edits) do
		start_line = math.min(e.range.start.line, start_line)
		finish_line = math.max(e.range["end"].line, finish_line)
		-- TODO(ashkan) sanity check ranges for overlap.
		table.insert(cleaned, {
			i = i;
			A = {e.range.start.line; e.range.start.character};
			B = {e.range["end"].line; e.range["end"].character};
			lines = vim.split(e.newText, '\n', true);
		})
	end

	-- 计算出备用col
	local spare_col = cleaned[1].A[2] + #cleaned[1].lines[1]

	-- Reverse sort the orders so we can apply them without interfering with
	-- eachother. Also add i as a sort key to mimic a stable sort.
	table.sort(cleaned, edit_sort_key)
	if not vim.api.nvim_buf_is_loaded(bufnr) then
		vim.fn.bufload(bufnr)
	end

	local lines = vim.api.nvim_buf_get_lines(bufnr, start_line, finish_line + 1, false)
	lines[ctx_line - start_line + 1] = ctx_typed

	local fix_eol = vim.api.nvim_buf_get_option(bufnr, 'fixeol')
	local set_eol = fix_eol and vim.api.nvim_buf_line_count(bufnr) <= finish_line + 1
	if set_eol and #lines[#lines] ~= 0 then
	  table.insert(lines, '')
	end

	local ctx_cursor = {ctx_line, ctx_col}
	for i = #cleaned, 1, -1 do
		local e = cleaned[i]

		if e.i ~= 1 then
			ctx_cursor = calc_cursor(e, ctx_cursor)
		end

		local A = {e.A[1] - start_line, e.A[2]}
		local B = {e.B[1] - start_line, e.B[2]}
		lines = vim.lsp.util.set_lines(lines, A, B, e.lines)
	end
	if set_eol and #lines[#lines] == 0 then
	  table.remove(lines)
	end

	local real_line = ctx_cursor[1]
	local real_col = spare_col
	local ctx_line_index = real_line - start_line + 1
	local place_cursor = {}
	for i = ctx_line_index, #lines, 1 do
		local ret = snippet.convert_to_str_item(lines[i])
		log.debug("ret", ret)
		lines[i] = ret.str
		for _, ph in ipairs(ret.phs) do
			table.insert(place_cursor, {start_line + i - 1, ph.col, ph.len})
		end
	end

	vim.api.nvim_buf_set_lines(bufnr, start_line, finish_line + 1, false, lines)
	snippet.create_pos_extmarks(place_cursor)
	if #place_cursor > 0 then
		snippet.jump_to_next_pos(ctx_cursor)
	else
		api.set_cursor({ctx_line, real_col})
	end
end

module.lsp_items2vim = function(ctx, data)
	local items = {}
	for _, v in pairs(data) do
		local item = lsp2vim_item(ctx, v)
		if item ~= nil then
			table.insert(items, item)
		end
	end

	return items
end

module.apply_complete_user_edit = function(data, on_select)
	if not data or #data == 0 then
		return
	end
	log.trace("apply complete user data")
	local user_data = vim.fn.json_decode(data)
	if type(user_data) ~= "table" or vim.tbl_isempty(user_data) then
		return
	end

	local ctx_typed = user_data.typed
	local ctx_line = user_data.line
	local ctx_col = user_data.col

	apply_complete_edits({ctx_line, ctx_col, ctx_typed}, user_data.edits, on_select)
end

return module
