--------------------------------------------------
--    LICENSE: MIT
--     Author: Cosson2017
--    Version: 0.2
-- CreateTime: 2018-03-19 12:23:46
-- LastUpdate: 2018-03-19 12:23:46
--       Desc: 
--------------------------------------------------

local module = {}
local private = {}

local ncm = require("nvim-completor/complete")
local helper = require("nvim-completor/helper")
local log = require("nvim-completor/log")

private.servers = {} -- map[buftype]servername

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
 
private.call_lsp_complete = function(server_name, ctx)
	if ctx == nil then
		log.debug("private.call_lsp_complete ctx is nil")
		return
	end
	vim.api.nvim_call_function('vim_lsp#lsp_complete', {server_name, ctx})
end

module.get_whitelist_servers = function()
	return vim.api.nvim_call_function('lsp#get_whitelisted_servers', {})
end

module.server_initialized = function()
	log.debug("server init start")
    local server_names = vim.api.nvim_call_function('lsp#get_server_names', {})
    for sk, server_name in pairs(server_names) do
		local info = vim.api.nvim_call_function('lsp#get_server_info', {server_name})
		if info['whitelist'] ~= nil then
			for k, bt in pairs(info['whitelist']) do
				if private.servers[bt] == nil then
					local capabilites = vim.api.nvim_call_function('lsp#get_server_capabilities', {server_name})
					if capabilites['completionProvider'] ~= nil then
						if bt ~= "" then
							private.servers[bt] = server_name
						end
					end
				end
			end
		end
    end
	log.debug("server init success")
end

module.server_exited = function()
	private.servers = {}
end


private.get_cur_server = function()
	local bt = helper.get_filetype()
	return private.servers[bt]
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
	if start ~= -1 then
		if start < ctx.replace_col then
			word = string.sub(word, ctx.replace_col - start - 1)
		end
	end

    return {word = word, abbr = abbr, menu = menu, icase = 1, dup = 0}
end


private.format_completion = function(ctx, data)
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

	local items = {}
	local inc = result['isIncomplete']

	result = result['items']
	for k, v in pairs(result) do
		local item = private.format_item(ctx, v)
		table.insert(items, item)
	end
	return {items = items, inc = inc}
end

module.handle_lsp_complete = function(ctx, data)
	local items = private.format_completion(ctx, data)
	if #items.items == 0 then
		return
	end

	log.debug("items len: %d", #items.items)

	ncm.add_candidate(ctx, items.items, items.inc)
end

private.lsp_complete = function(ctx)
	log.debug("vim-lsp trigger")
	if ctx == nil then
		log.debug("private.lsp_complete ctx is nil")
		return false
	end
	local server_name = private.get_cur_server()
	if server_name == nil then
		log.debug("vim-lsp server_name is nil")
		return false
	end

	private.call_lsp_complete(server_name, ctx)
	return true
end

-- 添加引擎到complete中
ncm.add_engine(private.lsp_complete, "all")
log.debug("add vim-lsp engine success")

return module
