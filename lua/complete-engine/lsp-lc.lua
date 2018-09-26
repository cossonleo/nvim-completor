--------------------------------------------------
--    LICENSE: 
--     Author: 
--    Version: 
-- CreateTime: 2018-09-26 15:08:02
-- LastUpdate: 2018-09-26 15:08:02
--       Desc: 
--------------------------------------------------

local module = {}
local private = {}

local ncm = require("nvim-completor/complete")
local helper = require("nvim-completor/helper")
local log = require("nvim-completor/log")
local lsp = require("nvim-completor/lsp-format")

private.call_lsp_complete = function(ctx)
	if ctx == nil then
		log.debug("lsp-lc private.call_lsp_complete ctx is nil")
		return
	end
	vim.api.nvim_call_function('lsp_lc#complete', {ctx})
end

private.complete = function(ctx)
	if ctx == nil then
		return
	end
	private.call_lsp_complete(ctx)
end

private.complete_callback = function(ctx, data)
	if data['result'] == nil then
		return
	end
	local result = data['result']

	local items = lsp.parse_completion_resp(ctx, result)
	if items == nil or #items.items == 0 then
		return
	end

	ncm.add_candidate(ctx, items.items, items.inc)
end

private.init = function()
	ncm.add_engine(private.complete, "all")
	log.debug("add lsp-lc engine success")
end

module.complete_callback = private.complete_callback
module.init = private.init

return module
