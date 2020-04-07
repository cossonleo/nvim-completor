--------------------------------------------------
--    LICENSE: MIT
--     Author: Cosson2017
--    Version: 0.3
-- CreateTime: 2019-03-07 13:35:53
-- LastUpdate: 2019-03-07 13:35:53
--       Desc: lsp parse
--------------------------------------------------

local semantics = require("nvim-completor/semantics")
local protocol = require('vim.lsp.protocol')
local log = require("nvim-completor/log")
local api = vim.api

local module = {}
local private = {}


-- lsp range pos: zero-base
private.lsp_item2vim = function(ctx, complete_item)
    local abbr = complete_item.label
	local word = ""

	-- 组装user_data
	local user_data = {}
	if complete_item.textEdit and complete_item.textEdit.newText then
		local apply_text = {}
		apply_text.typed = ctx.typed
		apply_text.line = ctx.pos.position.line
		apply_text.edits = {complete_item.textEdit}
		if complete_item.additionalTextEdits and #complete_item.additionalTextEdits > 0 then
			vim.list_extend(apply_text.edits, complete_item.additionalTextEdits)
		end
		--apply_text.range = complete_item.textEdit.range
		--apply_text.newText = complete_item.textEdit.newText
		user_data = apply_text
		word = complete_item.textEdit and complete_item.textEdit.newText

		---- 需不需要判断开始行 TODO
		----
		---- 判断开始列
		--local textEdit_start = user_data.range.start.character
		--local ctx_start = ctx.pos.position.character
		--if  textEdit_start < ctx_start then
		--	log.debug("start offset ", ctx_start - textEdit_start )
		--	word = word:sub(ctx_start - textEdit_start + 1)
		--end

		---- 判断结束列
		--local textEdit_tail = user_data.range['end'].character
		--local line_offset = user_data.range['end'].line - user_data.range.start.line
		--if line_offset == 1 then
		--	textEdit_tail = #ctx.typed + 1
		--elseif line_offset > 1 then
		--	-- TODO 暂不处理
		--end

	--elseif  complete_item.insertText or complete_item.label then
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

module.lsp_items2vim = function(ctx, data)
	local items = {}
	for _, v in pairs(data) do
		local item = private.lsp_item2vim(ctx, v)
		if item ~= nil then
			table.insert(items, item)
		end
	end

	return items
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

function module.apply_first_line_edits(bufnr, text_edits)
  if not next(text_edits) then return end
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

  -- Reverse sort the orders so we can apply them without interfering with
  -- eachother. Also add i as a sort key to mimic a stable sort.
  table.sort(cleaned, edit_sort_key)
  if not api.nvim_buf_is_loaded(bufnr) then
    vim.fn.bufload(bufnr)
  end

  
  local lines = api.nvim_buf_get_lines(bufnr, start_line, finish_line + 1, false)
  local fix_eol = api.nvim_buf_get_option(bufnr, 'fixeol')
  local set_eol = fix_eol and api.nvim_buf_line_count(bufnr) <= finish_line + 1
  if set_eol and #lines[#lines] ~= 0 then
    table.insert(lines, '')
  end

  for i = #cleaned, 1, -1 do
    local e = cleaned[i]
    local A = {e.A[1] - start_line, e.A[2]}
    local B = {e.B[1] - start_line, e.B[2]}
    lines = vim.lsp.util.set_lines(lines, A, B, e.lines)
  end
  if set_eol and #lines[#lines] == 0 then
    table.remove(lines)
  end
  log.trace(lines[1])
  api.nvim_buf_set_lines(bufnr, start_line, start_line + 1, false, {lines[1]})
end


module.apply_complete_user_edit_first = function(data)
	if not data or #data == 0 then
		return
	end
	log.trace("apply complete user data")
	local user_data = vim.fn.json_decode(data)
	if type(user_data) ~= "table" or vim.tbl_isempty(user_data) then
		return
	end

	local typed = user_data.typed
	local ctx_line = user_data.line
	vim.api.nvim_buf_set_lines(0, ctx_line, ctx_line + 1, false, {typed})

	module.apply_first_line_edits(0, user_data.edits)
	local newText = user_data.edits[1].newText
	local start = user_data.edits[1].range.start.character
	vim.api.nvim_win_set_cursor(0, {ctx_line + 1, start + #newText})
	--local newText = user_data.newText
	--local line = user_data.range.start.line
	--local start = user_data.range.start.character
	--local tail = user_data.range['end'].character
	--if tail < start then
	--	tail = #typed
	--end
	--local content = typed:sub(1, start) .. newText .. typed:sub(tail + 1)
	----vim.api.nvim_buf_set_lines(bno, line, line + 1, false, {content})
	--vim.api.nvim_buf_set_lines(0, line, line + 1, false, {content})
	--vim.api.nvim_win_set_cursor(0, {line + 1, start + #newText})
end

module.apply_user_data_edits_all = function(data)
	if not data or #data == 0 then
		return
	end
	log.trace("apply complete user data")
	local user_data = vim.fn.json_decode(data)
	if type(user_data) ~= "table" or vim.tbl_isempty(user_data) then
		return
	end

	local typed = user_data.typed
	local ctx_line = user_data.line
	vim.api.nvim_buf_set_lines(0, ctx_line, ctx_line + 1, false, {typed})

	--local newText = user_data.newText
	--local line = user_data.range.start.line
	--local start = user_data.range.start.character
	--local tail = user_data.range['end'].character
	--if tail < start then
	--	tail = #typed
	--end
	--local content = typed:sub(1, start) .. newText .. typed:sub(tail + 1)
	--vim.api.nvim_buf_set_lines(bno, line, line + 1, false, {content})
	vim.lsp.util.apply_text_edits(user_data.edits, 0)
	local newText = user_data.edits[1].newText
	local start = user_data.edits[1].range.start.character
	vim.api.nvim_win_set_cursor(0, {ctx_line + 1, start + #newText})
end


return module
