--------------------------------------------------
--    LICENSE: MIT
--     Author: Cosson2017
--    Version: 0.1
-- CreateTime: 2018-09-26 15:08:02
-- LastUpdate: 2018-09-26 15:08:02
--       Desc: LanguageClient-neovim
--------------------------------------------------

local module = {}
local private = {}

local ncm = require("nvim-completor/core")
--local helper = require("nvim-completor/helper")
local log = require("nvim-completor/log")
local lsp = require("nvim-completor/lsp")

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
	local result = data['result']
	if result == nil then
		return
	end

	local incomplete = result['isIncomplete']
	local data_items = result['items']
	if data_items == nil then
		data_items = result
	end
	if #data_items == 0 then
		return
	end
	local complete_items = lsp.complete_items_lsp2vim(ctx, data_items)
	if complete_items == nil then
		return
	end

	if incomplete == true then
		ctx.incomplete = true
	end

	ncm.add_complete_items(ctx, complete_items)
end

private.init = function()
	ncm.add_engine(private.complete, "public")
	log.info("add lsp-lc engine success")
end

module.complete_callback = private.complete_callback
module.init = private.init

return module
