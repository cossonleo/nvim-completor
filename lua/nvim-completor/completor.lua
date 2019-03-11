--------------------------------------------------
--    LICENSE: MIT
--     Author: Cosson2017
--    Version: 0.3
-- CreateTime: 2019-03-11 11:10:38
-- LastUpdate: 2019-03-11 11:10:38
--       Desc: out interface
--------------------------------------------------

local core = require("nvim-completor/core")
local lsp = require("nvim-completor/lsp")
local state = require("nvim-completor/state")


local module = {}

module.leave = function()
	core.reset()
end

module.enter = function()
	state.set_ft()
	core.text_changed()
end

module.text_changed = function()
	core.text_changed()
end

module.complete_done = function(user_data)
	lsp.apply_complete_user_data(user_data)
end

module.add_complete_items = function(ctx, items)
	core.add_complete_items(ctx, items)
end

module.add_engine = function(handle, src_kind)
	core.add_src(handle, src_kind)
end

return module
