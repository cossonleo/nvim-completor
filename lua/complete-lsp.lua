--------------------------------------------------
--    LICENSE: MIT
--     Author: Cosson2017
--    Version: 0.1
-- CreateTime: 2018-03-07 13:17:08
-- LastUpdate: 2018-03-08 18:36:44
--       Desc: 
--------------------------------------------------

api = require("api")

local lsp = {} -- { server_name: 1 }

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


	if item['insertText'] ~= nil and item['insertText'] ~= "" then
        word = item['insertText'] -- 带有snippet
    end


	if item.kind ~= nil then
		menu = _get_kind_text(item.kind)
	end

    return {word = word, abbr = abbr, menu = menu, icase = 1, dup = 0}
end


local function _format_completion(data)
	if data == nil then
		api.echo_log("data is nil ")
		return 
	end

	if data['error'] ~= nil then
		api.echo_log("data result error")
		return
	end
	if data['response'] == nil then
		api.echo_log("response is nil")
		return
	end

	local result = data['response']['result']
	if result == nil then
		api.echo_log("result is nil")
		return
	end

	if result['items'] == nil then
		local incomplete = 0
	else
		result = result['items']
		local incomplete = result['isIncomplete']
	end

	local items = {}
	for k, v in pairs(result) do
		local item = _format_completion_item(v)
		table.insert(items, item)
	end
	return items
end


local function _lsp_complete(ctx)
	local servers = api.get_whitelist_servers()
	if servers[1] == nil  then
		return
	end

	api.lsp_complete(servers[1], ctx)

	--for k, s in ipairs(servers) do
	--end
end

lsp.lsp_complete = _lsp_complete
lsp.format_completion = _format_completion

return lsp
