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
local vimfn = vim.fn
local semantics = require('nvim-completor/semantics')

--local complete_core = require("nvim-completor/core")
--local engine = complete_core

module.on_insert = function()
	print('insert')
end

module.on_leave = function()
	print('leave')
end

module.on_text_changed_i = function()

	print('on_text_changed_i position ' .. vimfn.json_encode(vim.lsp.util.make_position_params()))
	--print('on_text_changed_i ' .. #api.nvim_get_vvar('completed_item'))
end

module.on_text_changed_p = function()
	print('on_text_changed_p position ' .. vimfn.json_encode(vim.lsp.util.make_position_params()))
	local complete_info = vimfn.complete_info({'pum_visible', 'selected'})
	if complete_info.pum_visible == 1 and complete_info.selected ~= -1 then
		return
	end

	-- 刷新匹配 -- 模糊匹配
	--print('on_text_changed_p complete info ' .. vimfn.json_encode(complete_info))
end

module.on_complete_done = function()
	if #api.nvim_get_vvar('completed_item') == 0 then
		return
	end

	-- 补全 写入选中项
	print('on_complete_done ' .. vimfn.json_encode(api.nvim_get_vvar('completed_item')))
end

module.on_buf_enter = function()
	local ft = api.nvim_buf_get_option(0, 'filetype')
	semantics.set_ft(ft)
end

module.on_load = function()
	api.nvim_set_option('cot', "menuone,preview,noselect,noinsert")
end

return module
