--------------------------------------------------
--    LICENSE: 
--     Author: 
--    Version: 
-- CreateTime: 2020-03-08 11:27:15
-- LastUpdate: 2020-03-08 11:27:15
--       Desc: 
--------------------------------------------------

local module = {}
local api = vim.api
local semantics = require('nvim-completor/semantics')

--local complete_core = require("nvim-completor/core")
--local engine = complete_core

module.on_enter = function()

end

module.on_insert = function()
	print('insert')
end

module.on_leave = function()
	print('leave')
end

module.on_text_changed_i = function()
	print('on_text_changed_i')
end

module.on_text_changed_p = function()
	local complete_info = vim.fn.complete_info({'pum_visible', 'selected'})
	print('on_text_changed_p')
end

module.on_complete_done = function()
	print('on_complete_done')
end

module.on_buf_enter = function()
	local ft = api.nvim_buf_get_option(0, 'filetype')
	semantics.set_ft(ft)
end

module.on_load = function()
	api.nvim_set_option('cot', "menuone,preview,noselect,noinsert")
end

return module
