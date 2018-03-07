--------------------------------------------------
--    LICENSE: 
--     Author: 
--    Version: 
-- CreateTime: 2018-03-04 22:53:58
-- LastUpdate: 2018-03-04 22:53:58
--       Desc: 
--------------------------------------------------

local util = require("util")
local api = require("api")
local fuzzy = require("fuzzy_match")
local ft = require("ft")
local lsp = require("complete-lsp")
-- module name
local complete = {}

-- 匹配方法
local fuzzy_match = fuzzy.head_fuzzy_match
local ctx = api.context:new()
local items = {}

local _kind_text_mappings = {
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
 
function _get_kind_text(item)
	local index = item['kind']
	if index == nil then
		return ''
	end
	local t = _kind_text_mappings[index]
	if t == nil then
		return ''
	end
	return t
end

local function _format_completion_item(item)
	if item['insertText'] ~= nil and item['insertText'] ~= "" then
        if item['insertTextFormat'] ~= nil and item['insertTextFormat'] ~= 1 then
            local word = item['label']
        else
            local word = item['insertText']
        end
        local abbr = item['label']
    else
        local word = item['label']
        local abbr = ''
    end
    local menu = _get_kind_text(item)
    return {word = word, abbr = abbr, menu = menu, icase = 1, dup = 0}
end

-- 获取匹配上下文
local function _get_context()
	local pos = api.get_curpos()
	local cur_ctx = api.context:new()

	cur_ctx.bname = api.get_bufname()
	cur_ctx.bno = pos['buf']
	cur_ctx.line = pos['line']
	cur_ctx.ft = api.get_filetype()
	cur_ctx.typed = api.cursor_pre_content()
	cur_ctx.start = util.last_word_start(cur_ctx.typed)

	return cur_ctx
end


local function _handle_completion(ctx, data)
	if data ~= nil then
		for k, v in ipairs(data) do
			local item = _get_kind_text(v)
			table.insert(items, item)
		end
	end

	local tlen = ctx.typed:len()
	local pattern = ctx.typed:sub(ctx.start, tlen)
	if pattern ~= nil and pattern:match('[%w_]+'):len() > 0 then
		local candi = fuzzy_match(items, pattern)
		--api.complete(ctx.start, candi)
		api.complete(ctx.start, candi)
	else
		api.complete(ctx.start, items)
	end

end

local function _text_changed()
	local pre_input = api.cursor_pre_content()
	local plen = pre_input:len()
	local lchar = pre_input:sub(plen,plen)
	if ft.trigger(lchar) == false then
		return
	end

	cur_ctx = _get_context()
	if ctx:eq(cur_ctx) == false then
		ctx = cur_ctx
		items = {}
		lsp.lsp_complete(ctx)
	else
		_handle_completion(ctx, nil)	
	end
end


complete.text_changed = _text_changed
complete.handle_completion = _handle_completion

return complete
