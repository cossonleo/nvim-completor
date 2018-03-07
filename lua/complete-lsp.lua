--------------------------------------------------
--    LICENSE: MIT
--     Author: Cosson2017
--    Version: 0.1
-- CreateTime: 2018-03-07 13:17:08
-- LastUpdate: 2018-03-07 13:17:08
--       Desc: 
--------------------------------------------------

api = require("api")

local lsp = {} -- { server_name: 1 }


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

return lsp
