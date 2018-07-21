--------------------------------------------------
--    LICENSE: MIT
--     Author: Cosson2017
--    Version: 0.2
-- CreateTime: 2018-03-19 12:23:46
-- LastUpdate: 2018-03-19 12:23:46
--       Desc: 
--------------------------------------------------

local module = {}

local cm = require("nvim-completor/candidate-manager")
local helper = require("nvim-completor/helper")
local servers = {} -- map[buftype]servername
local l_ctx = nil

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
	local bt = helper.get_filetype()
	return servers[bt]
end

local function func_get_kind_text(index)
	if index == nil then
		return ''
	end
	local t = _kind_text_mappings[index]
	if t == nil then
		return ''
	end
	return t
end

local function func_format_item(ctx, item)
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

	-- 当前不考虑start > ctx.col情况, 如果需要再进行处理
	if start ~= nil or start ~= -1 then
		if start < ctx.replace_col then
			word = string.sub(word, ctx.replace_col - start - 1)
		end
	end

    return {word = word, abbr = abbr, menu = menu, icase = 1, dup = 0}
end


local function func_format_completion(ctx, data)
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
	local inc = result['isIncomplete']

	result = result['items']
	for k, v in pairs(result) do
		local item = func_format_item(ctx, v)
		table.insert(format_res, item)
	end
	return {result = format_res, inc = inc}
end

local function func_handle_lsp_complete(ctx, data)
	local result = func_format_completion(ctx, data)
	if #result.result == 0 then
		return
	end

	cm.set_incomplete(result.inc)
	cm.add_candidate(result.result)
end

local function func_lsp_complete(ctx)
	local server_name = vim_lsp.get_cur_server()
	if server_name == nil then
		vim.api.nvim_out_write("servers is nil\n")
		return false
	end

	helper.lsp_complete(server_name, ctx)
	return true
end

module.lsp_complete = func_lsp_complete
module.handle_lsp_complete = func_handle_lsp_complete

module.server_initialized = func_server_initialized
module.server_exited = func_server_exited

return module
