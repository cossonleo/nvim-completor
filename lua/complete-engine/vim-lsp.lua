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
local lsp = require("nvim-completor/lsp-format")

private.servers = {} -- map[buftype]servername

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

module.handle_lsp_complete = function(ctx, data)
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

	local incomplete = result['isIncomplete']
	local data_items = result['items']
	if data_items == nil then
		data_items = result
	end

	local complete_items = lsp.parse_completion_resp(ctx, data_items)
	if complete_items == nil then
		return
	end

	ncm.add_candidate(ctx, complete_items, incomplete)
end

private.lsp_complete = function(ctx)
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

private.init = function()
	-- 添加引擎到complete中
	ncm.add_engine(private.lsp_complete, "all")
	log.debug("add vim-lsp engine success")
end

module.init = private.init
return module
