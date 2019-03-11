--------------------------------------------------
--    LICENSE: MIT
--     Author: Cosson2017
--    Version: 0.3
-- CreateTime: 2019-03-07 13:35:53
-- LastUpdate: 2019-03-07 13:35:53
--       Desc: lsp parse
--------------------------------------------------

local p_helper = require("nvim-completor/helper")

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
private.complete_item_lsp2vim = function(ctx, item)
	local word = item['label']
    local abbr = item['label']
    local menu = ""
	local user_data = {}


	if item['insertText'] ~= nil and item['insertText'] ~= "" then
        word = item['insertText'] -- 带有snippet
	end

	if item['textEdit'] ~= nil then
		user_data.line = item['textEdit']['range']['start']['line']
		user_data.bno = ctx.bno

		local new_text = item['textEdit']['newText']
		local typed_len = ctx.typed:len()
		-- lsp range zero-base pos: start + 1 - 1
		local front  = item['textEdit']['range']['start']['character']
		if front < typed_len then
			user_data.content = ctx.typed:sub(1, front) .. new_text
		else
			user_data.content = ctx.typed .. new_text
		end
		-- 补全后光标的位置
		user_data.col = user_data.content:len()

		-- zero-based exclude: tail + 1 + 1 - 1
		local tail = item['textEdit']['range']['end']['character'] + 1
		if tail < typed_len then
			user_data.content = user_data.content .. ctx.typed:sub(tail)
		end

		-- ctx.col 补全触发最后一个字符的位置
		if front < ctx.col then
			word = new_text:sub(ctx.col - front + 1)
		end
    end

	if item['detail'] ~= nil then
		abbr = abbr .. ' ' .. item['detail']
	end

	if item.kind ~= nil then
		menu = private.get_kind_text(item.kind)
	end

	local ud = p_helper.json_encode(user_data)
    return {word = word, abbr = abbr, menu = menu, icase = 1, dup = 0, user_data = ud}
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
	local user_data = p_helper.json_decode(ud)
	if user_data == nil then
		return
	end
	if user_data.line == nil then
		return
	end
	log.debug(user_data)
	local bno = user_data.bno
	local line = user_data.line
	local content = user_data.content
	local col = user_data.col

	vim.api.nvim_buf_set_lines(bno, line, line + 1, false, {content})
end

return module
