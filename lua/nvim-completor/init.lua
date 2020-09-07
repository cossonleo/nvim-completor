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
local context = require('nvim-completor/context')
local log = require('nvim-completor/log')
local ncp_lsp = require("nvim-completor/lsp")
local snippet = require("nvim-completor/snippet")

local _completor = require('nvim-completor/completor')

local _ctx = nil
local _last_selected = -1

local function reset()
	_ctx = nil
	_last_selected = -1
	_completor.reset()
end

local function text_changed()
	if _ctx and _ctx.changedtick == vim.b.changedtick then
	 	log.trace("repeat trigger text changed")
	 	return
	end

	_ctx = context.new()
	_last_selected = -1
	_completor.text_changed(_ctx)
end

module.on_text_changed_i = function()
	log.trace("text changed i")
	text_changed()
end

module.on_text_changed_p = function()
	log.trace("text changed p")
	local complete_info = vimfn.complete_info({'pum_visible', 'selected'})
	if complete_info.pum_visible then
		if complete_info.selected ~= -1 then
			module.on_select_item()
			_last_selected = 1
			log.trace("on select item")
			return
		elseif _last_selected ~= -1 then
			_last_selected = -1
			_ctx:restore_ctx()
			log.trace("on select item with not selected")
			return
		end
	end

	text_changed()
end

module.on_complete_done = function()
	log.trace("on complete done")
	local complete_item = vim.v.completed_item
	if type(complete_item) ~= "table" or vim.tbl_isempty(complete_item) then
		return
	end
	--ncp_lsp.apply_complete_user_data(complete_item.user_data)
	ncp_lsp.apply_complete_user_edit(complete_item.user_data)
end

module.on_select_item = function()
	local complete_item = api.nvim_get_vvar('completed_item')
	if type(complete_item) ~= "table" or vim.tbl_isempty(complete_item) then
		return
	end
	log.trace("on select item trigger apply user data")
	ncp_lsp.apply_complete_user_edit(complete_item.user_data, true)
end

module.on_insert = function()
	log.trace("on insert")
	local ft = api.nvim_buf_get_option(0, 'filetype')
	text_changed()
end


module.on_insert_leave = function()
	log.trace("on insert leave")
	reset()
end

module.on_buf_enter = function()
end

module.on_load = function()
	log.trace("on load")
	log.set_level(4)
	api.nvim_set_option('cot', "menuone,noselect,noinsert")
	log.info("nvim completor loaded finish")
end

module.set_log_level = function(level)
	log.set_level(level)
end

module.jump_to_next_pos = function()
	snippet.jump_to_next_pos()
end

return module
