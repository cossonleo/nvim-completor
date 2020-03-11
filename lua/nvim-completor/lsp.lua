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

local module = {}
local private = {}

private.kind_text_mappings = {
            'text',
            'method',
            'function',
            'constructor',
            'field',
            'variable',
            'class',
            'interface',
            'module',
            'property',
            'unit',
            'value',
            'enum',
            'keyword',
            'snippet',
            'color',
            'file',
            'reference',
		}

private.get_kind_text = function(index)
	if index == nil then
		return ''
	end
	local t = private.kind_text_mappings[index]
	if t == nil then
		return ''
	end
	return t
end

-- lsp range pos: zero-base
private.complete_item_lsp2vim = function(ctx, complete_item)
    local abbr = item['label']
	local word = (complete_item.textEdit and complete_item.textEdit.newText) or complete_item.insertText or complete_item.label

    local info = ' '
    local documentation = completion_item.documentation
    if documentation then
      if type(documentation) == 'string' and documentation ~= '' then
        info = documentation
      elseif type(documentation) == 'table' and type(documentation.value) == 'string' then
        info = documentation.value
      end
    end

    return {
      word = word,
      abbr = completion_item.label,
      kind = protocol.CompletionItemKind[completion_item.kind] or '',
      menu = completion_item.detail or '',
      info = info,
      icase = 1,
      dup = 1,
      empty = 1,
	  user_data = vim.fn.json_encode({lsp = completion_item}),
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

module.complete_items_lsp2vim = function(ctx, data)
	local items = {}
	for _, v in pairs(data) do
		local item = private.complete_item_lsp2vim(ctx, v)
		if item ~= nil then
			table.insert(items, item)
		end
	end

	return items
end

module.apply_complete_user_data = function(data)
	local user_data = vim.fn.json_decode(data)
	if user_data == nil then
		return
	end
	if user_data.line == nil then
		return
	end
	local bno = user_data.bno
	local line = user_data.line
	local content = user_data.content
	local col = user_data.col

	vim.api.nvim_buf_set_lines(bno, line, line + 1, false, {content})
end

return module
