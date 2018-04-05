--------------------------------------------------
--    LICENSE: MIT
--     Author: Cosson2017
--    Version: 0.2
-- CreateTime: 2018-03-19 12:23:46
-- LastUpdate: 2018-03-19 12:23:46
--       Desc: 
--------------------------------------------------

local module = {}

local servers = {} -- map[buftype]servername
local api = require("api")

function module.server_initialized()
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

function module.server_exited()
	servers = {}
end


function module.get_cur_server()
	local bt = api.get_filetype()
	return servers[bt]
end

return module
