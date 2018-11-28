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
local head_match = require("nvim-completor/head-fuzzy-match")

private.keys = {}

private.get_keys = function()
	if private.keys ~= nil and #private.keys > 0 then
		return private.keys
	end

	private.keys = {}
	table.insert(private.keys, {word = "break", abbr = "break", menu = "key", icase = 1, dup = 0})
	table.insert(private.keys, {word = "const", abbr = "const", menu = "key", icase = 1, dup = 0})
	table.insert(private.keys, {word = "continue", abbr = "continue", menu = "key", icase = 1, dup = 0})
	table.insert(private.keys, {word = "crate", abbr = "crate", menu = "key", icase = 1, dup = 0})
	table.insert(private.keys, {word = "else", abbr = "else", menu = "key", icase = 1, dup = 0})
	table.insert(private.keys, {word = "enum", abbr = "enum", menu = "key", icase = 1, dup = 0})
	table.insert(private.keys, {word = "extern", abbr = "extern", menu = "key", icase = 1, dup = 0})
	table.insert(private.keys, {word = "false", abbr = "false", menu = "key", icase = 1, dup = 0})
	table.insert(private.keys, {word = "impl", abbr = "impl", menu = "key", icase = 1, dup = 0})
	table.insert(private.keys, {word = "loop", abbr = "loop", menu = "key", icase = 1, dup = 0})
	table.insert(private.keys, {word = "match", abbr = "match", menu = "key", icase = 1, dup = 0})
	table.insert(private.keys, {word = "move", abbr = "move", menu = "key", icase = 1, dup = 0})
	table.insert(private.keys, {word = "return", abbr = "return", menu = "key", icase = 1, dup = 0})
	table.insert(private.keys, {word = "Self", abbr = "Self", menu = "key", icase = 1, dup = 0})
	table.insert(private.keys, {word = "self", abbr = "self", menu = "key", icase = 1, dup = 0})
	table.insert(private.keys, {word = "static", abbr = "static", menu = "key", icase = 1, dup = 0})
	table.insert(private.keys, {word = "struct", abbr = "struct", menu = "key", icase = 1, dup = 0})
	table.insert(private.keys, {word = "super", abbr = "super", menu = "key", icase = 1, dup = 0})
	table.insert(private.keys, {word = "trait", abbr = "trait", menu = "key", icase = 1, dup = 0})
	table.insert(private.keys, {word = "true", abbr = "true", menu = "key", icase = 1, dup = 0})
	table.insert(private.keys, {word = "type", abbr = "type", menu = "key", icase = 1, dup = 0})
	table.insert(private.keys, {word = "unsafe", abbr = "unsafe", menu = "key", icase = 1, dup = 0})
	table.insert(private.keys, {word = "where", abbr = "where", menu = "key", icase = 1, dup = 0})
	table.insert(private.keys, {word = "while", abbr = "while", menu = "key", icase = 1, dup = 0})
	return private.keys
end

private.rust_key_complete = function(ctx)
	local ft = helper.get_filetype()
	if ft == nil and ft ~= "go" then
		return
	end

	local typed = helper.get_line_last_word(ctx.col)
	if typed == nil or string.len(typed) == 0 then
		return
	end
	local all_keys = private.get_keys()
	local matchs = head_match.simple_match(all_keys, typed)
	cm.add_candidate(ctx, matchs)
	return
end

private.init = function()
	cm.add_engine(private.rust_key_complete, "rust")
	log.debug("add rust key complete engine success")
end

module.init = private.init
return module
