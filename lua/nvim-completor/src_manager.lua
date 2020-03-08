--------------------------------------------------
--    LICENSE: MIT
--     Author: Cosson2017
--    Version: 0.3
-- CreateTime: 2019-03-06 11:22:55
-- LastUpdate: 2019-03-06 11:22:55
--       Desc: core of complete framework
--------------------------------------------------

local semantics = require("nvim-completor/semantics")

local complete_src = {
	public = {},
	kindless = {},
}

function complete_src:add_src(handle, kind)
	if kind == nil or kind == "" then
		table.insert(self.kindless, handle)
		return
	end

	if kind == "public" then
		table.insert(self.public, handle)
		return
	end

	if self[kind] == nil then
		self[kind] = {}
	end
	table.insert(self[kind], handle)
end

function complete_src:has_complete_src()
	local cur_ft = semantics.get_ft()
	if #self.public > 0 then
		return true
	end

	if self[cur_ft] and #self[cur_ft] > 0 then
		return true
	end

	return false
end

function complete_src:call_src(ctx)
	for  _, handle in pairs(self.public) do
		handle(ctx)
	end

	local cur_ft = semantics.get_ft()
	local handles = self[cur_ft]
	if handles then
		for _, handle in pairs(handles) do
			handle(ctx)
		end
	end
end



return {
	reset = function() complete_engine:reset() end,
	text_changed = function() complete_engine:text_changed() end,
	add_complete_items = function(ctx, items) complete_engine:add_complete_items(ctx, items) end,
	add_src = function(handle, src_kind) complete_src:add_src(handle, src_kind) end,
}
