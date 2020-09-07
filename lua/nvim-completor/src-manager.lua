--------------------------------------------------
--    LICENSE: MIT
--     Author: Cosson2017
--    Version: 0.3
-- CreateTime: 2019-03-06 11:22:55
-- LastUpdate: 2019-03-06 11:22:55
--       Desc: core of complete framework
--------------------------------------------------

local log = require("nvim-completor/log")

local complete_src = {
	public = {}
}

function complete_src:add_src(ident, handle, kind)
	log.trace("add complete src", ident, " ", kind)
	if not kind or kind == "" then
		self.public[ident] = handle
	else
		self[kind] = self[kind] or {}
		self[kind][ident] = handle
	end
	log.debug("complete src", self)
end

function complete_src:has_complete_src()
	if self.public then return true end
	local cur_ft = vim.bo.filetype
	return self[cur_ft] and true or false
end

function complete_src:call_src(ctx, idents)
	log.trace("call src, idents: ", idents)
	log.debug("self.public", self.public)
	for  k, handle in pairs(self.public) do
		if not idents or vim.tbl_contains(idents, k) then
			log.trace("call src: ", k)
			handle(ctx)
		end
	end

	local cur_ft = vim.bo.filetype
	local handles = self[cur_ft] or {}
	for k, handle in pairs(handles) do
		if not idents or vim.tbl_contains(idents, k) then
			log.trace("call src: ", k)
			handle(ctx)
		end
	end
end

return complete_src
