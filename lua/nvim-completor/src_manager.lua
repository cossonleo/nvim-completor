--------------------------------------------------
--    LICENSE: MIT
--     Author: Cosson2017
--    Version: 0.3
-- CreateTime: 2019-03-06 11:22:55
-- LastUpdate: 2019-03-06 11:22:55
--       Desc: core of complete framework
--------------------------------------------------

local semantics = require("nvim-completor/semantics")

local complete_src = {}

function complete_src:add_src(ident, handle, kind)
	if not kind or kind == "" then
		if not complete_src["public"] then
			complete_src["public"] = {}
		end

		complete_src.public[ident] = handle
		return
	end

	if self[kind] == nil then
		self[kind] = {}
	end
	self[kind][ident] = handle
end

function complete_src:has_complete_src()
	local cur_ft = semantics.get_ft()
	return self.public or self[cur_ft]
end

function complete_src:call_src(ctx)
	local p = self.public
	if p then
		for  _, handle in pairs(p) do
			handle(ctx)
		end
	end

	local cur_ft = semantics.get_ft()
	local handles = self[cur_ft]
	if handles then
		for _, handle in pairs(handles) do
			handle(ctx)
		end
	end
end

return complete_src
