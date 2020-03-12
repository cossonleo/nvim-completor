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
local log = require('nvim-completor/log')
local ncp_lsp = require("nvim-completor/lsp")

module.ctx = nil

function module:reset()
	self.ctx = nil
end

function module:text_changed()
	local cur_ctx = context:new()
	if module.ctx and vim.deep_equal(module.ctx, cur_ctx) then
		return
	end

	self.ctx = cur_ctx
	completor.text_changed(module.ctx)
end

module.on_text_changed_i = function()
	module:text_changed()

	-- print('on_text_changed_i position ' .. vimfn.json_encode(vim.lsp.util.make_position_params()))
end

module.on_text_changed_p = function()
	print('on_text_changed_p position ' .. vimfn.json_encode(vim.lsp.util.make_position_params()))
	local complete_info = vimfn.complete_info({'pum_visible', 'selected'})
	if complete_info.pum_visible == 1 and complete_info.selected ~= -1 then
		return
	end

	module:text_changed()
end

module.on_complete_done = function()
	local complete_item = api.nvim_get_vvar('completed_item')
	if type(complete_item) ~= "table" or vim.tbl_isempty(complete_item) then
		return
	end
	ncp_lsp.apply_complete_user_data(complete_item.user_data)
	-- 补全 写入选中项
	print('on_complete_done ' .. vimfn.json_encode(api.nvim_get_vvar('completed_item')))
end

module.on_insert = function()
	module:text_changed()
end


module.on_leave = function()
	module:reset()
	completor.reset()
end

module.on_buf_enter = function()
	local ft = api.nvim_buf_get_option(0, 'filetype')
	semantics.set_ft(ft)
end

module.on_load = function()
	log.set_level(1)
	api.nvim_set_option('cot', "menuone,noselect,noinsert")
	log.info("nvim completor loaded finish")
end

return module
