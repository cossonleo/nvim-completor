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
		-- lsp range pos: zero-base
		start = item['textEdit']['range']['start']['character'] + 1
	else
		start = lang.fire_postion(ctx.col)
		log.debug("start: %d", start)
		if start == 0 then
			return nil
		end
    end
	if item['detail'] ~= nil then
		abbr = abbr .. ' ' .. item['detail']
	end

	if item.kind ~= nil then
		menu = private.get_kind_text(item.kind)
	end

	local comp_start = ctx.col + 1
	log.debug("cs: %d", comp_start)
	if comp_start < start then
		return nil
	end
	if start < comp_start then
		word = string.sub(word, comp_start - start + 1)
	end

    return {word = word, abbr = abbr, menu = menu, icase = 1, dup = 0}
end


private.parse_completion_resp = function(ctx, data)
	local items = {}
	for _, v in pairs(data) do
		local item = private.format_item(ctx, v)
		if item ~= nil then
			table.insert(items, item)
		end
	end

	return items
end

module.parse_completion_resp = private.parse_completion_resp
return module
