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
local context = require('nvim-completor/context')
local completor = require('nvim-completor/completor')

module.ctx = nil

function _text_changed()
	local cur_ctx = context:new()
	if module.ctx and vim.deep_equal(module.ctx, cur_ctx) then
		return
	end

	module.ctx = cur_ctx
	completor.text_changed(module.ctx)
end

module.on_insert = function()
	_text_changed()
	print('insert')
end

module.on_leave = function()
	module.ctx = nil
	print('leave')
end

module.on_text_changed_i = function()
	_text_changed()

	print('on_text_changed_i position ' .. vimfn.json_encode(vim.lsp.util.make_position_params()))
end

module.on_text_changed_p = function()
	print('on_text_changed_p position ' .. vimfn.json_encode(vim.lsp.util.make_position_params()))
	local complete_info = vimfn.complete_info({'pum_visible', 'selected'})
	if complete_info.pum_visible == 1 and complete_info.selected ~= -1 then
		return
	end

	_text_changed()
end

module.on_complete_done = function()
	local complete_item = api.nvim_get_vvar('completed_item')
	if vim.tbl_isempty(complete_item) then
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
