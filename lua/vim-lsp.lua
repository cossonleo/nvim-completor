--------------------------------------------------
--    LICENSE: MIT
--     Author: Cosson2017
--    Version: 0.2
-- CreateTime: 2018-03-19 12:23:46
-- LastUpdate: 2018-03-19 12:23:46
--       Desc: 
--------------------------------------------------

local module = {}

local api = require("api")
local servers = {} -- map[buftype]servername

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
 

local function func_server_initialized()
    local server_names = vim.api.nvim_call_function('lsp#get_server_names', {})
    for sk, server_name in ipairs(server_names) do
		local info = vim.api.nvim_call_function('lsp#get_server_info', {server_name})
		if info['whitelist'] ~= nil then
			for k, bt in ipairs(info['whitelist']) do
				if servers[bt] == nil then
					local capabilites = vim.api.nvim_call_function('lsp#get_server_capabilities', {server_name})
					if capabilites['completionProvider'] ~= nil then
						if bt ~= "" then
							servers[bt] = server_name
						end
					end
				end
			end
		end
    end
end

local function func_server_exited()
	servers = {}
end


local function func_get_cur_server()
	local bt = api.get_filetype()
	return servers[bt]
end

function func_get_kind_text(index)
	if index == nil then
		return ''
	end
	local t = _kind_text_mappings[index]
	if t == nil then
		return ''
	end
	return t
end

local function func_format_item(item)
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
		menu = func_get_kind_text(item.kind)
	end

    return {item = {word = word, abbr = abbr, menu = menu, icase = 1, dup = 0}, start = start}
end


local function func_format_completion(data)
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

	local format_res = {}
	format_res.incomplete = result['isIncomplete']
	format_res.items = {}
	format_res.start = -1

	result = result['items']
	for k, v in pairs(result) do
		local item = func_format_item(v)
		format_res.start = item.start
		table.insert(format_res.items, item.item)
	end

	if format_res.start ~= -1 then
		format_res.start = format_res.start + 1
	end
	return format_res
end


local function func_lsp_complete(ctx)
	local server_name = vim_lsp.get_cur_server()
	if server_name == nil then
		vim.api.nvim_out_write("servers is nil\n")
		return false
	end

	api.lsp_complete(server_name, ctx)
	return true
end

local function func_handle_lsp_complete(ctx, data)
	items = func_format_completion(data)
	if #items.items == 0 then
		return
	end
end

module.lsp_complete = func_lsp_complete
module.handle_lsp_complete = func_handle_lsp_complete

module.server_initialized = func_server_initialized
module.server_exited = func_server_exited

return module
