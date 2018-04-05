--------------------------------------------------
--    LICENSE: MIT
--     Author: Cosson2017
--    Version: 0.1
-- CreateTime: 2018-03-07 13:17:08
-- LastUpdate: 2018-03-19 13:10:44
--       Desc: 
--------------------------------------------------

local api = require("api")
local vim_lsp = require("vim-lsp")
local module = {} -- { server_name: 1 }

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
 
function _get_kind_text(index)
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
	local word = item['label']
    local abbr = item['label']
    local menu = ""
	local start = -1


	if item['insertText'] ~= nil and item['insertText'] ~= "" then
        word = item['insertText'] -- 带有snippet
	elseif item['textEdit'] ~= nil then
		word = item['textEdit']['newText']
		start = item['textEdit']['range']['start']['character']
    end
	if item['detail'] ~= nil then
		abbr = abbr .. ' ' .. item['detail']
	end

	if item.kind ~= nil then
		menu = _get_kind_text(item.kind)
	end

    return {item = {word = word, abbr = abbr, menu = menu, icase = 1, dup = 0}, start = start}
end


local function _format_completion(data)
	if data == nil then
		return 
	end

	if data['error'] ~= nil then
		return
	end
	if data['response'] == nil then
		return
	end

	local result = data['response']['result']
	if result == nil then
		return
	end

	if result['items'] == nil then
		local incomplete = 0
	else
		result = result['items']
		local incomplete = result['isIncomplete']
	end

	local items = {}
	local start = -1
	for k, v in pairs(result) do
		local item = _format_completion_item(v)
		start = item.start
		table.insert(items, item.item)
	end
	if start ~= -1 then
		start = start + 1
	end
	return {items = items, start = start}
end


local function _lsp_complete(ctx)
	local server_name = vim_lsp.get_cur_server()
	if server_name == nil then
		vim.api.nvim_out_write("servers is nil\n")
		return
	end

	api.lsp_complete(server_name, ctx)
end

module.lsp_complete = _lsp_complete
module.format_completion = _format_completion

return module
