--------------------------------------------------
--    LICENSE: 
--     Author: 
--    Version: 
-- CreateTime: 2018-07-31 23:08:48
-- LastUpdate: 2018-07-31 23:08:48
--       Desc: 
--------------------------------------------------

local module = {}
local private = {}

local ncm = require("nvim-completor/complete")
local helper = require("nvim-completor/helper")
local log = require("nvim-completor/log")

private.call_lsp_complete = function(ctx)
	if ctx == nil then
		log.debug("vim-lsc private.call_lsp_complete ctx is nil")
		return
	end
	vim.api.nvim_call_function('vim_lsc#complete', {ctx})
end

private.complete = function(ctx)
	if ctx == nil then
		return
	end
	private.call_lsp_complete(ctx)
end

private.complete_callback = function(ctx, ret_data)
end

-- 添加引擎到complete中
ncm.add_engine(private.complete, "all")
log.debug("add vim-lsc engine success")

return module
