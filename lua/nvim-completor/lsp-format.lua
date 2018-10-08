--------------------------------------------------
--    LICENSE: 
--     Author: 
--    Version: 
-- CreateTime: 2018-08-01 09:55:03
-- LastUpdate: 2018-08-01 09:55:03
--       Desc: format lsp protocol completion items
--------------------------------------------------

local module = {}
local private = {}

local log = require("nvim-completor/log")
local fuzzy = require("nvim-completor/fuzzy-match")

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

private.format_item = function(ctx, item)
	local word = item['label']
    local abbr = item['label']
    local menu = ""
	local start = -1


	if item['insertText'] ~= nil and item['insertText'] ~= "" then
        word = item['insertText'] -- 带有snippet
	end

	if item['textEdit'] ~= nil then
		word = item['textEdit']['newText']
		start = item['textEdit']['range']['start']['character']
    end
	if item['detail'] ~= nil then
		abbr = abbr .. ' ' .. item['detail']
	end

	if item.kind ~= nil then
		menu = private.get_kind_text(item.kind)
	end

	-- 当前不考虑start > ctx.col情况, 如果需要再进行处理
	if start ~= -1 then
		if start < ctx.replace_col then
			word = string.sub(word, ctx.replace_col - start - 1)
		end
	end

    return {word = word, abbr = abbr, menu = menu, icase = 1, dup = 0}
end

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

private.format_item = function(ctx, item)
	local word = item['label']
    local abbr = item['label']
    local menu = ""
	local start = -1


	if item['insertText'] ~= nil and item['insertText'] ~= "" then
        word = item['insertText'] -- 带有snippet
	end

	if item['textEdit'] ~= nil then
		word = item['textEdit']['newText']
		start = item['textEdit']['range']['start']['character']
    end
	if item['detail'] ~= nil then
		abbr = abbr .. ' ' .. item['detail']
	end

	if item.kind ~= nil then
		menu = private.get_kind_text(item.kind)
	end

	-- 当前不考虑start > ctx.col情况, 如果需要再进行处理
	-- start 从零开始
	-- replace_col 从一开始
	-- lua的下标从一开始
	if start ~= -1 then
		if start + 1 < ctx.replace_col then
			--word = string.sub(word, ctx.replace_col - start - 1)
			word = string.sub(word, ctx.replace_col - start)
			--word = string.sub(word, ctx.replace_col - start + 1)
		end
	end

    return {word = word, abbr = abbr, menu = menu, icase = 1, dup = 0}
end


private.parse_completion_resp = function(ctx, data)
	local items = {}
	--local inc = data['isIncomplete']

	--local result = data['items']
	--if result == nil then
	--	result = data
	--end
	for _, v in pairs(data) do
		local item = private.format_item(ctx, v)
		table.insert(items, item)
	end

	return items
end

module.parse_completion_resp = private.parse_completion_resp
return module
