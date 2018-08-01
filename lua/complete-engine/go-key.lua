--------------------------------------------------
--    LICENSE: MIT
--     Author: Cosson2017
--    Version: 0.3
-- CreateTime: 2018-07-23 15:57:53
-- LastUpdate: 2018-07-23 15:57:53
--       Desc: go key length > 3 show
--------------------------------------------------

local module = {}
local private = {}

local cm = require("nvim-completor/complete")
local helper = require("nvim-completor/helper")
local log = require("nvim-completor/log")

private.keys = nil

private.get_keys = function()
	if private.keys ~= nil and #private.keys > 0 then
		return private.keys
	end

	private.keys = {}
	table.insert(private.keys, {word = "type", abbr = "type", menu = "key", icase = 1, dup = 0})
	table.insert(private.keys, {word = "struct", abbr = "struct", menu = "key", icase = 1, dup = 0})
	table.insert(private.keys, {word = "interface", abbr = "interface", menu = "key", icase = 1, dup = 0})
	table.insert(private.keys, {word = "import", abbr = "import", menu = "key", icase = 1, dup = 0})
	table.insert(private.keys, {word = "package", abbr = "package", menu = "key", icase = 1, dup = 0})
	table.insert(private.keys, {word = "const", abbr = "const", menu = "key", icase = 1, dup = 0})
	table.insert(private.keys, {word = "return", abbr = "return", menu = "key", icase = 1, dup = 0})
	table.insert(private.keys, {word = "chan", abbr = "chan", menu = "key", icase = 1, dup = 0})
	table.insert(private.keys, {word = "continue", abbr = "continue", menu = "key", icase = 1, dup = 0})
	table.insert(private.keys, {word = "break", abbr = "break", menu = "key", icase = 1, dup = 0})
	table.insert(private.keys, {word = "select", abbr = "select", menu = "key", icase = 1, dup = 0})
	table.insert(private.keys, {word = "case", abbr = "case", menu = "key", icase = 1, dup = 0})
	table.insert(private.keys, {word = "switch", abbr = "switch", menu = "key", icase = 1, dup = 0})
	table.insert(private.keys, {word = "range", abbr = "range", menu = "key", icase = 1, dup = 0})
	table.insert(private.keys, {word = "func", abbr = "func", menu = "key", icase = 1, dup = 0})
	return private.keys
end

private.go_key_complete = function(ctx)
	log.debug("go key cm trigger")
	local ft = helper.get_filetype()
	if ft == nil and ft ~= "go" then
		return
	end

	local typed = helper.get_cur_line(ctx.replace_col)
	if typed == nil or string.len(typed) == 0 or string.find(typed, "%.[%w_]*$") ~= nil then
		return
	end
	local all_keys = private.get_keys()
	local candi = helper.head_fuzzy_match(all_keys, typed)
	cm.add_candidate(ctx, candi)
	return
end

private.init = function()
	cm.add_engine(private.go_key_complete, "go")
	log.debug("add go key complete engine success")
end

module.init = private.init
return module
