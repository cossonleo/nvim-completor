--------------------------------------------------
--    LICENSE: MIT
--     Author: Cosson2017
--    Version: 0.3
-- CreateTime: 2019-03-07 13:35:53
-- LastUpdate: 2019-03-07 13:35:53
--       Desc: lsp parse
--------------------------------------------------


local module = {}
local private = {}

--local log = require("nvim-completor/log")
--local fuzzy = require("nvim-completor/fuzzy-match")
local lang = require("nvim-completor/lang-spec")

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

		local new_text = item['textEdit']['newText']
		local typed_len = ctx.typed:len()
		-- lsp range zero-base pos: start + 1 - 1
		local front  = item['textEdit']['range']['start']['character']
		if front < typed_len then
			user_data.context = ctx.typed:sub(1, front) .. new_text
		else
			user_data.context = ctx.typed .. new_text
		end
		-- 补全后光标的位置
		user_data.col = user_data.context:len()

		-- zero-based exclude: tail + 1 + 1 - 1
		local tail = item['textEdit']['range']['end']['character'] + 1
		if tail < typed_len then
			user_data.context = user_data .. ctx.typed:sub(tail)
		end

		-- ctx.col 补全触发位置即光标的位置
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

    return {word = word, abbr = abbr, menu = menu, icase = 1, dup = 0, user_data = user_data}
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

return module
