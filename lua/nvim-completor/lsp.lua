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

local module = {}
local private = {}


-- lsp range pos: zero-base
private.lsp_item2vim = function(ctx, complete_item)
    local abbr = complete_item.label
	local word = (complete_item.textEdit and complete_item.textEdit.newText) or complete_item.insertText or complete_item.label

	-- 校正abbr
	if not complete_item.textEdit and not complete_item.insertText then
		local prefix = ctx:typed_to_cursor()
		local ps, pe = prefix:find("%w_+$")
		if ps and pe then
			abbr = prefix:sub(ps, pe) .. abbr
		end
	end

	-- 组装user_data
	local user_data = {}
	if complete_item.textEdit then
		local apply_text = {}
		apply_text.typed = ctx.typed
		apply_text.range = complete_item.textEdit.range
		apply_text.newText = complete_item.textEdit.newText
		user_data = {apply_text = apply_text}
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


--	local user_data = {}
--	user_data.bno = ctx.bno
--
--	local typed_len = ctx.typed:len()
--	local start = 0
--	local tail = 0
--	if item['textEdit'] ~= nil then
--		start = item['textEdit']['range']['start']['character'] + 1
--		tail = item['textEdit']['range']['end']['character'] + 1
--		word = item['textEdit']['newText']
--		user_data.line = item['textEdit']['range']['start']['line']
--	else
--		--word = abbr
--		user_data.line = ctx.line - 1
--		start, tail = semantics.new_text_pos(ctx)
--		if start == nil or tail == nil then
--			start = ctx.col + 1
--			tail = ctx.col + 1
--		end
--	end
--
--	user_data.content = ctx.typed:sub(1, start - 1) .. word .. ctx.typed:sub(tail)
--	user_data.col = start + #word
--	if start <= ctx.col then
--		word = word:sub(ctx.col - start + 2)
--	end
--
--	if item['detail'] ~= nil then
--		abbr = abbr .. ' ' .. item['detail']
--	end
--
--	if item.kind ~= nil then
--		menu = private.get_kind_text(item.kind)
--	end
--
--	local ud = vim.fn.json_encode(user_data)
--    return {word = word, abbr = abbr, menu = menu, icase = 1, dup = 0, user_data = ud}
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

module.apply_complete_user_data = function(data)

--	local user_data = {}
--	if complete_item.textEdit then
--		local apply_text = {}
--		apply_text.typed = ctx.typed
--		apply_text.range = complete_item.textEdit.range
--		apply_text.newText = complete_item.textEdit.range.newText
--		user_data = {apply_text = apply_text}
--
--		start = item['textEdit']['range']['start']['character'] + 1
--		tail = item['textEdit']['range']['end']['character'] + 1
--		word = item['textEdit']['newText']
--		user_data.line = item['textEdit']['range']['start']['line']

	local user_data = vim.fn.json_decode(data)
	if type(user_data) ~= "table" or vim.tbl_isempty(user_data) then
		return
	end

	local typed = user_data.apply_text.typed
	local newText = user_data.apply_text.newText
	local line = user_data.apply_text.range.start.line
	local start = user_data.apply_text.range.start.character
	local tail = user_data.apply_text.range['end'].character
	local content = typed:sub(1, start) .. newText .. typed:sub(tail + 1)

	log.debug("apply ", content)


	vim.api.nvim_buf_set_lines(bno, line, line + 1, false, {content})
end

return module
