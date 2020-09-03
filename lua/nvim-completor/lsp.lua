--------------------------------------------------
--		LICENSE: MIT
--		 Author: Cosson2017
--		Version: 0.3
-- CreateTime: 2019-03-07 13:35:53
-- LastUpdate: 2019-03-07 13:35:53
--			 Desc: lsp parse
--------------------------------------------------

-- local semantics = require("nvim-completor/semantics")
local protocol = require('vim.lsp.protocol')
local log = require("nvim-completor/log")
local snippet = require("nvim-completor/snippet")
local api = require("nvim-completor/api")

local module = {}

local function fix_edits_col(ctx, edits)
	local new_edits = {}

	local fix = function(pos)
		local line = ctx.typed
		if pos.line ~= ctx.pos[1] then
			line = api.get_line(pos.line)
		end
		pos.character = vim.str_byteindex(line, pos.character)
		return pos
	end

	for _, e in ipairs(edits) do
		e.range.start = fix(e.range.start)
		e.range["end"] = fix(e.range["end"])
		table.insert(new_edits, e)
	end
	return new_edits
end

-- lsp range pos: zero-base
local function lsp2vim_item(ctx, complete_item)
		-- local abbr = complete_item.label
	local word = ""

	-- 组装user_data
	local user_data = {}
	if complete_item.textEdit and complete_item.textEdit.newText then
		local apply_text = {}
		apply_text.typed = ctx.typed
		apply_text.pos = ctx.pos
		local raw_edits = {complete_item.textEdit}
		if complete_item.additionalTextEdits and #complete_item.additionalTextEdits > 0 then
			vim.list_extend(raw_edits, complete_item.additionalTextEdits)
		end
		apply_text.edits = fix_edits_col(ctx, raw_edits)
		apply_text.marks = ctx.marks
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
	return {e.head[1], e.head[2], e.i}
end)

local function apply_complete_edits(ctx, on_select)
	local bufnr = 0
	local ctx_line = ctx.pos[1]
	local ctx_col = ctx.pos[2]
	local ctx_typed = ctx.typed
	local text_edits = ctx.edits
	local ctx_marks = ctx.marks

	log.trace('apply_complete_edits', ctx, text_edits)
	if not next(text_edits) then return end

	local get_edit = function(e)
		head = {e.range.start.line; e.range.start.character};
		tail = {e.range["end"].line; e.range["end"].character};
		local new_text = e.newText

		if not on_select then
			return {
				head = head;
				tail = tail;
				new_text = vim.split(new_text, '\n', true);
			}
		end

		if head[1] ~= ctx_line and tail[1] ~= ctx_line then return nil end
		if head[1] < ctx_line then
			local temp = vim.split(e.newText, '\n', true);
			new_text = temp[#temp]
			head = {ctx_line, 0}
		elseif tail[1] > ctx_line then
			local temp = vim.split(e.newText, '\n', true);
			new_text = temp[1]
			tail = {ctx_line + 1, 0}
		else
			new_text = vim.fn.substitute(new_text, "\\n", "\\\\n", 'g');
		end

		return {
			head = head;
			tail = tail;
			new_text = {new_text}
		}
	end

	local cleaned = {}
	for i, e in ipairs(text_edits) do
		local edit = get_edit(e)
		if edit then
			edit.i = i
			table.insert(cleaned, edit)
		end
	end

	table.sort(cleaned, edit_sort_key)

	local cursor = nil
	for i = #cleaned, 1, -1 do
		local e = cleaned[i]
		local temp_cursor = snippet.apply_edit(ctx, e, not on_select)
		if not cursor then cursor = temp_cursor end
		if temp_cursor[3] then 
			cursor = temp_cursor 
		end
	end
	if cursor[3] and not on_select then
		snippet.jump_to_next_pos(cursor)
	else
		api.set_cursor(cursor)
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
	
	snippet.restore_ctx(user_data)
	apply_complete_edits(user_data, on_select)
end

return module
